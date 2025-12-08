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

@WebServlet("/api/shoes")
public class ShoesApiServlet extends HttpServlet {
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
            Integer currentUserId = null;
            if (session != null) {
                currentUserId = (Integer) session.getAttribute("userIdValue");
            }

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                String sql = "SELECT s.*, u.usernameValue AS sellerUsername " +
                           "FROM shoes s " +
                           "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                           "WHERE s.isActiveValue = TRUE " +
                           "ORDER BY s.shoeIdValue DESC";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ResultSet rs = ps.executeQuery();
                    StringBuilder json = new StringBuilder("[");
                    boolean first = true;

                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;

                        int sellerId = rs.getInt("auctionSellerIdValue");
                        boolean isSeller = (currentUserId != null && currentUserId == sellerId);
                        float minBid = rs.getFloat("minimumBidPriceValue");

                        json.append("{");
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


                        int itemId = rs.getInt("shoeIdValue");
                        String imagesJson = getItemImages(con, "shoes", itemId);
                        json.append("\"images\":").append(imagesJson).append(",");

                        int buyerId = rs.getInt("buyerIdValue");
                        json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
                        json.append("}");
                    }

                    json.append("]");
                    out.print(json.toString());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String getItemImages(Connection con, String itemType, int itemId) throws Exception {
        StringBuilder imagesJson = new StringBuilder("[");
        try {
            String sql = "SELECT imagePathValue FROM item_images " +
                        "WHERE itemTypeValue = ? AND itemIdValue = ? " +
                        "ORDER BY displayOrderValue ASC, createdAtValue ASC";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, itemType);
                ps.setInt(2, itemId);
                ResultSet rs = ps.executeQuery();
                boolean first = true;
                while (rs.next()) {
                    if (!first) imagesJson.append(",");
                    first = false;
                    String imagePath = rs.getString("imagePathValue");
                    imagesJson.append("\"").append(escapeJson(imagePath)).append("\"");
                }
            }
        } catch (Exception e) {

        }
        imagesJson.append("]");
        return imagesJson.toString();
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

