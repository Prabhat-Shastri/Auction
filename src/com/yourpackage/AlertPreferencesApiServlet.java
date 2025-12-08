package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.stream.Collectors;

@WebServlet("/api/alert-preferences")
public class AlertPreferencesApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userIdValue") : null;
        PrintWriter out = response.getWriter();

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

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

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                String sql = "SELECT alertIdValue, itemTypeValue, colorValue, sizeValue, genderValue, createdAtValue " +
                           "FROM alert_preferences WHERE userIdValue = ? ORDER BY createdAtValue DESC";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ResultSet rs = ps.executeQuery();

                    StringBuilder json = new StringBuilder("[");
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"alertId\":").append(rs.getInt("alertIdValue")).append(",");
                        json.append("\"itemType\":\"").append(escapeJson(rs.getString("itemTypeValue"))).append("\",");
                        json.append("\"color\":\"").append(escapeJson(rs.getString("colorValue"))).append("\",");
                        json.append("\"size\":\"").append(escapeJson(rs.getString("sizeValue"))).append("\",");
                        json.append("\"gender\":\"").append(escapeJson(rs.getString("genderValue"))).append("\",");
                        json.append("\"createdAt\":\"").append(rs.getTimestamp("createdAtValue").toInstant().toString()).append("\"");
                        json.append("}");
                    }
                    json.append("]");
                    out.print(json.toString());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        HttpSession session = request.getSession(false);
        Integer userId = (session != null) ? (Integer) session.getAttribute("userIdValue") : null;
        PrintWriter out = response.getWriter();

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

        String itemType = null;
        String color = null;
        String size = null;
        String gender = null;
        Integer alertId = null;
        String action = null;

        String contentType = request.getHeader("Content-Type");
        if (contentType != null && contentType.contains("application/json")) {
            try (BufferedReader reader = request.getReader()) {
                String body = reader.lines().collect(Collectors.joining(System.lineSeparator()));

                if (body.contains("\"itemType\"")) {
                    itemType = extractJsonValue(body, "itemType");
                }
                if (body.contains("\"color\"")) {
                    color = extractJsonValue(body, "color");
                }
                if (body.contains("\"size\"")) {
                    size = extractJsonValue(body, "size");
                }
                if (body.contains("\"gender\"")) {
                    gender = extractJsonValue(body, "gender");
                }
                if (body.contains("\"alertId\"")) {
                    String alertIdStr = extractJsonValue(body, "alertId");
                    if (alertIdStr != null && !alertIdStr.isEmpty()) {
                        try {
                            alertId = Integer.parseInt(alertIdStr);
                        } catch (NumberFormatException e) {

                        }
                    }
                }
                if (body.contains("\"action\"")) {
                    action = extractJsonValue(body, "action");
                }
            } catch (Exception e) {
                System.err.println("Error parsing JSON: " + e.getMessage());
            }
        }


        if (itemType == null) itemType = request.getParameter("itemType");
        if (color == null) color = request.getParameter("color");
        if (size == null) size = request.getParameter("size");
        if (gender == null) gender = request.getParameter("gender");
        if (alertId == null && request.getParameter("alertId") != null) {
            try {
                alertId = Integer.parseInt(request.getParameter("alertId"));
            } catch (NumberFormatException e) {

            }
        }
        if (action == null) action = request.getParameter("action");

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

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                if ("delete".equalsIgnoreCase(action) && alertId != null) {

                    String deleteSql = "DELETE FROM alert_preferences WHERE alertIdValue = ? AND userIdValue = ?";
                    try (PreparedStatement ps = con.prepareStatement(deleteSql)) {
                        ps.setInt(1, alertId);
                        ps.setInt(2, userId);
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"Alert preference deleted\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"Alert preference not found\"}");
                        }
                    }
                } else if (itemType != null && !itemType.trim().isEmpty()) {

                    String insertSql = "INSERT INTO alert_preferences (userIdValue, itemTypeValue, colorValue, sizeValue, genderValue) " +
                                     "VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                        ps.setInt(1, userId);
                        ps.setString(2, itemType);
                        ps.setString(3, color != null && !color.trim().isEmpty() ? color : null);
                        ps.setString(4, size != null && !size.trim().isEmpty() ? size : null);
                        ps.setString(5, gender != null && !gender.trim().isEmpty() ? gender : null);
                        ps.executeUpdate();
                        out.print("{\"success\": true, \"message\": \"Alert preference created\"}");
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Missing required parameters\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doPost(request, response);
    }

    @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setStatus(HttpServletResponse.SC_OK);
    }

    private String extractJsonValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\"";
            int keyIndex = json.indexOf(searchKey);
            if (keyIndex == -1) return null;

            int colonIndex = json.indexOf(":", keyIndex);
            if (colonIndex == -1) return null;

            int startIndex = colonIndex + 1;
            while (startIndex < json.length() && (json.charAt(startIndex) == ' ' || json.charAt(startIndex) == '\t')) {
                startIndex++;
            }

            if (startIndex >= json.length()) return null;

            if (json.charAt(startIndex) == '"') {

                startIndex++;
                int endIndex = json.indexOf("\"", startIndex);
                if (endIndex == -1) return null;
                return json.substring(startIndex, endIndex);
            } else {

                int endIndex = startIndex;
                while (endIndex < json.length() &&
                       json.charAt(endIndex) != ',' &&
                       json.charAt(endIndex) != '}' &&
                       json.charAt(endIndex) != ' ' &&
                       json.charAt(endIndex) != '\n' &&
                       json.charAt(endIndex) != '\r') {
                    endIndex++;
                }
                String value = json.substring(startIndex, endIndex).trim();
                return value.isEmpty() ? null : value;
            }
        } catch (Exception e) {
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

