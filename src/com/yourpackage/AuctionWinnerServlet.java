package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet("/api/check-winners")
public class AuctionWinnerServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        PrintWriter out = response.getWriter();

        try {
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
                LocalDateTime now = LocalDateTime.now();
                System.out.println("=== CHECKING WINNERS AT: " + now + " ===");
                DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

                DateTimeFormatter timeFormatter1 = DateTimeFormatter.ofPattern("HH:mm:ss");
                DateTimeFormatter timeFormatter2 = DateTimeFormatter.ofPattern("HH:mm");

                int processedCount = 0;


                processedCount += processWinners(con, "tops", "topIdValue", now, dateFormatter, timeFormatter1, timeFormatter2);


                processedCount += processWinners(con, "bottoms", "bottomIdValue", now, dateFormatter, timeFormatter1, timeFormatter2);


                processedCount += processWinners(con, "shoes", "shoeIdValue", now, dateFormatter, timeFormatter1, timeFormatter2);

                out.print("{\"success\": true, \"message\": \"Processed " + processedCount + " closed auctions\", \"timestamp\": \"" + LocalDateTime.now() + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorMsg = escapeJson(e.getMessage());
            if (errorMsg == null || errorMsg.isEmpty()) {
                errorMsg = "Unknown error - check server logs";
            }
            out.print("{\"error\": \"" + errorMsg + "\", \"stackTrace\": \"" + escapeJson(getStackTrace(e)) + "\"}");
        }
    }

    private String getStackTrace(Exception e) {
        java.io.StringWriter sw = new java.io.StringWriter();
        java.io.PrintWriter pw = new java.io.PrintWriter(sw);
        e.printStackTrace(pw);
        return sw.toString();
    }

    private int processWinners(Connection con, String tableName, String idColumn,
                              LocalDateTime now, DateTimeFormatter dateFormatter,
                              DateTimeFormatter timeFormatter1, DateTimeFormatter timeFormatter2) throws Exception {
        int count = 0;



        String sql = "SELECT " + idColumn + ", auctionSellerIdValue, minimumBidPriceValue, " +
                    "startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue, descriptionValue " +
                    "FROM " + tableName + " " +
                    "WHERE buyerIdValue IS NULL";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int itemId = rs.getInt(idColumn);
                String closeDateStr = rs.getString("auctionCloseDateValue");
                String closeTimeStr = rs.getString("auctionCloseTimeValue");

                System.out.println("Processing item " + itemId + ": closeDate=" + closeDateStr + ", closeTime=" + closeTimeStr);

                if (closeDateStr == null || closeTimeStr == null) {
                    System.out.println("Skipping item " + itemId + ": null date or time");
                    continue;
                }

                try {
                    LocalDate closeDate = LocalDate.parse(closeDateStr, dateFormatter);
                    LocalTime closeTime;

                    try {
                        closeTime = LocalTime.parse(closeTimeStr, timeFormatter1);
                        System.out.println("Parsed time with seconds format: " + closeTime);
                    } catch (Exception e) {
                        try {
                            closeTime = LocalTime.parse(closeTimeStr, timeFormatter2);
                            System.out.println("Parsed time without seconds format: " + closeTime);
                        } catch (Exception e2) {
                            System.err.println("Error parsing time '" + closeTimeStr + "' for item " + itemId + ": " + e2.getMessage());
                            continue;
                        }
                    }
                    LocalDateTime closeDateTime = LocalDateTime.of(closeDate, closeTime);

                    System.out.println("Item " + itemId + ": closeDateTime=" + closeDateTime + ", now=" + now);
                    System.out.println("Item " + itemId + ": isAfter=" + now.isAfter(closeDateTime) + ", isEqual=" + now.isEqual(closeDateTime));




                    boolean isClosed = false;
                    if (now.isAfter(closeDateTime)) {
                        isClosed = true;
                        System.out.println("Item " + itemId + ": CLOSED (now is after closeDateTime)");
                    } else if (now.isEqual(closeDateTime)) {
                        isClosed = true;
                        System.out.println("Item " + itemId + ": CLOSED (now equals closeDateTime)");
                    } else if (now.toLocalDate().equals(closeDateTime.toLocalDate()) &&
                               now.toLocalTime().isAfter(closeDateTime.toLocalTime())) {

                        isClosed = true;
                        System.out.println("Item " + itemId + ": CLOSED (same day, past close time)");
                    } else if (now.toLocalDate().isAfter(closeDateTime.toLocalDate())) {

                        isClosed = true;
                        System.out.println("Item " + itemId + ": CLOSED (past close date)");
                    }

                    if (isClosed) {
                        System.out.println("Item " + itemId + " has CLOSED - processing winner...");
                        int sellerId = rs.getInt("auctionSellerIdValue");
                        float reservePrice = rs.getFloat("minimumBidPriceValue");
                        String description = rs.getString("descriptionValue");
                        if (description == null || description.trim().isEmpty()) {
                            description = "Item #" + itemId;
                        }

                        System.out.println("Item " + itemId + ": sellerId=" + sellerId + ", reservePrice=" + reservePrice);


                        String getHighestBidSql = "SELECT buyerIdValue, newBidValue " +
                                                 "FROM incrementbids " +
                                                 "WHERE itemTypeValue = ? AND itemIdValue = ? " +
                                                 "ORDER BY newBidValue DESC LIMIT 1";

                        Integer winnerId = null;
                        float winningBid = 0f;

                        try (PreparedStatement bidPs = con.prepareStatement(getHighestBidSql)) {
                            String itemType = tableName;
                            bidPs.setString(1, itemType);
                            bidPs.setInt(2, itemId);
                            ResultSet bidRs = bidPs.executeQuery();

                            if (bidRs.next()) {
                                winnerId = bidRs.getInt("buyerIdValue");
                                winningBid = bidRs.getFloat("newBidValue");
                            }
                        }


                        String itemType = tableName;

                        if (itemType.equals("tops")) itemType = "top";
                        else if (itemType.equals("bottoms")) itemType = "bottom";
                        else if (itemType.equals("shoes")) itemType = "shoe";


                        if (reservePrice > 0 && winningBid < reservePrice) {


                            String updateNoWinnerSql = "UPDATE " + tableName + " SET buyerIdValue = -1 " +
                                                      "WHERE " + idColumn + " = ?";
                            try (PreparedStatement updatePs = con.prepareStatement(updateNoWinnerSql)) {
                                updatePs.setInt(1, itemId);
                                updatePs.executeUpdate();
                            }


                            insertTransaction(con, itemType, itemId, sellerId, -1, winningBid);


                            deactivateBidsForAuction(con, itemType, itemId);


                            createNotification(con, sellerId, itemId, tableName,
                                            "Your auction for " + description + " closed. " +
                                            "Reserve price of $" + String.format("%.2f", reservePrice) +
                                            " was not met. Highest bid was $" + String.format("%.2f", winningBid) +
                                            ". No winner.");
                        } else if (winnerId != null) {


                            String updateWinnerSql = "UPDATE " + tableName + " SET buyerIdValue = ? " +
                                                   "WHERE " + idColumn + " = ?";
                            try (PreparedStatement updatePs = con.prepareStatement(updateWinnerSql)) {
                                updatePs.setInt(1, winnerId);
                                updatePs.setInt(2, itemId);
                                updatePs.executeUpdate();
                            }


                            insertTransaction(con, itemType, itemId, sellerId, winnerId, winningBid);


                            createNotification(con, winnerId, itemId, tableName,
                                            "Congratulations! You won the auction for " + description +
                                            " with a bid of $" + String.format("%.2f", winningBid) + "!");


                            createNotification(con, sellerId, itemId, tableName,
                                            "Your auction for " + description + " closed. " +
                                            "Winner: User ID " + winnerId + " with bid $" +
                                            String.format("%.2f", winningBid) + ".");


                            deactivateBidsForAuction(con, itemType, itemId);

                            count++;
                        } else {


                            String updateNoWinnerSql = "UPDATE " + tableName + " SET buyerIdValue = -1 " +
                                                      "WHERE " + idColumn + " = ?";
                            try (PreparedStatement updatePs = con.prepareStatement(updateNoWinnerSql)) {
                                updatePs.setInt(1, itemId);
                                updatePs.executeUpdate();
                            }


                            insertTransaction(con, itemType, itemId, sellerId, -1, 0f);


                            deactivateBidsForAuction(con, itemType, itemId);

                            createNotification(con, sellerId, itemId, tableName,
                                            "Your auction for " + description + " closed with no bids.");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error processing item " + itemId + ": " + e.getMessage());
                    e.printStackTrace();
                    continue;
                }
            }
        }

        return count;
    }

    private void insertTransaction(Connection con, String itemType, int itemId, int sellerId, int buyerId, float finalPrice)
            throws Exception {

        String createTableSql = "CREATE TABLE IF NOT EXISTS auction_transactions (" +
                               "transactionIdValue INT AUTO_INCREMENT PRIMARY KEY, " +
                               "itemTypeValue VARCHAR(20) NOT NULL, " +
                               "itemIdValue INT NOT NULL, " +
                               "sellerIdValue INT NOT NULL, " +
                               "buyerIdValue INT NOT NULL, " +
                               "finalPriceValue DECIMAL(10, 2) NOT NULL, " +
                               "transactionDateValue TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                               "INDEX idx_item (itemTypeValue, itemIdValue), " +
                               "INDEX idx_seller (sellerIdValue), " +
                               "INDEX idx_buyer (buyerIdValue), " +
                               "INDEX idx_date (transactionDateValue)) " +
                               "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
        try (PreparedStatement ps = con.prepareStatement(createTableSql)) {
            ps.execute();
        } catch (Exception e) {

        }


        String checkSql = "SELECT transactionIdValue FROM auction_transactions " +
                         "WHERE itemTypeValue = ? AND itemIdValue = ?";
        boolean exists = false;
        try (PreparedStatement ps = con.prepareStatement(checkSql)) {
            ps.setString(1, itemType);
            ps.setInt(2, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                exists = true;
            }
        }

        if (!exists) {
            String insertSql = "INSERT INTO auction_transactions " +
                             "(itemTypeValue, itemIdValue, sellerIdValue, buyerIdValue, finalPriceValue) " +
                             "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setString(1, itemType);
                ps.setInt(2, itemId);
                ps.setInt(3, sellerId);
                ps.setInt(4, buyerId);
                ps.setFloat(5, finalPrice);
                ps.executeUpdate();
                System.out.println("Inserted transaction: itemType=" + itemType + ", itemId=" + itemId +
                                 ", sellerId=" + sellerId + ", buyerId=" + buyerId + ", price=" + finalPrice);
            }
        }
    }

    private void deactivateBidsForAuction(Connection con, String itemType, int itemId) throws Exception {

        String deactivateBidsSql = "UPDATE incrementbids SET isActiveValue = FALSE " +
                                 "WHERE itemTypeValue = ? AND itemIdValue = ?";
        try (PreparedStatement deactivatePs = con.prepareStatement(deactivateBidsSql)) {
            deactivatePs.setString(1, itemType);
            deactivatePs.setInt(2, itemId);
            int rowsUpdated = deactivatePs.executeUpdate();
            System.out.println("Deactivated " + rowsUpdated + " bids for auction: itemType=" + itemType + ", itemId=" + itemId);
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

