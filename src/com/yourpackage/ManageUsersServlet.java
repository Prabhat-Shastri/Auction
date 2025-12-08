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

@WebServlet("/api/customer-rep/users")
public class ManageUsersServlet extends HttpServlet {

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
        Integer role = (session != null) ? (Integer) session.getAttribute("roleValue") : null;
        PrintWriter out = response.getWriter();

        if (role == null || role != 2) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\": false, \"message\": \"Access denied. Customer Representative access required.\"}");
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

                String sql = "SELECT userIdValue, usernameValue, roleValue FROM users WHERE roleValue = 1 ORDER BY userIdValue DESC";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ResultSet rs = ps.executeQuery();

                    StringBuilder json = new StringBuilder("[");
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        json.append("{");
                        json.append("\"userId\":").append(rs.getInt("userIdValue")).append(",");
                        json.append("\"username\":\"").append(escapeJson(rs.getString("usernameValue"))).append("\",");
                        json.append("\"role\":").append(rs.getInt("roleValue"));
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
        Integer role = (session != null) ? (Integer) session.getAttribute("roleValue") : null;
        PrintWriter out = response.getWriter();

        if (role == null || role != 2) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"success\": false, \"message\": \"Access denied. Customer Representative access required.\"}");
            return;
        }

        Integer userId = null;
        String newPassword = null;
        String action = null;

        String contentType = request.getHeader("Content-Type");
        if (contentType != null && contentType.contains("application/json")) {
            try (BufferedReader reader = request.getReader()) {
                String body = reader.lines().collect(Collectors.joining(System.lineSeparator()));

                if (body.contains("\"userId\"")) {
                    String userIdStr = extractJsonValue(body, "userId");
                    if (userIdStr != null && !userIdStr.isEmpty()) {
                        try {
                            userId = Integer.parseInt(userIdStr);
                        } catch (NumberFormatException e) {

                        }
                    }
                }
                if (body.contains("\"newPassword\"")) {
                    newPassword = extractJsonValue(body, "newPassword");
                }
                if (body.contains("\"action\"")) {
                    action = extractJsonValue(body, "action");
                }
            } catch (Exception e) {
                System.err.println("Error parsing JSON: " + e.getMessage());
            }
        }


        if (userId == null && request.getParameter("userId") != null) {
            try {
                userId = Integer.parseInt(request.getParameter("userId"));
            } catch (NumberFormatException e) {

            }
        }
        if (newPassword == null) newPassword = request.getParameter("newPassword");
        if (action == null) action = request.getParameter("action");

        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"userId is required\"}");
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

                String checkRoleSql = "SELECT roleValue FROM users WHERE userIdValue = ?";
                int userRole = -1;
                try (PreparedStatement checkPs = con.prepareStatement(checkRoleSql)) {
                    checkPs.setInt(1, userId);
                    ResultSet rs = checkPs.executeQuery();
                    if (rs.next()) {
                        userRole = rs.getInt("roleValue");
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.print("{\"success\": false, \"message\": \"User not found\"}");
                        return;
                    }
                }


                if (userRole != 1) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"success\": false, \"message\": \"Cannot edit or delete customer representatives or admins\"}");
                    return;
                }

                if ("delete".equalsIgnoreCase(action)) {


                    String deleteSql = "DELETE FROM users WHERE userIdValue = ? AND roleValue = 1";
                    try (PreparedStatement ps = con.prepareStatement(deleteSql)) {
                        ps.setInt(1, userId);
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"User deleted successfully\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"User not found or cannot be deleted\"}");
                        }
                    }
                } else if (newPassword != null && !newPassword.trim().isEmpty()) {

                    String updateSql = "UPDATE users SET passwordValue = ? WHERE userIdValue = ? AND roleValue = 1";
                    try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                        ps.setString(1, newPassword);
                        ps.setInt(2, userId);
                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"Password updated successfully\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"User not found or cannot be updated\"}");
                        }
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

