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

@WebServlet("/api/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {


        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type");
        response.setHeader("Access-Control-Allow-Credentials", "true");


        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {

            String username = request.getParameter("username");
            String password = request.getParameter("password");

            System.out.println("LoginServlet: Received username=" + username + ", password=" + (password != null ? "***" : "null"));


            if (username == null || password == null) {
                System.out.println("LoginServlet: Parameters not found in request, reading from body...");
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

                }
            }

            if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
                out.print("{\"success\": false, \"message\": \"Username and password are required\"}");
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

            System.out.println("LoginServlet: Connecting to database: " + jdbcUrl);
            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                System.out.println("LoginServlet: Database connection successful");


                try {
                    String alterSql = "ALTER TABLE users ADD COLUMN roleValue INT DEFAULT 1";
                    try (PreparedStatement alterPs = con.prepareStatement(alterSql)) {
                        alterPs.execute();
                    }
                } catch (Exception e) {

                }


                String sql = "SELECT userIdValue, usernameValue, roleValue FROM users WHERE usernameValue = ? AND passwordValue = ?";
                System.out.println("LoginServlet: Executing query for username: " + username);
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, password);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {

                        int userId = rs.getInt("userIdValue");
                        int role = rs.getInt("roleValue");


                        if (role == 3) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            out.print("{\"success\": false, \"message\": \"Please use admin login page\"}");
                            return;
                        }
                        if (role == 2) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            out.print("{\"success\": false, \"message\": \"Please use customer representative login page\"}");
                            return;
                        }

                        System.out.println("LoginServlet: Login successful for user: " + username + ", userId: " + userId);

                        HttpSession session = request.getSession();
                        session.setAttribute("username", username);
                        session.setAttribute("userId", userId);
                        session.setAttribute("userIdValue", userId);
                        session.setAttribute("roleValue", role);


                        String safeUsername = username.replace("\"", "\\\"").replace("\\", "\\\\");
                        String jsonResponse = "{\"success\": true, \"username\": \"" + safeUsername + "\", \"userId\": " + userId + "}";
                        System.out.println("LoginServlet: Sending response: " + jsonResponse);
                        out.print(jsonResponse);
                    } else {

                        System.out.println("LoginServlet: Invalid credentials for username: " + username);
                        out.print("{\"success\": false, \"message\": \"Invalid username or password\"}");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage();
            if (errorMsg == null) errorMsg = "Unknown error";

            errorMsg = errorMsg.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
            out.print("{\"success\": false, \"message\": \"Server error: " + errorMsg + "\"}");
        }
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
            return null;
        }
    }
}

