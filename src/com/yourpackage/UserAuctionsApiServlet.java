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

@WebServlet("/api/user-auctions")
public class UserAuctionsApiServlet extends HttpServlet {
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

            HttpSession session = request.getSession(false);
            if (session == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Not authenticated\"}");
                return;
            }

            Integer currentUserId = (Integer) session.getAttribute("userIdValue");
            if (currentUserId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Not authenticated\"}");
                return;
            }

            String role = request.getParameter("role");
            String targetUserId = request.getParameter("userId");

            Integer targetId = currentUserId;
            if (targetUserId != null && !targetUserId.isEmpty()) {
                try {
                    targetId = Integer.parseInt(targetUserId);
                } catch (NumberFormatException e) {
                    targetId = currentUserId;
                }
            }

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;

                if ("buyer".equals(role)) {

                    first = getBuyerAuctions(con, targetId, json, first);
                } else if ("seller".equals(role)) {

                    first = getSellerAuctions(con, targetId, json, first);
                } else {

                    first = getBuyerAuctions(con, targetId, json, first);
                    first = getSellerAuctions(con, targetId, json, first);
                }

                json.append("]");
                out.print(json.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private boolean getBuyerAuctions(Connection con, Integer userId, StringBuilder json, boolean first) throws Exception {

        String sql = "SELECT DISTINCT ib.itemTypeValue, ib.itemIdValue " +
                    "FROM incrementbids ib " +
                    "WHERE ib.buyerIdValue = ? AND ib.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String itemType = rs.getString("itemTypeValue");
                int itemId = rs.getInt("itemIdValue");


                if ("top".equals(itemType) || "tops".equals(itemType)) {
                    first = getTopDetails(con, itemId, json, first);
                } else if ("bottom".equals(itemType) || "bottoms".equals(itemType)) {
                    first = getBottomDetails(con, itemId, json, first);
                } else if ("shoe".equals(itemType) || "shoes".equals(itemType)) {
                    first = getShoeDetails(con, itemId, json, first);
                }
            }
        }
        return first;
    }

    private boolean getSellerAuctions(Connection con, Integer userId, StringBuilder json, boolean first) throws Exception {

        String sql = "SELECT t.*, u.usernameValue AS sellerUsername " +
                    "FROM tops t " +
                    "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                    "WHERE t.auctionSellerIdValue = ? AND t.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendTopJson(rs, json, userId);
            }
        }


        sql = "SELECT b.*, u.usernameValue AS sellerUsername " +
             "FROM bottoms b " +
             "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
             "WHERE b.auctionSellerIdValue = ? AND b.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendBottomJson(rs, json, userId);
            }
        }


        sql = "SELECT s.*, u.usernameValue AS sellerUsername " +
             "FROM shoes s " +
             "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
             "WHERE s.auctionSellerIdValue = ? AND s.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendShoeJson(rs, json, userId);
            }
        }

        return first;
    }

    private boolean getTopDetails(Connection con, int itemId, StringBuilder json, boolean first) throws Exception {
        String sql = "SELECT t.*, u.usernameValue AS sellerUsername " +
                    "FROM tops t " +
                    "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                    "WHERE t.topIdValue = ? AND t.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendTopJson(rs, json, null);
            }
        }
        return first;
    }

    private boolean getBottomDetails(Connection con, int itemId, StringBuilder json, boolean first) throws Exception {
        String sql = "SELECT b.*, u.usernameValue AS sellerUsername " +
                    "FROM bottoms b " +
                    "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
                    "WHERE b.bottomIdValue = ? AND b.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendBottomJson(rs, json, null);
            }
        }
        return first;
    }

    private boolean getShoeDetails(Connection con, int itemId, StringBuilder json, boolean first) throws Exception {
        String sql = "SELECT s.*, u.usernameValue AS sellerUsername " +
                    "FROM shoes s " +
                    "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                    "WHERE s.shoeIdValue = ? AND s.isActiveValue = TRUE";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                if (!first) json.append(",");
                first = false;
                appendShoeJson(rs, json, null);
            }
        }
        return first;
    }

    private void appendTopJson(ResultSet rs, StringBuilder json, Integer currentUserId) throws Exception {
        int sellerId = rs.getInt("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && currentUserId == sellerId);
        float minBid = rs.getFloat("minimumBidPriceValue");

        json.append("{");
        json.append("\"type\":\"top\",");
        json.append("\"id\":").append(rs.getInt("topIdValue")).append(",");
        json.append("\"sellerId\":").append(sellerId).append(",");
        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\",");
        json.append("\"gender\":\"").append(escapeJson(rs.getString("genderValue"))).append("\",");
        json.append("\"size\":\"").append(escapeJson(rs.getString("sizeValue"))).append("\",");
        json.append("\"color\":\"").append(escapeJson(rs.getString("colorValue"))).append("\",");
        json.append("\"frontLength\":").append(rs.getFloat("frontLengthValue")).append(",");
        json.append("\"chestLength\":").append(rs.getFloat("chestLengthValue")).append(",");
        json.append("\"sleeveLength\":").append(rs.getFloat("sleeveLengthValue")).append(",");
        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
        json.append("\"condition\":\"").append(escapeJson(rs.getString("conditionValue"))).append("\",");
        if (isSeller) {
            json.append("\"minimumBidPrice\":").append(minBid).append(",");
        } else {
            json.append("\"minimumBidPrice\":null,");
        }
        json.append("\"currentBidPrice\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
        json.append("\"closeDate\":\"").append(escapeJson(rs.getString("auctionCloseDateValue"))).append("\",");
        json.append("\"closeTime\":\"").append(escapeJson(rs.getString("auctionCloseTimeValue"))).append("\",");
        String imagePath = rs.getString("imagePathValue");
        json.append("\"imagePath\":").append(imagePath != null ? "\"" + escapeJson(imagePath) + "\"" : "null").append(",");
        int buyerId = rs.getInt("buyerIdValue");
        json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
        json.append("}");
    }

    private void appendBottomJson(ResultSet rs, StringBuilder json, Integer currentUserId) throws Exception {
        int sellerId = rs.getInt("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && currentUserId == sellerId);
        float minBid = rs.getFloat("minimumBidPriceValue");

        json.append("{");
        json.append("\"type\":\"bottom\",");
        json.append("\"id\":").append(rs.getInt("bottomIdValue")).append(",");
        json.append("\"sellerId\":").append(sellerId).append(",");
        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\",");
        json.append("\"gender\":\"").append(escapeJson(rs.getString("genderValue"))).append("\",");
        json.append("\"size\":\"").append(escapeJson(rs.getString("sizeValue"))).append("\",");
        json.append("\"color\":\"").append(escapeJson(rs.getString("colorValue"))).append("\",");
        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
        json.append("\"condition\":\"").append(escapeJson(rs.getString("conditionValue"))).append("\",");
        if (isSeller) {
            json.append("\"minimumBidPrice\":").append(minBid).append(",");
        } else {
            json.append("\"minimumBidPrice\":null,");
        }
        json.append("\"currentBidPrice\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
        json.append("\"closeDate\":\"").append(escapeJson(rs.getString("auctionCloseDateValue"))).append("\",");
        json.append("\"closeTime\":\"").append(escapeJson(rs.getString("auctionCloseTimeValue"))).append("\",");
        String imagePath = rs.getString("imagePathValue");
        json.append("\"imagePath\":").append(imagePath != null ? "\"" + escapeJson(imagePath) + "\"" : "null").append(",");
        int buyerId = rs.getInt("buyerIdValue");
        json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
        json.append("}");
    }

    private void appendShoeJson(ResultSet rs, StringBuilder json, Integer currentUserId) throws Exception {
        int sellerId = rs.getInt("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && currentUserId == sellerId);
        float minBid = rs.getFloat("minimumBidPriceValue");

        json.append("{");
        json.append("\"type\":\"shoe\",");
        json.append("\"id\":").append(rs.getInt("shoeIdValue")).append(",");
        json.append("\"sellerId\":").append(sellerId).append(",");
        json.append("\"sellerUsername\":\"").append(escapeJson(rs.getString("sellerUsername"))).append("\",");
        json.append("\"gender\":\"").append(escapeJson(rs.getString("genderValue"))).append("\",");
        json.append("\"size\":\"").append(escapeJson(rs.getString("sizeValue"))).append("\",");
        json.append("\"color\":\"").append(escapeJson(rs.getString("colorValue"))).append("\",");
        json.append("\"description\":\"").append(escapeJson(rs.getString("descriptionValue"))).append("\",");
        json.append("\"condition\":\"").append(escapeJson(rs.getString("conditionValue"))).append("\",");
        if (isSeller) {
            json.append("\"minimumBidPrice\":").append(minBid).append(",");
        } else {
            json.append("\"minimumBidPrice\":null,");
        }
        json.append("\"currentBidPrice\":").append(rs.getFloat("startingOrCurrentBidPriceValue")).append(",");
        json.append("\"closeDate\":\"").append(escapeJson(rs.getString("auctionCloseDateValue"))).append("\",");
        json.append("\"closeTime\":\"").append(escapeJson(rs.getString("auctionCloseTimeValue"))).append("\",");
        String imagePath = rs.getString("imagePathValue");
        json.append("\"imagePath\":").append(imagePath != null ? "\"" + escapeJson(imagePath) + "\"" : "null").append(",");
        int buyerId = rs.getInt("buyerIdValue");
        json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
        json.append("}");
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

