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

@WebServlet("/api/customer-rep/manage")
public class ManageBidsAuctionsServlet extends HttpServlet {

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
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

        Integer role = (Integer) session.getAttribute("roleValue");
        if (role == null || role != 2) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\": false, \"message\": \"Customer representative access required\"}");
            return;
        }

        try {
            String action = request.getParameter("action");
            String bidId = request.getParameter("bidId");
            String auctionId = request.getParameter("auctionId");
            String itemType = request.getParameter("itemType");

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
                if ("removeBid".equals(action) && bidId != null) {

                    String sql = "UPDATE incrementbids SET isActiveValue = FALSE WHERE bidIdValue = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(bidId));
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"Bid removed successfully\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"Bid not found\"}");
                        }
                    }
                } else if ("removeAuction".equals(action) && auctionId != null && itemType != null) {

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
                        out.print("{\"success\": false, \"message\": \"Invalid item type\"}");
                        return;
                    }

                    String sql = "UPDATE " + tableName + " SET isActiveValue = FALSE WHERE " + idColumn + " = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(auctionId));
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"Auction removed successfully\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"Auction not found\"}");
                        }
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Invalid parameters\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Not authenticated\"}");
            return;
        }

        Integer role = (Integer) session.getAttribute("roleValue");
        if (role == null || role != 2) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\": \"Customer representative access required\"}");
            return;
        }

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
                StringBuilder json = new StringBuilder("{");


                json.append("\"bids\":[");
                String bidsSql = "SELECT ib.bidIdValue, ib.itemTypeValue, ib.itemIdValue, ib.newBidValue, " +
                                "ib.buyerIdValue, u.usernameValue as buyerUsername " +
                                "FROM incrementbids ib " +
                                "JOIN users u ON ib.buyerIdValue = u.userIdValue " +
                                "LEFT JOIN tops t ON ib.itemTypeValue = 'top' AND ib.itemIdValue = t.topIdValue " +
                                "LEFT JOIN bottoms b ON ib.itemTypeValue = 'bottom' AND ib.itemIdValue = b.bottomIdValue " +
                                "LEFT JOIN shoes s ON ib.itemTypeValue = 'shoe' AND ib.itemIdValue = s.shoeIdValue " +
                                "WHERE ib.isActiveValue = TRUE " +
                                "AND (t.buyerIdValue IS NULL OR b.buyerIdValue IS NULL OR s.buyerIdValue IS NULL) " +
                                "ORDER BY ib.bidIdValue DESC LIMIT 100";

                boolean first = true;
                try (PreparedStatement ps = con.prepareStatement(bidsSql)) {
                    java.sql.ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"bidId\":").append(rs.getInt("bidIdValue")).append(",");
                        json.append("\"itemType\":\"").append(rs.getString("itemTypeValue")).append("\",");
                        json.append("\"itemId\":").append(rs.getInt("itemIdValue")).append(",");
                        json.append("\"bidAmount\":").append(rs.getFloat("newBidValue")).append(",");
                        json.append("\"buyerId\":").append(rs.getInt("buyerIdValue")).append(",");
                        json.append("\"buyerUsername\":\"").append(escapeJson(rs.getString("buyerUsername"))).append("\"");
                        json.append("}");
                    }
                }
                json.append("],");


                json.append("\"auctions\":[");
                first = true;


                String topsSql = "SELECT t.topIdValue as itemId, 'top' as itemType, t.descriptionValue, " +
                                "t.startingOrCurrentBidPriceValue, u.usernameValue as sellerUsername " +
                                "FROM tops t " +
                                "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                                "WHERE t.isActiveValue = TRUE " +
                                "ORDER BY t.topIdValue DESC";
                try (PreparedStatement ps = con.prepareStatement(topsSql)) {
                    java.sql.ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"itemId\":").append(rs.getInt("itemId")).append(",");
                        json.append("\"itemType\":\"").append(rs.getString("itemType")).append("\",");
                        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
                        json.append("\"currentBid\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
                        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\"");
                        json.append("}");
                    }
                }


                String bottomsSql = "SELECT b.bottomIdValue as itemId, 'bottom' as itemType, b.descriptionValue, " +
                                   "b.startingOrCurrentBidPriceValue, u.usernameValue as sellerUsername " +
                                   "FROM bottoms b " +
                                   "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
                                   "WHERE b.isActiveValue = TRUE " +
                                   "ORDER BY b.bottomIdValue DESC";
                try (PreparedStatement ps = con.prepareStatement(bottomsSql)) {
                    java.sql.ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"itemId\":").append(rs.getInt("itemId")).append(",");
                        json.append("\"itemType\":\"").append(rs.getString("itemType")).append("\",");
                        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
                        json.append("\"currentBid\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
                        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\"");
                        json.append("}");
                    }
                }


                String shoesSql = "SELECT s.shoeIdValue as itemId, 'shoe' as itemType, s.descriptionValue, " +
                                 "s.startingOrCurrentBidPriceValue, u.usernameValue as sellerUsername " +
                                 "FROM shoes s " +
                                 "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                                 "WHERE s.isActiveValue = TRUE " +
                                 "ORDER BY s.shoeIdValue DESC";
                try (PreparedStatement ps = con.prepareStatement(shoesSql)) {
                    java.sql.ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"itemId\":").append(rs.getInt("itemId")).append(",");
                        json.append("\"itemType\":\"").append(rs.getString("itemType")).append("\",");
                        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
                        json.append("\"currentBid\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
                        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\"");
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

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setStatus(HttpServletResponse.SC_OK);
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

