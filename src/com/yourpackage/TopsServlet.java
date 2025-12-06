package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/tops")
@MultipartConfig
public class TopsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException(e);
        }

        String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
        String dbUser = "root";
        String dbPass = "12345";

        // target images folder inside webapp
        String imagesDir = getServletContext().getRealPath("/Images");
        File imagesFolder = new File(imagesDir);
        if (!imagesFolder.exists()) imagesFolder.mkdirs();

        try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
            String gender = request.getParameter("topGender");
            if (gender != null) {
                Integer userIdValue = (Integer) request.getSession().getAttribute("userIdValue");
                if (userIdValue == null) userIdValue = 0;

                String size = request.getParameter("topSize");
                String color = request.getParameter("topColor");
                float frontlength = 0f;
                float chestlength = 0f;
                float sleevelength = 0f;
                try { frontlength = Float.parseFloat(request.getParameter("FrontLength")); } catch(Exception ignore){}
                try { chestlength = Float.parseFloat(request.getParameter("ChestLength")); } catch(Exception ignore){}
                try { sleevelength = Float.parseFloat(request.getParameter("SleeveLength")); } catch(Exception ignore){}
                String description = request.getParameter("Description");
                String condition = request.getParameter("Condition");
                String auctionclosedate = request.getParameter("AuctionCloseDateTops");
                String auctionclosetime = request.getParameter("AuctionCloseTimeTops");

                // handle file upload
                Part imagePart = null;
                try {
                    imagePart = request.getPart("image");
                } catch (Exception ignored) {}

                String savedFileName = null;
                if (imagePart != null && imagePart.getSize() > 0) {
                    String submittedName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
                    String uniqueName = System.currentTimeMillis() + "_" + submittedName;
                    File file = new File(imagesFolder, uniqueName);
                    try (InputStream in = imagePart.getInputStream()) {
                        Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
                    }
                    savedFileName = uniqueName;
                }

                String sql = "INSERT INTO tops (auctionSellerIdValue, genderValue, sizeValue, colorValue, frontLengthValue, chestLengthValue, sleeveLengthValue, descriptionValue, conditionValue, auctionCloseDateValue, auctionCloseTimeValue, imagePathValue) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userIdValue);
                    ps.setString(2, gender);
                    ps.setString(3, size);
                    ps.setString(4, color);
                    ps.setFloat(5, frontlength);
                    ps.setFloat(6, chestlength);
                    ps.setFloat(7, sleevelength);
                    ps.setString(8, description);
                    ps.setString(9, condition);
                    ps.setString(10, auctionclosedate);
                    ps.setString(11, auctionclosetime);
                    ps.setString(12, savedFileName);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        // redirect back to the listing page
        response.sendRedirect(request.getContextPath() + "/WebsitePages/tops.jsp");
    }
}
