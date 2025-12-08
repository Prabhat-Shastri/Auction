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

@WebServlet("/api/admin/login")
public class AdminLoginServlet extends HttpServlet {
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

            String username = request.getParameter("username");
            String password = request.getParameter("password");


            if (username == null || password == null) {
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
                }
            }

            if (username == null || password == null || username.isEmpty() || password.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Username and password are required\"}");
                return;
            }

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {

                try {
                    String alterSql = "ALTER TABLE users ADD COLUMN roleValue INT DEFAULT 1";
                    try (PreparedStatement alterPs = con.prepareStatement(alterSql)) {
                        alterPs.execute();
                    }
                } catch (Exception e) {

                }


                String sql = "SELECT userIdValue, usernameValue, roleValue FROM users WHERE usernameValue = ? AND passwordValue = ?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, username);
                    ps.setString(2, password);
                    ResultSet rs = ps.executeQuery();

                    if (rs.next()) {
                        int role = rs.getInt("roleValue");
                        if (role != 3) {
                            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                            out.print("{\"success\": false, \"message\": \"Access denied. Admin access required.\"}");
                            return;
                        }

                        int userId = rs.getInt("userIdValue");


                        HttpSession session = request.getSession(true);
                        session.setAttribute("userIdValue", userId);
                        session.setAttribute("usernameValue", username);
                        session.setAttribute("roleValue", role);
                        session.setAttribute("isAdmin", true);



                        String contextPath = request.getContextPath();
                        if (contextPath == null || contextPath.isEmpty()) {
                            contextPath = "/ThriftShop";
                        }


                        jakarta.servlet.http.Cookie sessionCookie = new jakarta.servlet.http.Cookie("JSESSIONID", session.getId());
                        sessionCookie.setPath(contextPath);
                        sessionCookie.setHttpOnly(true);
                        sessionCookie.setMaxAge(-1);
                        sessionCookie.setSecure(false);
                        response.addCookie(sessionCookie);

                        System.out.println("AdminLoginServlet: Session created - userId=" + userId + ", role=" + role + ", sessionId=" + session.getId());

                        out.print("{\"success\": true, \"message\": \"Login successful\", \"username\": \"" +
                                 escapeJson(username) + "\", \"userId\": " + userId + ", \"role\": " + role + "}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        out.print("{\"success\": false, \"message\": \"Invalid username or password\"}");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Server error: " + escapeJson(e.getMessage()) + "\"}");
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

