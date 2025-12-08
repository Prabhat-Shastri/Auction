package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet({"/register", "/api/register"})
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");


        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");


        if (username == null || password == null) {
            try {
                StringBuilder sb = new StringBuilder();
                String line;
                java.io.BufferedReader reader = request.getReader();
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                String body = sb.toString();


                if (body.contains("username=") && body.contains("password=")) {
                    String[] pairs = body.split("&");
                    for (String pair : pairs) {
                        String[] keyValue = pair.split("=");
                        if (keyValue.length == 2) {
                            String key = java.net.URLDecoder.decode(keyValue[0], "UTF-8");
                            String value = java.net.URLDecoder.decode(keyValue[1], "UTF-8");
                            if ("username".equals(key)) username = value;
                            if ("password".equals(key)) password = value;
                        }
                    }
                } else if (body.contains("\"username\"") && body.contains("\"password\"")) {

                    username = extractJsonValue(body, "username");
                    password = extractJsonValue(body, "password");
                }
            } catch (Exception e) {
                System.err.println("RegisterServlet: Error parsing request body: " + e.getMessage());
            }
        }


        if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Username and password are required\"}");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException(e);
        }

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

            String checkSql = "SELECT userIdValue FROM users WHERE usernameValue = ?";
            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setString(1, username);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {

                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    response.getWriter().print("{\"success\": false, \"message\": \"Username already exists\"}");
                    return;
                }
            }


            try {
                String alterSql = "ALTER TABLE users ADD COLUMN roleValue INT DEFAULT 1";
                try (PreparedStatement alterPs = con.prepareStatement(alterSql)) {
                    alterPs.execute();
                }
            } catch (Exception e) {

            }


            String insertSql = "INSERT INTO users (usernameValue, passwordValue, roleValue) VALUES (?, ?, 1)";
            try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                insertPs.setString(1, username);
                insertPs.setString(2, password);
                insertPs.executeUpdate();
            }


            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().print("{\"success\": true, \"message\": \"Registration successful\"}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            String errorMsg = escapeJson(e.getMessage());
            if (errorMsg == null || errorMsg.isEmpty()) {
                errorMsg = "Unknown server error";
            }
            response.getWriter().print("{\"success\": false, \"message\": \"Server error during registration: " + errorMsg + "\"}");
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

    private String extractJsonValue(String json, String key) {
        try {
            int keyIndex = json.indexOf("\"" + key + "\"");
            if (keyIndex == -1) return null;
            int valueStart = json.indexOf(":", keyIndex) + 1;
            int quoteStart = json.indexOf("\"", valueStart);
            if (quoteStart == -1) return null;
            int quoteEnd = json.indexOf("\"", quoteStart + 1);
            if (quoteEnd == -1) return null;
            return json.substring(quoteStart + 1, quoteEnd);
        } catch (Exception e) {
            System.err.println("RegisterServlet: Error extracting JSON value for key '" + key + "': " + e.getMessage());
            return null;
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
