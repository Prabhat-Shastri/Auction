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

@WebServlet("/api/admin/sales-report")
public class SalesReportApiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
            System.out.println("SalesReportApiServlet: Session check - session=" + session);


            jakarta.servlet.http.Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                System.out.println("SalesReportApiServlet: Request cookies count: " + cookies.length);
                for (jakarta.servlet.http.Cookie cookie : cookies) {
                    System.out.println("SalesReportApiServlet: Cookie - " + cookie.getName() + " = " + cookie.getValue() + ", Path: " + cookie.getPath());
                }
            } else {
                System.out.println("SalesReportApiServlet: No cookies in request");
            }

            if (session == null) {
                System.out.println("SalesReportApiServlet: No session found");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Not authenticated - please login again\"}");
                return;
            }

            Integer role = (Integer) session.getAttribute("roleValue");
            Integer userId = (Integer) session.getAttribute("userIdValue");
            String username = (String) session.getAttribute("usernameValue");
            System.out.println("SalesReportApiServlet: userId=" + userId + ", role=" + role + ", username=" + username);
            System.out.println("SalesReportApiServlet: All session attributes: " + getSessionAttributes(session));

            if (role == null || role != 3) {
                System.out.println("SalesReportApiServlet: Not admin - role=" + role);
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\": \"Admin access required. Please login as admin.\"}");
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


            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            System.out.println("SalesReportApiServlet: Date range - startDate=" + startDate + ", endDate=" + endDate);

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
                StringBuilder json = new StringBuilder("{");


                float totalEarnings = getTotalEarnings(con, startDate, endDate);
                json.append("\"totalEarnings\":").append(totalEarnings).append(",");


                json.append("\"earningsPerItem\":[");
                json.append(getEarningsPerItem(con, startDate, endDate));
                json.append("],");


                json.append("\"earningsPerItemType\":[");
                json.append(getEarningsPerItemType(con, startDate, endDate));
                json.append("],");


                json.append("\"earningsPerEndUser\":[");
                json.append(getEarningsPerEndUser(con, startDate, endDate));
                json.append("],");


                json.append("\"bestSellingItems\":[");
                json.append(getBestSellingItems(con, startDate, endDate));
                json.append("],");


                json.append("\"bestBuyers\":[");
                json.append(getBestBuyers(con, startDate, endDate));
                json.append("]");

                json.append("}");
                String jsonString = json.toString();
                System.out.println("SalesReportApiServlet: Generated JSON length: " + jsonString.length());
                if (jsonString.length() > 353) {
                    System.out.println("SalesReportApiServlet: JSON around position 353: " +
                        jsonString.substring(Math.max(0, 353-50), Math.min(jsonString.length(), 353+50)));
                }
                out.print(jsonString);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private float getTotalEarnings(Connection con, String startDate, String endDate) throws Exception {

        StringBuilder sql = new StringBuilder("SELECT SUM(at.finalPriceValue) FROM auction_transactions at " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getFloat(1);
            }
        }
        return 0f;
    }

    private String getEarningsPerItem(Connection con, String startDate, String endDate) throws Exception {
        StringBuilder json = new StringBuilder();
        boolean first = true;


        StringBuilder sql = new StringBuilder("SELECT at.itemIdValue, at.itemTypeValue, at.finalPriceValue, at.buyerIdValue, " +
                    "COALESCE(t.descriptionValue, b.descriptionValue, s.descriptionValue) as description " +
                    "FROM auction_transactions at " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        sql.append(" ORDER BY at.finalPriceValue DESC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;

                json.append("{");
                json.append("\"itemId\":").append(rs.getInt("itemIdValue")).append(",");
                String desc = rs.getString("description");
                json.append("\"description\":\"").append(escapeJson(desc != null ? desc : "")).append("\",");
                json.append("\"earnings\":").append(rs.getFloat("finalPriceValue")).append(",");
                json.append("\"buyerId\":").append(rs.getInt("buyerIdValue")).append(",");
                String itemType = rs.getString("itemTypeValue");
                json.append("\"itemType\":\"").append(itemType != null ? itemType : "").append("\"");
                json.append("}");
            }
        }

        return json.toString();
    }

    private String getEarningsPerItemType(Connection con, String startDate, String endDate) throws Exception {
        StringBuilder json = new StringBuilder();
        boolean first = true;


        StringBuilder sql = new StringBuilder("SELECT at.itemTypeValue, SUM(at.finalPriceValue) as totalEarnings " +
                    "FROM auction_transactions at " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        sql.append(" GROUP BY at.itemTypeValue");

        java.util.Map<String, Float> earningsMap = new java.util.HashMap<>();
        earningsMap.put("top", 0f);
        earningsMap.put("bottom", 0f);
        earningsMap.put("shoe", 0f);

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String itemType = rs.getString("itemTypeValue");
                float earnings = rs.getFloat("totalEarnings");
                System.out.println("getEarningsPerItemType: Found itemType=" + itemType + ", earnings=" + earnings);
                earningsMap.put(itemType, earnings);
            }
        }

        System.out.println("getEarningsPerItemType: Final map - top=" + earningsMap.get("top") +
                          ", bottom=" + earningsMap.get("bottom") + ", shoe=" + earningsMap.get("shoe"));


        json.append("{\"itemType\":\"top\",\"totalEarnings\":").append(earningsMap.get("top")).append("}");
        json.append(",{\"itemType\":\"bottom\",\"totalEarnings\":").append(earningsMap.get("bottom")).append("}");
        json.append(",{\"itemType\":\"shoe\",\"totalEarnings\":").append(earningsMap.get("shoe")).append("}");

        String result = json.toString();
        System.out.println("getEarningsPerItemType: Returning JSON: " + result);
        return result;
    }

    private String getEarningsPerEndUser(Connection con, String startDate, String endDate) throws Exception {
        StringBuilder json = new StringBuilder();
        boolean first = true;


        StringBuilder sql = new StringBuilder("SELECT at.sellerIdValue, u.usernameValue, SUM(at.finalPriceValue) as totalEarnings " +
                    "FROM auction_transactions at " +
                    "INNER JOIN users u ON at.sellerIdValue = u.userIdValue " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        sql.append(" GROUP BY at.sellerIdValue, u.usernameValue ORDER BY totalEarnings DESC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{");
                json.append("\"userId\":").append(rs.getInt("sellerIdValue")).append(",");
                String username = rs.getString("usernameValue");
                json.append("\"username\":\"").append(escapeJson(username != null ? username : "")).append("\",");
                json.append("\"totalSpent\":").append(rs.getFloat("totalEarnings"));
                json.append("}");
            }
        }


        return json.toString();
    }

    private float getSellerTotalEarnings(Connection con, int sellerId) throws Exception {
        float total = 0f;


        String sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
                    "INNER JOIN tops t ON t.topIdValue = ib.itemIdValue AND ib.itemTypeValue = 'top' " +
                    "WHERE t.auctionSellerIdValue = ? AND t.buyerIdValue > 0 " +
                    "GROUP BY t.topIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }


        sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
             "INNER JOIN bottoms b ON b.bottomIdValue = ib.itemIdValue AND ib.itemTypeValue = 'bottom' " +
             "WHERE b.auctionSellerIdValue = ? AND b.buyerIdValue > 0 " +
             "GROUP BY b.bottomIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }


        sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
             "INNER JOIN shoes s ON s.shoeIdValue = ib.itemIdValue AND ib.itemTypeValue = 'shoe' " +
             "WHERE s.auctionSellerIdValue = ? AND s.buyerIdValue > 0 " +
             "GROUP BY s.shoeIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }

        return total;
    }

    private float getUserTotalSpent(Connection con, int userId) throws Exception {
        float total = 0f;


        String sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
                    "INNER JOIN tops t ON t.topIdValue = ib.itemIdValue AND ib.itemTypeValue = 'top' " +
                    "WHERE t.buyerIdValue = ? GROUP BY t.topIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }

        sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
             "INNER JOIN bottoms b ON b.bottomIdValue = ib.itemIdValue AND ib.itemTypeValue = 'bottom' " +
             "WHERE b.buyerIdValue = ? GROUP BY b.bottomIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }

        sql = "SELECT MAX(ib.newBidValue) FROM incrementbids ib " +
             "INNER JOIN shoes s ON s.shoeIdValue = ib.itemIdValue AND ib.itemTypeValue = 'shoe' " +
             "WHERE s.buyerIdValue = ? GROUP BY s.shoeIdValue";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                total += rs.getFloat(1);
            }
        }

        return total;
    }

    private String getBestSellingItems(Connection con, String startDate, String endDate) throws Exception {
        StringBuilder json = new StringBuilder();
        boolean first = true;


        StringBuilder sql = new StringBuilder("SELECT at.itemIdValue, at.itemTypeValue, at.finalPriceValue, " +
                    "COALESCE(t.descriptionValue, b.descriptionValue, s.descriptionValue) as description " +
                    "FROM auction_transactions at " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        sql.append(" ORDER BY at.finalPriceValue DESC LIMIT 10");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{");
                json.append("\"itemId\":").append(rs.getInt("itemIdValue")).append(",");
                String desc2 = rs.getString("description");
                json.append("\"description\":\"").append(escapeJson(desc2 != null ? desc2 : "")).append("\",");
                json.append("\"price\":").append(rs.getFloat("finalPriceValue")).append(",");
                json.append("\"itemType\":\"").append(rs.getString("itemTypeValue")).append("\"");
                json.append("}");
            }
        }

        return json.toString();
    }

    private void addItemsToList(Connection con, String sql, String itemType, java.util.List<java.util.Map<String, Object>> items) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> item = new java.util.HashMap<>();
                item.put("itemId", rs.getInt(1));
                item.put("description", rs.getString(2));
                item.put("price", rs.getFloat(3));
                item.put("itemType", itemType);
                items.add(item);
            }
        }
    }

    private void addBuyersToList(Connection con, String sql, java.util.List<java.util.Map<String, Object>> buyers) throws Exception {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String, Object> buyer = new java.util.HashMap<>();
                buyer.put("userId", rs.getInt("buyerIdValue"));
                buyer.put("username", rs.getString("usernameValue"));
                buyer.put("finalBid", rs.getFloat("finalBid"));
                buyers.add(buyer);
            }
        }
    }

    private String getBestBuyers(Connection con, String startDate, String endDate) throws Exception {

        StringBuilder json = new StringBuilder();
        boolean first = true;


        StringBuilder sql = new StringBuilder("SELECT at.buyerIdValue, u.usernameValue, MAX(at.finalPriceValue) as highestBid " +
                    "FROM auction_transactions at " +
                    "INNER JOIN users u ON at.buyerIdValue = u.userIdValue " +
                    "LEFT JOIN tops t ON at.itemTypeValue = 'top' AND at.itemIdValue = t.topIdValue " +
                    "LEFT JOIN bottoms b ON at.itemTypeValue = 'bottom' AND at.itemIdValue = b.bottomIdValue " +
                    "LEFT JOIN shoes s ON at.itemTypeValue = 'shoe' AND at.itemIdValue = s.shoeIdValue " +
                    "WHERE at.buyerIdValue > 0 " +
                    "AND (t.isActiveValue = TRUE OR b.isActiveValue = TRUE OR s.isActiveValue = TRUE)");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) >= ?");
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append(" AND DATE(at.transactionDateValue) <= ?");
        }

        sql.append(" GROUP BY at.buyerIdValue, u.usernameValue ORDER BY highestBid DESC LIMIT 10");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (startDate != null && !startDate.isEmpty()) {
                ps.setString(paramIndex++, startDate);
            }
            if (endDate != null && !endDate.isEmpty()) {
                ps.setString(paramIndex++, endDate);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                json.append("{");
                json.append("\"userId\":").append(rs.getInt("buyerIdValue")).append(",");
                json.append("\"username\":\"").append(escapeJson(rs.getString("usernameValue"))).append("\",");
                json.append("\"totalSpent\":").append(rs.getFloat("highestBid"));
                json.append("}");
            }
        }

        return json.toString();
    }

    private String getSessionAttributes(HttpSession session) {
        if (session == null) return "null";
        java.util.Enumeration<String> attrNames = session.getAttributeNames();
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        while (attrNames.hasMoreElements()) {
            if (!first) sb.append(", ");
            first = false;
            String name = attrNames.nextElement();
            Object value = session.getAttribute(name);
            sb.append(name).append("=").append(value);
        }
        sb.append("}");
        return sb.toString();
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
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
}

