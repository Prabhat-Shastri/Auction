package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/bid")
public class BidApiServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");


        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userIdValue") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Not logged in\"}");
                return;
            }

            Integer userIdValue = (Integer) session.getAttribute("userIdValue");
            String itemType = request.getParameter("itemType");
            Integer itemId = Integer.parseInt(request.getParameter("itemId"));
            Float newBid = Float.parseFloat(request.getParameter("newBid"));
            String autoIncrement = request.getParameter("autoIncrement");
            String maxBid = request.getParameter("maxBid");

            Class.forName("com.mysql.cj.jdbc.Driver");

            String jdbcUrl = System.getenv("JDBC_URL");
            if (jdbcUrl == null || jdbcUrl.isEmpty()) {
                String dbHost = System.getenv("DB_HOST");
                String dbPort = System.getenv("DB_PORT");
                String dbName = System.getenv("DB_NAME");
                if (dbHost == null) dbHost = "localhost";
                if (dbPort == null) dbPort = "3306";
                if (dbName == null) dbName = "thriftShop";
                jdbcUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName;
            }
            String dbUser = System.getenv("DB_USER");
            if (dbUser == null) dbUser = "root";
            String dbPass = System.getenv("DB_PASS");
            if (dbPass == null) dbPass = "12345";

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {

                String tableName;
                String idColumn;
                if ("top".equals(itemType)) {
                    tableName = "tops";
                    idColumn = "topIdValue";
                } else if ("bottom".equals(itemType)) {
                    tableName = "bottoms";
                    idColumn = "bottomIdValue";
                } else if ("shoe".equals(itemType)) {
                    tableName = "shoes";
                    idColumn = "shoeIdValue";
                } else {
                    out.print("{\"success\": false, \"message\": \"Invalid item type\"}");
                    return;
                }
                String priceColumn = "startingOrCurrentBidPriceValue";

                String getCurrentBidSql = "SELECT " + priceColumn + ", auctionCloseDateValue, auctionCloseTimeValue, buyerIdValue " +
                                         "FROM " + tableName + " WHERE " + idColumn + " = ? AND isActiveValue = TRUE";
                float currentBid = 0f;
                String closeDateStr = null;
                String closeTimeStr = null;
                Integer buyerIdValue = null;

                try (PreparedStatement ps = con.prepareStatement(getCurrentBidSql)) {
                    ps.setInt(1, itemId);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        currentBid = rs.getFloat(priceColumn);
                        closeDateStr = rs.getString("auctionCloseDateValue");
                        closeTimeStr = rs.getString("auctionCloseTimeValue");
                        int buyerId = rs.getInt("buyerIdValue");
                        if (!rs.wasNull()) {
                            buyerIdValue = buyerId;
                        }
                    } else {
                        out.print("{\"success\": false, \"message\": \"Item not found\"}");
                        return;
                    }
                }


                if (buyerIdValue != null && buyerIdValue != 0) {
                    if (buyerIdValue == -1) {
                        out.print("{\"success\": false, \"message\": \"This auction has closed with no winner\"}");
                    } else {
                        out.print("{\"success\": false, \"message\": \"This auction has already been sold\"}");
                    }
                    return;
                }


                if (closeDateStr != null && closeTimeStr != null) {
                    try {
                        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                        DateTimeFormatter timeFormatter1 = DateTimeFormatter.ofPattern("HH:mm:ss");
                        DateTimeFormatter timeFormatter2 = DateTimeFormatter.ofPattern("HH:mm");

                        LocalDate closeDate = LocalDate.parse(closeDateStr, dateFormatter);
                        LocalTime closeTime;
                        try {
                            closeTime = LocalTime.parse(closeTimeStr, timeFormatter1);
                        } catch (Exception e) {
                            closeTime = LocalTime.parse(closeTimeStr, timeFormatter2);
                        }
                        LocalDateTime closeDateTime = LocalDateTime.of(closeDate, closeTime);
                        LocalDateTime now = LocalDateTime.now();

                        if (now.isAfter(closeDateTime) || now.isEqual(closeDateTime)) {
                            out.print("{\"success\": false, \"message\": \"This auction has closed. Bidding is no longer allowed.\"}");
                            return;
                        }
                    } catch (Exception e) {

                        System.err.println("Error parsing close date/time for item " + itemId + ": " + e.getMessage());
                    }
                }

                if (newBid > currentBid) {

                    String normalizedItemType = itemType.endsWith("s") ? itemType : itemType + "s";


                    String insertBidSql = "INSERT INTO incrementbids " +
                                         "(buyerIdValue, newBidValue, bidIncrementValue, bidMaxValue, " +
                                         "itemTypeValue, itemIdValue) VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = con.prepareStatement(insertBidSql)) {
                        ps.setInt(1, userIdValue);
                        ps.setFloat(2, newBid);
                        ps.setString(3, autoIncrement != null && !autoIncrement.isEmpty() ? autoIncrement : "");
                        ps.setString(4, maxBid != null && !maxBid.isEmpty() ? maxBid : "");
                        ps.setString(5, normalizedItemType);
                        ps.setInt(6, itemId);
                        ps.executeUpdate();
                    }


                    String updatePriceSql = "UPDATE " + tableName + " SET " + priceColumn + " = ? " +
                                          "WHERE " + idColumn + " = ?";
                    try (PreparedStatement ps = con.prepareStatement(updatePriceSql)) {
                        ps.setFloat(1, newBid);
                        ps.setInt(2, itemId);
                        ps.executeUpdate();
                    }


                    List<Integer> notifiedBuyers = new ArrayList<>();
                    float finalBid = newBid;
                    Integer originalBidder = userIdValue;
                    boolean autoBidPlaced = true;


                    while (autoBidPlaced) {
                        autoBidPlaced = false;


                        String getAutoBidsSql = "SELECT ib.buyerIdValue, ib.bidMaxValue, ib.bidIncrementValue, " +
                                              "MAX(ib.newBidValue) as maxBidValue " +
                                              "FROM incrementbids ib " +
                                              "WHERE ib.itemTypeValue = ? AND ib.itemIdValue = ? " +
                                              "AND ib.buyerIdValue != ? " +
                                              "AND ib.isActiveValue = TRUE " +
                                              "AND ib.bidMaxValue IS NOT NULL AND ib.bidMaxValue != '' " +
                                              "AND ib.bidMaxValue != '0' " +
                                              "AND ib.bidIncrementValue IS NOT NULL AND ib.bidIncrementValue != '' " +
                                              "AND ib.bidIncrementValue != '0' " +
                                              "GROUP BY ib.buyerIdValue, ib.bidMaxValue, ib.bidIncrementValue";

                        try (PreparedStatement ps = con.prepareStatement(getAutoBidsSql)) {
                            ps.setString(1, normalizedItemType);
                            ps.setInt(2, itemId);
                            ps.setInt(3, userIdValue);
                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                                int otherBuyerId = rs.getInt("buyerIdValue");
                                String maxBidStr = rs.getString("bidMaxValue");
                                String incrementStr = rs.getString("bidIncrementValue");

                                if (maxBidStr == null || maxBidStr.isEmpty() ||
                                    incrementStr == null || incrementStr.isEmpty()) {
                                    continue;
                                }

                                try {
                                    float buyerMaxBid = Float.parseFloat(maxBidStr);
                                    float increment = Float.parseFloat(incrementStr);
                                    float theirCurrentBid = rs.getFloat("maxBidValue");


                                    if (finalBid > buyerMaxBid) {
                                        createNotification(con, otherBuyerId, itemId, normalizedItemType,
                                                         "Your maximum bid of $" + String.format("%.2f", buyerMaxBid) +
                                                         " has been exceeded. Current bid is now $" +
                                                         String.format("%.2f", finalBid) + ".");
                                        notifiedBuyers.add(otherBuyerId);
                                    }

                                    else if (finalBid < buyerMaxBid && theirCurrentBid < buyerMaxBid) {
                                        float nextBid = Math.min(finalBid + increment, buyerMaxBid);
                                        if (nextBid > finalBid) {

                                            String autoBidSql = "INSERT INTO incrementbids " +
                                                               "(buyerIdValue, newBidValue, bidIncrementValue, bidMaxValue, " +
                                                               "itemTypeValue, itemIdValue) VALUES (?, ?, ?, ?, ?, ?)";
                                            try (PreparedStatement autoPs = con.prepareStatement(autoBidSql)) {
                                                autoPs.setInt(1, otherBuyerId);
                                                autoPs.setFloat(2, nextBid);
                                                autoPs.setString(3, incrementStr);
                                                autoPs.setString(4, maxBidStr);
                                                autoPs.setString(5, normalizedItemType);
                                                autoPs.setInt(6, itemId);
                                                autoPs.executeUpdate();
                                            }


                                            try (PreparedStatement updatePs = con.prepareStatement(updatePriceSql)) {
                                                updatePs.setFloat(1, nextBid);
                                                updatePs.setInt(2, itemId);
                                                updatePs.executeUpdate();
                                            }


                                            createNotification(con, originalBidder, itemId, normalizedItemType,
                                                             "You were outbid! New bid is $" + String.format("%.2f", nextBid) + ".");

                                            finalBid = nextBid;
                                            userIdValue = otherBuyerId;
                                            autoBidPlaced = true;
                                            break;
                                        }
                                    }
                                } catch (NumberFormatException e) {

                                    continue;
                                }
                            }
                        }
                    }


                    String getOtherBiddersSql = "SELECT DISTINCT buyerIdValue FROM incrementbids " +
                                               "WHERE itemTypeValue = ? AND itemIdValue = ? " +
                                               "AND buyerIdValue != ? AND isActiveValue = TRUE";
                    try (PreparedStatement ps = con.prepareStatement(getOtherBiddersSql)) {
                        ps.setString(1, normalizedItemType);
                        ps.setInt(2, itemId);
                        ps.setInt(3, originalBidder);
                        ResultSet rs = ps.executeQuery();

                        while (rs.next()) {
                            int otherBuyerId = rs.getInt("buyerIdValue");
                            if (!notifiedBuyers.contains(otherBuyerId)) {
                                createNotification(con, otherBuyerId, itemId, normalizedItemType,
                                                 "A new bid of $" + String.format("%.2f", finalBid) +
                                                 " has been placed on this item.");
                            }
                        }
                    }

                    out.print("{\"success\": true, \"message\": \"Bid placed successfully\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Bid must be higher than current bid\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void createNotification(Connection con, int userId, int itemId, String itemType, String message)
            throws Exception {

        String createTableSql = "CREATE TABLE IF NOT EXISTS notifications (" +
                               "notificationIdValue INT AUTO_INCREMENT PRIMARY KEY, " +
                               "userIdValue INT, " +
                               "itemIdValue INT, " +
                               "itemTypeValue VARCHAR(20), " +
                               "messageValue TEXT, " +
                               "isReadValue BOOLEAN DEFAULT FALSE, " +
                               "createdAtValue TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                               "FOREIGN KEY (userIdValue) REFERENCES users(userIdValue))";
        try (PreparedStatement ps = con.prepareStatement(createTableSql)) {
            ps.execute();
        } catch (Exception e) {

        }

        String insertSql = "INSERT INTO notifications (userIdValue, itemIdValue, itemTypeValue, messageValue) " +
                          "VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(insertSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, itemId);
            ps.setString(3, itemType);
            ps.setString(4, message);
            ps.executeUpdate();
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
