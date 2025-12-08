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

@WebServlet("/api/search")
public class SearchApiServlet extends HttpServlet {
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
            if (itemType == null) itemType = "any";

            String sortBy = request.getParameter("sortBy");
            String sortOrder = request.getParameter("sortOrder");
            if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "asc";


            String gender = request.getParameter("gender");
            String size = request.getParameter("size");
            String color = request.getParameter("color");
            String description = request.getParameter("description");
            String condition = request.getParameter("condition");
            String minPrice = request.getParameter("minPrice");
            String maxPrice = request.getParameter("maxPrice");
            String seller = request.getParameter("seller");

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                StringBuilder json = new StringBuilder("[");

                if ("any".equals(itemType)) {

                    searchTops(con, currentUserId, gender, size, color, description, condition,
                             minPrice, maxPrice, seller, sortBy, sortOrder, json);
                    searchBottoms(con, currentUserId, gender, size, color, description, condition,
                                 minPrice, maxPrice, seller, sortBy, sortOrder, json);
                    searchShoes(con, currentUserId, gender, size, color, description, condition,
                               minPrice, maxPrice, seller, sortBy, sortOrder, json);
                } else if ("tops".equals(itemType)) {
                    searchTops(con, currentUserId, gender, size, color, description, condition,
                             minPrice, maxPrice, seller, sortBy, sortOrder, json);
                } else if ("bottoms".equals(itemType)) {
                    searchBottoms(con, currentUserId, gender, size, color, description, condition,
                                 minPrice, maxPrice, seller, sortBy, sortOrder, json);
                } else if ("shoes".equals(itemType)) {
                    searchShoes(con, currentUserId, gender, size, color, description, condition,
                               minPrice, maxPrice, seller, sortBy, sortOrder, json);
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

    private void searchTops(Connection con, Integer currentUserId, String gender, String size,
                           String color, String description, String condition, String minPrice,
                           String maxPrice, String seller, String sortBy, String sortOrder,
                           StringBuilder json) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT t.*, u.usernameValue AS sellerUsername " +
            "FROM tops t " +
            "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
            "WHERE t.isActiveValue = TRUE");

