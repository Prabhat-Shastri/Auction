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

@WebServlet("/api/bid-history")
public class BidHistoryApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userIdValue") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Not logged in\"}");
                return;
            }

            Integer userIdValue = (Integer) session.getAttribute("userIdValue");
            String itemType = request.getParameter("itemType");
            String itemIdParam = request.getParameter("itemId");

            if (itemType == null || itemIdParam == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"itemType and itemId are required\"}");
                return;
            }

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
                if ("top".equals(itemType) || "tops".equals(itemType)) {
                    tableName = "tops";
                    idColumn = "topIdValue";
                } else if ("bottom".equals(itemType) || "bottoms".equals(itemType)) {
                    tableName = "bottoms";
                    idColumn = "bottomIdValue";
                } else if ("shoe".equals(itemType) || "shoes".equals(itemType)) {
                    tableName = "shoes";
                    idColumn = "shoeIdValue";
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\": \"Invalid item type\"}");
                    return;
                }

                int itemId = Integer.parseInt(itemIdParam);


                String itemSql = "SELECT i.*, u.usernameValue AS sellerUsername " +
                               "FROM " + tableName + " i " +
                               "JOIN users u ON i.auctionSellerIdValue = u.userIdValue " +
                               "WHERE i." + idColumn + " = ? AND i.isActiveValue = TRUE";

                StringBuilder json = new StringBuilder("{");

                try (PreparedStatement psItem = con.prepareStatement(itemSql)) {
                    psItem.setInt(1, itemId);
                    ResultSet rsItem = psItem.executeQuery();

                    if (rsItem.next()) {
                        json.append("\"item\":{");
                        json.append("\"type\":\"").append(itemType).append("\",");
                        json.append("\"id\":").append(rsItem.getInt(idColumn)).append(",");
                        json.append("\"sellerUsername\":\"").append(escapeJson(rsItem.getString("sellerUsername"))).append("\",");
                        json.append("\"gender\":\"").append(escapeJson(rsItem.getString("genderValue"))).append("\",");
                        json.append("\"size\":\"").append(escapeJson(rsItem.getString("sizeValue"))).append("\",");
                        json.append("\"color\":\"").append(escapeJson(rsItem.getString("colorValue"))).append("\",");
                        json.append("\"description\":\"").append(escapeJson(rsItem.getString("descriptionValue"))).append("\",");
                        json.append("\"condition\":\"").append(escapeJson(rsItem.getString("conditionValue"))).append("\",");
                        json.append("\"currentBidPrice\":").append(rsItem.getFloat("startingOrCurrentBidPriceValue")).append(",");
                        json.append("\"closeDate\":\"").append(escapeJson(rsItem.getString("auctionCloseDateValue"))).append("\",");
                        json.append("\"closeTime\":\"").append(escapeJson(rsItem.getString("auctionCloseTimeValue"))).append("\"");
                        json.append("},");
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{\"error\": \"Item not found\"}");
                        return;
                    }
                }


                String bidSql = "SELECT ib.*, u.usernameValue AS buyerUsername " +
                              "FROM incrementbids ib " +
                              "JOIN users u ON ib.buyerIdValue = u.userIdValue " +
                              "WHERE ib.itemTypeValue = ? AND ib.itemIdValue = ? AND ib.isActiveValue = TRUE " +
                              "ORDER BY ib.newBidValue DESC";

                json.append("\"bids\":[");
                boolean first = true;

                try (PreparedStatement psBids = con.prepareStatement(bidSql)) {
                    String normalizedType = itemType.endsWith("s") ? itemType : itemType + "s";
                    psBids.setString(1, normalizedType);
                    psBids.setInt(2, itemId);
                    ResultSet rsBids = psBids.executeQuery();

                    while (rsBids.next()) {
                        if (!first) json.append(",");
                        first = false;

                        int bidBuyerId = rsBids.getInt("buyerIdValue");
                        boolean isOwnBid = (bidBuyerId == userIdValue.intValue());

                        json.append("{");
                        json.append("\"bidId\":").append(rsBids.getInt("bidIdValue")).append(",");
                        json.append("\"buyerUsername\":\"").append(escapeJson(rsBids.getString("buyerUsername"))).append("\",");
                        json.append("\"bidAmount\":").append(rsBids.getFloat("newBidValue")).append(",");
                        json.append("\"buyerId\":").append(bidBuyerId).append(",");

                        if (isOwnBid) {
                            json.append("\"bidIncrement\":\"").append(escapeJson(rsBids.getString("bidIncrementValue"))).append("\",");
                            json.append("\"maxBid\":\"").append(escapeJson(rsBids.getString("bidMaxValue"))).append("\"");
                        } else {
                            json.append("\"bidIncrement\":null,");
                            json.append("\"maxBid\":null");
                        }
                        json.append("}");
                    }
                }

                json.append("]}");
                out.print(json.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
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

