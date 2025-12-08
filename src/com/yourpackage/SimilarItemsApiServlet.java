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
import java.time.format.DateTimeFormatter;

@WebServlet("/api/similar-items")
public class SimilarItemsApiServlet extends HttpServlet {
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

            String itemType = request.getParameter("itemType");
            String itemId = request.getParameter("itemId");

            if (itemType == null || itemId == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"itemType and itemId are required\"}");
                return;
            }


            LocalDate oneMonthAgo = LocalDate.now().minusMonths(1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            String oneMonthAgoStr = oneMonthAgo.format(formatter);

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                StringBuilder json = new StringBuilder("[");
                boolean first = true;


                String refGender = null;
                String refSize = null;
                String refColor = null;
                String refCondition = null;

                if ("top".equals(itemType) || "tops".equals(itemType)) {
                    String sql = "SELECT genderValue, sizeValue, colorValue, conditionValue " +
                                "FROM tops WHERE topIdValue = ? AND isActiveValue = TRUE";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(itemId));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            refGender = rs.getString("genderValue");
                            refSize = rs.getString("sizeValue");
                            refColor = rs.getString("colorValue");
                            refCondition = rs.getString("conditionValue");
                        }
                    }

                    first = findSimilarTops(con, currentUserId, refGender, refSize, refColor, refCondition,
                                          oneMonthAgoStr, Integer.parseInt(itemId), json, first);
                } else if ("bottom".equals(itemType) || "bottoms".equals(itemType)) {
                    String sql = "SELECT genderValue, sizeValue, colorValue, conditionValue " +
                                "FROM bottoms WHERE bottomIdValue = ? AND isActiveValue = TRUE";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(itemId));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            refGender = rs.getString("genderValue");
                            refSize = rs.getString("sizeValue");
                            refColor = rs.getString("colorValue");
                            refCondition = rs.getString("conditionValue");
                        }
                    }
                    first = findSimilarBottoms(con, currentUserId, refGender, refSize, refColor, refCondition,
                                            oneMonthAgoStr, Integer.parseInt(itemId), json, first);
                } else if ("shoe".equals(itemType) || "shoes".equals(itemType)) {
                    String sql = "SELECT genderValue, sizeValue, colorValue, conditionValue " +
                                "FROM shoes WHERE shoeIdValue = ? AND isActiveValue = TRUE";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(itemId));
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            refGender = rs.getString("genderValue");
                            refSize = rs.getString("sizeValue");
                            refColor = rs.getString("colorValue");
                            refCondition = rs.getString("conditionValue");
                        }
                    }
                    first = findSimilarShoes(con, currentUserId, refGender, refSize, refColor, refCondition,
                                           oneMonthAgoStr, Integer.parseInt(itemId), json, first);
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

    private boolean findSimilarTops(Connection con, Integer currentUserId, String refGender, String refSize,
                                   String refColor, String refCondition, String oneMonthAgoStr, int excludeId,
                                   StringBuilder json, boolean first) throws Exception {


        String sql = "SELECT t.*, u.usernameValue AS sellerUsername " +
                    "FROM tops t " +
                    "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                    "WHERE t.topIdValue != ? AND t.isActiveValue = TRUE " +
                    "AND t.auctionCloseDateValue >= ? " +
                    "AND (t.genderValue = ? OR t.sizeValue = ? OR t.colorValue = ? OR t.conditionValue = ?) " +
                    "ORDER BY " +
                    "CASE WHEN t.genderValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN t.sizeValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN t.colorValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN t.conditionValue = ? THEN 1 ELSE 2 END " +
                    "LIMIT 10";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, excludeId);
            ps.setString(2, oneMonthAgoStr);
            ps.setString(3, refGender);
            ps.setString(4, refSize);
            ps.setString(5, refColor);
            ps.setString(6, refCondition);
            ps.setString(7, refGender);
            ps.setString(8, refSize);
            ps.setString(9, refColor);
            ps.setString(10, refCondition);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

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


                int similarItemId = rs.getInt("topIdValue");
                String imagesJson = getItemImages(con, "tops", similarItemId);
                json.append("\"images\":").append(imagesJson).append(",");

                int buyerId = rs.getInt("buyerIdValue");
                json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
                json.append("}");
            }
        }
        return first;
    }

    private boolean findSimilarBottoms(Connection con, Integer currentUserId, String refGender, String refSize,
                                      String refColor, String refCondition, String oneMonthAgoStr, int excludeId,
                                      StringBuilder json, boolean first) throws Exception {
        String sql = "SELECT b.*, u.usernameValue AS sellerUsername " +
                    "FROM bottoms b " +
                    "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
                    "WHERE b.bottomIdValue != ? AND b.isActiveValue = TRUE " +
                    "AND b.auctionCloseDateValue >= ? " +
                    "AND (b.genderValue = ? OR b.sizeValue = ? OR b.colorValue = ? OR b.conditionValue = ?) " +
                    "ORDER BY " +
                    "CASE WHEN b.genderValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN b.sizeValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN b.colorValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN b.conditionValue = ? THEN 1 ELSE 2 END " +
                    "LIMIT 10";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, excludeId);
            ps.setString(2, oneMonthAgoStr);
            ps.setString(3, refGender);
            ps.setString(4, refSize);
            ps.setString(5, refColor);
            ps.setString(6, refCondition);
            ps.setString(7, refGender);
            ps.setString(8, refSize);
            ps.setString(9, refColor);
            ps.setString(10, refCondition);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

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
        }
        return first;
    }

    private boolean findSimilarShoes(Connection con, Integer currentUserId, String refGender, String refSize,
                                    String refColor, String refCondition, String oneMonthAgoStr, int excludeId,
                                    StringBuilder json, boolean first) throws Exception {
        String sql = "SELECT s.*, u.usernameValue AS sellerUsername " +
                    "FROM shoes s " +
                    "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                    "WHERE s.shoeIdValue != ? AND s.isActiveValue = TRUE " +
                    "AND s.auctionCloseDateValue >= ? " +
                    "AND (s.genderValue = ? OR s.sizeValue = ? OR s.colorValue = ? OR s.conditionValue = ?) " +
                    "ORDER BY " +
                    "CASE WHEN s.genderValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN s.sizeValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN s.colorValue = ? THEN 1 ELSE 2 END, " +
                    "CASE WHEN s.conditionValue = ? THEN 1 ELSE 2 END " +
                    "LIMIT 10";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, excludeId);
            ps.setString(2, oneMonthAgoStr);
            ps.setString(3, refGender);
            ps.setString(4, refSize);
            ps.setString(5, refColor);
            ps.setString(6, refCondition);
            ps.setString(7, refGender);
            ps.setString(8, refSize);
            ps.setString(9, refColor);
            ps.setString(10, refCondition);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

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


                int similarItemId = rs.getInt("shoeIdValue");
                String imagesJson = getItemImages(con, "shoes", similarItemId);
                json.append("\"images\":").append(imagesJson).append(",");

                int buyerId = rs.getInt("buyerIdValue");
                json.append("\"buyerId\":").append(rs.wasNull() ? "null" : String.valueOf(buyerId));
                json.append("}");
            }
        }
        return first;
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