        if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
            sql.append(" AND t.genderValue = ?");
        }
        if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
            sql.append(" AND t.sizeValue = ?");
        }
        if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
            sql.append(" AND t.colorValue = ?");
        }
        if (description != null && !description.isEmpty()) {
            sql.append(" AND t.descriptionValue LIKE ?");
        }
        if (condition != null && !condition.isEmpty()) {
            sql.append(" AND t.conditionValue = ?");
        }
        if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND t.startingOrCurrentBidPriceValue >= ?");
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND t.startingOrCurrentBidPriceValue <= ?");
        }
        if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
            sql.append(" AND u.usernameValue = ?");
        }


        if (sortBy != null && !sortBy.isEmpty()) {
            if ("price".equals(sortBy)) {
                sql.append(" ORDER BY t.startingOrCurrentBidPriceValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("date".equals(sortBy)) {
                sql.append(" ORDER BY t.auctionCloseDateValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC").append(", t.auctionCloseTimeValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("type".equals(sortBy)) {
                sql.append(" ORDER BY t.descriptionValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else {
                sql.append(" ORDER BY t.startingOrCurrentBidPriceValue ASC");
            }
        } else {
            sql.append(" ORDER BY t.startingOrCurrentBidPriceValue ASC");
        }

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
                ps.setString(paramIndex++, gender);
            }
            if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
                ps.setString(paramIndex++, size);
            }
            if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
                ps.setString(paramIndex++, color);
            }
            if (description != null && !description.isEmpty()) {
                ps.setString(paramIndex++, "%" + description + "%");
            }
            if (condition != null && !condition.isEmpty()) {
                ps.setString(paramIndex++, condition);
            }
            if (minPrice != null && !minPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(minPrice));
            }
            if (maxPrice != null && !maxPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(maxPrice));
            }
            if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
                ps.setString(paramIndex++, seller);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                if (json.length() > 1) json.append(",");

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


                int itemId = rs.getInt("topIdValue");
                String imagesJson = getItemImages(con, "tops", itemId);
                json.append("\"images\":").append(imagesJson);
                json.append("}");
            }
        }
    }

    private void searchBottoms(Connection con, Integer currentUserId, String gender, String size,
                              String color, String description, String condition, String minPrice,
                              String maxPrice, String seller, String sortBy, String sortOrder,
                              StringBuilder json) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, u.usernameValue AS sellerUsername " +
            "FROM bottoms b " +
            "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
            "WHERE b.isActiveValue = TRUE");

        if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
            sql.append(" AND b.genderValue = ?");
        }
        if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
            sql.append(" AND b.sizeValue = ?");
        }
        if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
            sql.append(" AND b.colorValue = ?");
        }
        if (description != null && !description.isEmpty()) {
            sql.append(" AND b.descriptionValue LIKE ?");
        }
        if (condition != null && !condition.isEmpty()) {
            sql.append(" AND b.conditionValue = ?");
        }
        if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND b.startingOrCurrentBidPriceValue >= ?");
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND b.startingOrCurrentBidPriceValue <= ?");
        }
        if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
            sql.append(" AND u.usernameValue = ?");
        }


        if (sortBy != null && !sortBy.isEmpty()) {
            if ("price".equals(sortBy)) {
                sql.append(" ORDER BY b.startingOrCurrentBidPriceValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("date".equals(sortBy)) {
                sql.append(" ORDER BY b.auctionCloseDateValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC").append(", b.auctionCloseTimeValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("type".equals(sortBy)) {
                sql.append(" ORDER BY b.descriptionValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else {
                sql.append(" ORDER BY b.startingOrCurrentBidPriceValue ASC");
            }
        } else {
            sql.append(" ORDER BY b.startingOrCurrentBidPriceValue ASC");
        }

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
                ps.setString(paramIndex++, gender);
            }
            if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
                ps.setString(paramIndex++, size);
            }
            if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
                ps.setString(paramIndex++, color);
            }
            if (description != null && !description.isEmpty()) {
                ps.setString(paramIndex++, "%" + description + "%");
            }
            if (condition != null && !condition.isEmpty()) {
                ps.setString(paramIndex++, condition);
            }
            if (minPrice != null && !minPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(minPrice));
            }
            if (maxPrice != null && !maxPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(maxPrice));
            }
            if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
                ps.setString(paramIndex++, seller);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                if (json.length() > 1) json.append(",");

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


                int itemId = rs.getInt("bottomIdValue");
                String imagesJson = getItemImages(con, "bottoms", itemId);
                json.append("\"images\":").append(imagesJson);
                json.append("}");
            }
        }
    }

    private void searchShoes(Connection con, Integer currentUserId, String gender, String size,
                            String color, String description, String condition, String minPrice,
                            String maxPrice, String seller, String sortBy, String sortOrder,
                            StringBuilder json) throws Exception {
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, u.usernameValue AS sellerUsername " +
            "FROM shoes s " +
            "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
            "WHERE s.isActiveValue = TRUE");

        if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
            sql.append(" AND s.genderValue = ?");
        }
        if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
            sql.append(" AND s.sizeValue = ?");
        }
        if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
            sql.append(" AND s.colorValue = ?");
        }
        if (description != null && !description.isEmpty()) {
            sql.append(" AND s.descriptionValue LIKE ?");
        }
        if (condition != null && !condition.isEmpty()) {
            sql.append(" AND s.conditionValue = ?");
        }
        if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND s.startingOrCurrentBidPriceValue >= ?");
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND s.startingOrCurrentBidPriceValue <= ?");
        }
        if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
            sql.append(" AND u.usernameValue = ?");
        }


        if (sortBy != null && !sortBy.isEmpty()) {
            if ("price".equals(sortBy)) {
                sql.append(" ORDER BY s.startingOrCurrentBidPriceValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("date".equals(sortBy)) {
                sql.append(" ORDER BY s.auctionCloseDateValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC").append(", s.auctionCloseTimeValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else if ("type".equals(sortBy)) {
                sql.append(" ORDER BY s.descriptionValue ").append(sortOrder != null ? sortOrder.toUpperCase() : "ASC");
            } else {
                sql.append(" ORDER BY s.startingOrCurrentBidPriceValue ASC");
            }
        } else {
            sql.append(" ORDER BY s.startingOrCurrentBidPriceValue ASC");
        }

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (gender != null && !gender.isEmpty() && !"Any Gender".equalsIgnoreCase(gender)) {
                ps.setString(paramIndex++, gender);
            }
            if (size != null && !size.isEmpty() && !"Any Size".equalsIgnoreCase(size)) {
                ps.setString(paramIndex++, size);
            }
            if (color != null && !color.isEmpty() && !"Any Color".equalsIgnoreCase(color)) {
                ps.setString(paramIndex++, color);
            }
            if (description != null && !description.isEmpty()) {
                ps.setString(paramIndex++, "%" + description + "%");
            }
            if (condition != null && !condition.isEmpty()) {
                ps.setString(paramIndex++, condition);
            }
            if (minPrice != null && !minPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(minPrice));
            }
            if (maxPrice != null && !maxPrice.isEmpty()) {
                ps.setFloat(paramIndex++, Float.parseFloat(maxPrice));
            }
            if (seller != null && !seller.isEmpty() && !"Any Seller".equalsIgnoreCase(seller)) {
                ps.setString(paramIndex++, seller);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                if (json.length() > 1) json.append(",");

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


                int itemId = rs.getInt("shoeIdValue");
                String imagesJson = getItemImages(con, "shoes", itemId);
                json.append("\"images\":").append(imagesJson);
                json.append("}");
            }
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

                    if (imagesJson.length() > 1) imagesJson.append(",");
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

