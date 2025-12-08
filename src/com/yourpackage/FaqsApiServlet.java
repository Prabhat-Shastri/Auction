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
import java.sql.Timestamp;

@WebServlet("/api/faqs")
public class FaqsApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
            String searchQuery = request.getParameter("search");
            String unansweredOnly = request.getParameter("unansweredOnly");

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
                StringBuilder sql = new StringBuilder("SELECT f.faqIdValue, f.userIdValue, f.questionValue, f.answerValue, " +
                    "f.answeredByValue, f.answeredAtValue, f.createdAtValue, f.isAnsweredValue, " +
                    "u1.usernameValue as askerUsername, u2.usernameValue as answererUsername " +
                    "FROM faqs f " +
                    "LEFT JOIN users u1 ON f.userIdValue = u1.userIdValue " +
                    "LEFT JOIN users u2 ON f.answeredByValue = u2.userIdValue " +
                    "WHERE 1=1");

                if ("true".equals(unansweredOnly)) {
                    sql.append(" AND f.isAnsweredValue = FALSE");
                }

                if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                    sql.append(" AND (f.questionValue LIKE ? OR f.answerValue LIKE ?)");
                }

                sql.append(" ORDER BY f.createdAtValue DESC");

                try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                    int paramIndex = 1;
                    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                        String searchPattern = "%" + searchQuery + "%";
                        ps.setString(paramIndex++, searchPattern);
                        ps.setString(paramIndex++, searchPattern);
                    }

                    ResultSet rs = ps.executeQuery();
                    StringBuilder json = new StringBuilder("[");
                    boolean first = true;

                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;

                        json.append("{");
                        json.append("\"faqId\":").append(rs.getInt("faqIdValue")).append(",");
                        json.append("\"userId\":").append(rs.getInt("userIdValue")).append(",");
                        json.append("\"question\":\"").append(escapeJson(rs.getString("questionValue"))).append("\",");

                        String answer = rs.getString("answerValue");
                        if (answer != null) {
                            json.append("\"answer\":\"").append(escapeJson(answer)).append("\",");
                        } else {
                            json.append("\"answer\":null,");
                        }

                        int answeredBy = rs.getInt("answeredByValue");
                        if (!rs.wasNull()) {
                            json.append("\"answeredBy\":").append(answeredBy).append(",");
                        } else {
                            json.append("\"answeredBy\":null,");
                        }

                        Timestamp answeredAt = rs.getTimestamp("answeredAtValue");
                        if (answeredAt != null) {
                            json.append("\"answeredAt\":\"").append(answeredAt.toString()).append("\",");
                        } else {
                            json.append("\"answeredAt\":null,");
                        }

                        json.append("\"createdAt\":\"").append(rs.getTimestamp("createdAtValue").toString()).append("\",");
                        json.append("\"isAnswered\":").append(rs.getBoolean("isAnsweredValue")).append(",");
                        json.append("\"askerUsername\":\"").append(escapeJson(rs.getString("askerUsername"))).append("\",");

                        String answererUsername = rs.getString("answererUsername");
                        if (answererUsername != null) {
                            json.append("\"answererUsername\":\"").append(escapeJson(answererUsername)).append("\"");
                        } else {
                            json.append("\"answererUsername\":null");
                        }

                        json.append("}");
                    }

                    json.append("]");
                    out.print(json.toString());
                }
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
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        response.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.setHeader("Access-Control-Allow-Credentials", "true");

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userIdValue");
        if (userId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Not authenticated\"}");
            return;
        }

        try {

            StringBuilder requestBody = new StringBuilder();
            String line;
            java.io.BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                requestBody.append(line);
            }

            String body = requestBody.toString();
            String question = null;
            String answer = null;
            Integer faqId = null;


            question = request.getParameter("question");
            answer = request.getParameter("answer");
            if (request.getParameter("faqId") != null) {
                try {
                    faqId = Integer.parseInt(request.getParameter("faqId"));
                } catch (NumberFormatException e) {

                }
            }


            if ((question == null || answer == null) && body != null && !body.isEmpty()) {
                String[] pairs = body.split("&");
                for (String pair : pairs) {
                    String[] keyValue = pair.split("=", 2);
                    if (keyValue.length == 2) {
                        try {
                            String key = java.net.URLDecoder.decode(keyValue[0], "UTF-8");
                            String value = java.net.URLDecoder.decode(keyValue[1], "UTF-8");
                            if ("question".equals(key) && question == null) question = value;
                            if ("answer".equals(key) && answer == null) answer = value;
                            if ("faqId".equals(key) && faqId == null) {
                                try {
                                    faqId = Integer.parseInt(value);
                                } catch (NumberFormatException e) {

                                }
                            }
                        } catch (Exception e) {

                        }
                    }
                }
            }

            Integer role = (Integer) session.getAttribute("roleValue");

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
                if (answer != null && faqId != null) {

                    if (role == null || role != 2) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.print("{\"success\": false, \"message\": \"Only customer representatives can answer questions\"}");
                        return;
                    }

                    String updateSql = "UPDATE faqs SET answerValue = ?, answeredByValue = ?, answeredAtValue = CURRENT_TIMESTAMP, isAnsweredValue = TRUE WHERE faqIdValue = ?";
                    try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                        ps.setString(1, answer);
                        ps.setInt(2, userId);
                        ps.setInt(3, faqId);
                        int rows = ps.executeUpdate();

                        if (rows > 0) {
                            out.print("{\"success\": true, \"message\": \"Answer posted successfully\"}");
                        } else {
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            out.print("{\"success\": false, \"message\": \"FAQ not found\"}");
                        }
                    }
                } else if (question != null && !question.trim().isEmpty()) {

                    String insertSql = "INSERT INTO faqs (userIdValue, questionValue, isAnsweredValue) VALUES (?, ?, FALSE)";
                    try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                        ps.setInt(1, userId);
                        ps.setString(2, question);
                        ps.executeUpdate();

                        out.print("{\"success\": true, \"message\": \"Question posted successfully\"}");
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Question or answer required\"}");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
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

