package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/api/auctions/*")
@MultipartConfig
public class CreateAuctionApiServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");


        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userIdValue") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Not logged in\"}");
                return;
            }

            Integer userIdValue = (Integer) session.getAttribute("userIdValue");
            String pathInfo = request.getPathInfo();
            String itemType = pathInfo != null && pathInfo.length() > 1 ? pathInfo.substring(1) : "";

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

            String imagesDir = getServletContext().getRealPath("/Images");
            File imagesFolder = new File(imagesDir);
            if (!imagesFolder.exists()) imagesFolder.mkdirs();

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                if ("tops".equals(itemType)) {
                    createTopAuction(request, con, userIdValue, imagesFolder, out);
                } else if ("bottoms".equals(itemType)) {
                    createBottomAuction(request, con, userIdValue, imagesFolder, out);
                } else if ("shoes".equals(itemType)) {
                    createShoeAuction(request, con, userIdValue, imagesFolder, out);
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Invalid item type\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorMsg = escapeJson(e.getMessage());
            if (errorMsg == null || errorMsg.isEmpty()) {
                errorMsg = "Unknown error occurred: " + e.getClass().getSimpleName();
            }
            out.print("{\"success\": false, \"message\": \"" + errorMsg + "\"}");
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

    private void createTopAuction(HttpServletRequest request, Connection con,
                                 Integer userIdValue, File imagesFolder, PrintWriter out)
            throws Exception {
        String gender = request.getParameter("gender");
        String size = request.getParameter("size");
        String color = request.getParameter("color");
        float frontLength = parseFloat(request.getParameter("frontLength"), 0f);
        float chestLength = parseFloat(request.getParameter("chestLength"), 0f);
        float sleeveLength = parseFloat(request.getParameter("sleeveLength"), 0f);
        String description = request.getParameter("description");
        String condition = request.getParameter("condition");
        float minimumBidPrice = parseFloat(request.getParameter("minimumBidPrice"), 0f);
        float startingBidPrice = parseFloat(request.getParameter("startingBidPrice"), minimumBidPrice);
        String closeDate = request.getParameter("closeDate");
        String closeTime = request.getParameter("closeTime");


        String savedFileName = handleImageUpload(request, imagesFolder, "image");

        String sql = "INSERT INTO tops (auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                    "frontLengthValue, chestLengthValue, sleeveLengthValue, descriptionValue, " +
                    "conditionValue, minimumBidPriceValue, startingOrCurrentBidPriceValue, " +
                    "auctionCloseDateValue, auctionCloseTimeValue, imagePathValue) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int topId = 0;
        try (PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userIdValue);
            ps.setString(2, gender);
            ps.setString(3, size);
            ps.setString(4, color);
            ps.setFloat(5, frontLength);
            ps.setFloat(6, chestLength);
            ps.setFloat(7, sleeveLength);
            ps.setString(8, description);
            ps.setString(9, condition);
            ps.setFloat(10, minimumBidPrice);
            ps.setFloat(11, startingBidPrice);
            ps.setString(12, closeDate);
            ps.setString(13, closeTime);
            ps.setString(14, savedFileName);
            ps.executeUpdate();


            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    topId = rs.getInt(1);
                }
            }
        }


        handleMultipleImages(request, imagesFolder, con, "tops", topId);


        checkAndNotifyAlerts(con, "top", topId, gender, size, color);

        out.print("{\"success\": true, \"message\": \"Auction created successfully\"}");
    }

    private void createBottomAuction(HttpServletRequest request, Connection con,
                                    Integer userIdValue, File imagesFolder, PrintWriter out)
            throws Exception {
        String gender = request.getParameter("gender");
        String size = request.getParameter("size");
        String color = request.getParameter("color");
        String waistLength = request.getParameter("waistLength");
        String inseamLength = request.getParameter("inseamLength");
        String outseamLength = request.getParameter("outseamLength");
        String hipLength = request.getParameter("hipLength");
        String riseLength = request.getParameter("riseLength");
        String description = request.getParameter("description");
        String condition = request.getParameter("condition");
        float minimumBidPrice = parseFloat(request.getParameter("minimumBidPrice"), 0f);
        float startingBidPrice = parseFloat(request.getParameter("startingBidPrice"), minimumBidPrice);
        String closeDate = request.getParameter("closeDate");
        String closeTime = request.getParameter("closeTime");


        String savedFileName = handleImageUpload(request, imagesFolder, "image");

        String sql = "INSERT INTO bottoms (auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                    "waistLengthValue, inseamLengthValue, outseamLengthValue, hipLengthValue, " +
                    "riseLengthValue, descriptionValue, conditionValue, minimumBidPriceValue, " +
                    "startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue, imagePathValue) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int bottomId = 0;
        try (PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userIdValue);
            ps.setString(2, gender);
            ps.setString(3, size);
            ps.setString(4, color);
            ps.setString(5, waistLength);
            ps.setString(6, inseamLength);
            ps.setString(7, outseamLength);
            ps.setString(8, hipLength);
            ps.setString(9, riseLength);
            ps.setString(10, description);
            ps.setString(11, condition);
            ps.setFloat(12, minimumBidPrice);
            ps.setFloat(13, startingBidPrice);
            ps.setString(14, closeDate);
            ps.setString(15, closeTime);
            ps.setString(16, savedFileName);
            ps.executeUpdate();


            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    bottomId = rs.getInt(1);
                }
            }
        }


        handleMultipleImages(request, imagesFolder, con, "bottoms", bottomId);


        checkAndNotifyAlerts(con, "bottom", bottomId, gender, size, color);

        out.print("{\"success\": true, \"message\": \"Auction created successfully\"}");
    }

    private void createShoeAuction(HttpServletRequest request, Connection con,
                                  Integer userIdValue, File imagesFolder, PrintWriter out)
            throws Exception {
        String gender = request.getParameter("gender");
        String size = request.getParameter("size");
        String color = request.getParameter("color");
        String description = request.getParameter("description");
        String condition = request.getParameter("condition");
        float minimumBidPrice = parseFloat(request.getParameter("minimumBidPrice"), 0f);
        float startingBidPrice = parseFloat(request.getParameter("startingBidPrice"), minimumBidPrice);
        String closeDate = request.getParameter("closeDate");
        String closeTime = request.getParameter("closeTime");


        String savedFileName = handleImageUpload(request, imagesFolder, "image");

        String sql = "INSERT INTO shoes (auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                    "descriptionValue, conditionValue, minimumBidPriceValue, " +
                    "startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue, imagePathValue) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int shoeId = 0;
        try (PreparedStatement ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userIdValue);
            ps.setString(2, gender);
            ps.setString(3, size);
            ps.setString(4, color);
            ps.setString(5, description);
            ps.setString(6, condition);
            ps.setFloat(7, minimumBidPrice);
            ps.setFloat(8, startingBidPrice);
            ps.setString(9, closeDate);
            ps.setString(10, closeTime);
            ps.setString(11, savedFileName);
            ps.executeUpdate();


            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    shoeId = rs.getInt(1);
                }
            }
        }


        handleMultipleImages(request, imagesFolder, con, "shoes", shoeId);


        checkAndNotifyAlerts(con, "shoe", shoeId, gender, size, color);

        out.print("{\"success\": true, \"message\": \"Auction created successfully\"}");
    }

    private float parseFloat(String value, float defaultValue) {
        if (value == null || value.isEmpty()) return defaultValue;
        try {
            return Float.parseFloat(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String handleImageUpload(HttpServletRequest request, File imagesFolder, String paramName)
            throws Exception {
        try {
            Part imagePart = request.getPart(paramName);
            if (imagePart != null && imagePart.getSize() > 0) {
                String submittedName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
                String uniqueName = System.currentTimeMillis() + "_" + submittedName;
                File file = new File(imagesFolder, uniqueName);
                try (InputStream in = imagePart.getInputStream()) {
                    Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                return uniqueName;
            }
        } catch (Exception ignored) {}
        return null;
    }

    private void handleMultipleImages(HttpServletRequest request, File imagesFolder, Connection con,
                                     String itemType, int itemId) throws Exception {

        String createTableSql = "CREATE TABLE IF NOT EXISTS item_images (" +
                               "imageIdValue INT AUTO_INCREMENT PRIMARY KEY, " +
                               "itemTypeValue VARCHAR(20) NOT NULL, " +
                               "itemIdValue INT NOT NULL, " +
                               "imagePathValue VARCHAR(250) NOT NULL, " +
                               "displayOrderValue INT DEFAULT 0, " +
                               "createdAtValue TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                               "INDEX idx_item (itemTypeValue, itemIdValue)) " +
                               "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci";
        try (PreparedStatement ps = con.prepareStatement(createTableSql)) {
            ps.execute();
        } catch (Exception e) {

        }


        java.util.List<Part> imageParts = new java.util.ArrayList<>();
        try {
            for (Part part : request.getParts()) {
                if ("images".equals(part.getName()) && part.getSize() > 0) {
                    imageParts.add(part);
                }
            }
        } catch (Exception e) {

        }


        int displayOrder = 0;
        for (Part imagePart : imageParts) {
            String submittedName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
            String uniqueName = System.currentTimeMillis() + "_" + displayOrder + "_" + submittedName;
            File file = new File(imagesFolder, uniqueName);

            try (InputStream in = imagePart.getInputStream()) {
                Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }


            String insertSql = "INSERT INTO item_images (itemTypeValue, itemIdValue, imagePathValue, displayOrderValue) " +
                              "VALUES (?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setString(1, itemType);
                ps.setInt(2, itemId);
                ps.setString(3, uniqueName);
                ps.setInt(4, displayOrder);
                ps.executeUpdate();
            }

            displayOrder++;
        }
    }

    private void checkAndNotifyAlerts(Connection con, String itemType, int itemId,
                                     String gender, String size, String color) {
        try {


            String sql = "SELECT DISTINCT ap.userIdValue, u.usernameValue " +
                        "FROM alert_preferences ap " +
                        "JOIN users u ON ap.userIdValue = u.userIdValue " +
                        "WHERE ap.itemTypeValue = ? " +
                        "AND (ap.genderValue IS NULL OR ap.genderValue = '' OR ap.genderValue = ?) " +
                        "AND (ap.sizeValue IS NULL OR ap.sizeValue = '' OR ap.sizeValue = ?) " +
                        "AND (ap.colorValue IS NULL OR ap.colorValue = '' OR ap.colorValue = ?)";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, itemType);
                ps.setString(2, gender != null ? gender : "");
                ps.setString(3, size != null ? size : "");
                ps.setString(4, color != null ? color : "");

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int userId = rs.getInt("userIdValue");


                    createAlertNotification(con, userId, itemId, itemType,
                                         "New item matching your alert preferences! " +
                                         "A " + itemType + " has been listed. Check it out!");
                }
            }
        } catch (Exception e) {

            System.err.println("Error checking alert preferences: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void createAlertNotification(Connection con, int userId, int itemId, String itemType, String message) {
        try {

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
        } catch (Exception e) {
            System.err.println("Error creating alert notification: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

