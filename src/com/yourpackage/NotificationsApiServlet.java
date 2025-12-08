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

@WebServlet("/api/notifications")
public class NotificationsApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userIdValue") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Not logged in\"}");
                return;
            }

            Integer userIdValue = (Integer) session.getAttribute("userIdValue");

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

                String sql = "SELECT * FROM notifications WHERE userIdValue = ? " +
                           "ORDER BY createdAtValue DESC";

                StringBuilder json = new StringBuilder("[");
                boolean first = true;

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userIdValue);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;

                        json.append("{");
                        json.append("\"id\":").append(rs.getInt("notificationIdValue")).append(",");
                        json.append("\"itemId\":").append(rs.getInt("itemIdValue")).append(",");
                        json.append("\"itemType\":\"").append(escapeJson(rs.getString("itemTypeValue"))).append("\",");
                        json.append("\"message\":\"").append(escapeJson(rs.getString("messageValue"))).append("\",");
                        json.append("\"isRead\":").append(rs.getBoolean("isReadValue")).append(",");
                        json.append("\"createdAt\":\"").append(rs.getTimestamp("createdAtValue").toString()).append("\"");
                        json.append("}");
                    }
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userIdValue") == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Not logged in\"}");
                return;
            }

            String action = request.getParameter("action");
            String notificationId = request.getParameter("notificationId");

            if ("markRead".equals(action) && notificationId != null) {
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
                    String sql = "UPDATE notifications SET isReadValue = TRUE " +
                               "WHERE notificationIdValue = ?";
                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(notificationId));
                        ps.executeUpdate();
                    }
                    out.print("{\"success\": true}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
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

