<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page import="java.time.LocalDate,java.time.LocalTime,java.time.LocalDateTime" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shoes - ThriftShop Auction</title>
    <link rel="stylesheet" href="../css/auction-style.css">
</head>
<body>
    <header class="header">
        <div class="header-container">
            <a href="mainPage.jsp" class="logo">🏛️ ThriftShop</a>
            <nav>
                <ul class="nav-menu">
                    <li><a href="tops.jsp">Tops</a></li>
                    <li><a href="bottoms.jsp">Bottoms</a></li>
                    <li><a href="shoes.jsp">Shoes</a></li>
                    <li><a href="sellers.jsp">Sellers</a></li>
                    <li><a href="notifications.jsp">Notifications</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="../LoginPage/logout.jsp">Logout</a></li>
                </ul>
            </nav>
            <div class="user-info">👤 <%=session.getAttribute("username")%></div>
        </div>
    </header>
    <div class="container">

<%
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
    Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
    Statement st = con.createStatement();

    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }
%>
        <div class="page-header">
            <h1>👟 Shoes</h1>
            <p>Browse and bid on premium shoes</p>
            <a href="mainPage.jsp" class="btn btn-outline" style="margin-top: 1rem;">← Back to Main Page</a>
        </div>
<%

    String similarId = request.getParameter("similarId");
    String similarSize = request.getParameter("similarSize");
    String similarGender = request.getParameter("similarGender");
    String similarMinPrice = request.getParameter("similarMinPrice");
    String similarMaxPrice = request.getParameter("similarMaxPrice");

    boolean showingSimilar = (similarSize != null && !similarSize.isEmpty() &&
            similarGender != null && !similarGender.isEmpty());

    if (showingSimilar) {
        out.println("<p><strong>Showing Similar Shoes:</strong> Gender \"" + similarGender + "\" | Size \"" + similarSize + "\" | Price: $" + similarMinPrice + " - $" + similarMaxPrice);
        out.println("&nbsp;&nbsp;<a href='shoes.jsp'>Clear Filter</a></p>");
        out.println("<hr/>");
    }

    String gender = request.getParameter("shoeGender");
    if (gender != null) {

        String dateStr = request.getParameter("AuctionCloseDateShoes");
        String timeStr = request.getParameter("AuctionCloseTimeShoes");

        if (dateStr == null || timeStr == null ||
                dateStr.isEmpty() || timeStr.isEmpty()) {

            out.println("<p style='color:red'>Error. Auction close date or time is missing.</p>");
            out.println("<a href='../WebsitePages/mainPage.jsp'>Go back to Main Page</a>");
            st.close();
            con.close();
            return;
        }

        LocalDate closeDate = LocalDate.parse(dateStr);   // yyyy-MM-dd
        LocalTime closeTime = LocalTime.parse(timeStr);   // HH:mm
        LocalDateTime closeDateTime = LocalDateTime.of(closeDate, closeTime);
        LocalDateTime now = LocalDateTime.now();

        if (closeDateTime.isBefore(now)) {
            out.println("<p style='color:red'>Auction close date and time cannot be in the past.</p>");
            out.println("<a href='../WebsitePages/mainPage.jsp'>Go back to Main Page</a>");
            st.close();
            con.close();
            return;
        }

        Integer userIdValue = (Integer) session.getAttribute("userIdValue");
        String size        = request.getParameter("shoeSize");
        String color       = request.getParameter("shoeColor");
        String description = request.getParameter("Description");
        String condition   = request.getParameter("Condition");
        String minimum     = request.getParameter("Minimum");
        String startingorcurrentbidprice = request.getParameter("StartingOrCurrentBidPrice");

        String auctionDate = dateStr;
        String auctionTime = timeStr;

        if (minimum == null || minimum.isEmpty()) {
            minimum = "0.0";
        }


        if (startingorcurrentbidprice == null || startingorcurrentbidprice.isEmpty()) {
            startingorcurrentbidprice = minimum;
        }

        String insert =
                "INSERT INTO shoes " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " descriptionValue, conditionValue, minimumBidPriceValue, " +
                        " startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) " +
                        "VALUES ('" + userIdValue + "', '" + gender + "', '" + size + "', '" + color + "', " +
                        "'" + description + "', '" + condition + "', '" + minimum + "', " +
                        "'" + startingorcurrentbidprice + "', '" + auctionDate + "', '" + auctionTime + "')";

        st.executeUpdate(insert);
    }

    StringBuilder shoesQuery = new StringBuilder(
            "SELECT s.*, u.usernameValue AS sellerUsername " +
                    "FROM shoes s " +
                    "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                    "WHERE 1=1");

    if (showingSimilar) {
        if (similarGender != null && !similarGender.isEmpty()) {
            String safeGender = similarGender.replace("'", "''");
            shoesQuery.append(" AND s.genderValue = '").append(safeGender).append("'");
        }
        if (similarSize != null && !similarSize.isEmpty()) {
            String safeSize = similarSize.replace("'", "''");
            shoesQuery.append(" AND s.sizeValue = '").append(safeSize).append("'");
        }
        if (similarMinPrice != null && !similarMinPrice.isEmpty()) {
            shoesQuery.append(" AND s.minimumBidPriceValue >= ").append(similarMinPrice);
        }
        if (similarMaxPrice != null && !similarMaxPrice.isEmpty()) {
            shoesQuery.append(" AND s.minimumBidPriceValue <= ").append(similarMaxPrice);
        }
        if (similarId != null && !similarId.isEmpty()) {
            shoesQuery.append(" AND s.shoeIdValue != ").append(similarId);
        }
    }

    shoesQuery.append(" ORDER BY s.shoeIdValue DESC");

    ResultSet rs = st.executeQuery(shoesQuery.toString());
    boolean found = false;
    
    out.println("<div class='items-grid'>");

    while (rs.next()) {
        found = true;

        String sellerUsername  = rs.getString("sellerUsername");
        String shoeIdVal       = rs.getString("shoeIdValue");
        String genderVal       = rs.getString("genderValue");
        String sizeVal         = rs.getString("sizeValue");
        String colorVal        = rs.getString("colorValue");
        String descVal         = rs.getString("descriptionValue");
        String condVal         = rs.getString("conditionValue");
        float minBid           = rs.getFloat("minimumBidPriceValue");
        float startOrCurrent   = rs.getFloat("startingOrCurrentBidPriceValue");
        String auctionDateVal  = rs.getString("auctionCloseDateValue");
        String auctionTimeVal  = rs.getString("auctionCloseTimeValue");

        double simMinPrice = Math.round(minBid * 0.9 * 100.0) / 100.0;
        double simMaxPrice = Math.round(minBid * 1.1 * 100.0) / 100.0;

        Integer currentUserId = (Integer) session.getAttribute("userIdValue");
        String sellerIdStr = rs.getString("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && sellerIdStr != null && 
                           currentUserId.toString().equals(sellerIdStr));

        out.println("<div class='item-card'>");
        out.println("<div class='item-image'>👟</div>");
        out.println("<div class='item-body'>");
        out.println("<div class='item-title'>" + (descVal != null && !descVal.isEmpty() ? descVal : "Shoe #" + shoeIdVal) + "</div>");
        out.println("<div class='item-meta'>");
        out.println("<span>👤 Seller: " + sellerUsername + "</span> | ");
        out.println("<span>" + genderVal + "</span> | ");
        out.println("<span>Size: " + sizeVal + "</span> | ");
        out.println("<span>Color: " + colorVal + "</span>");
        out.println("</div>");
        
        out.println("<p style='margin: 0.5rem 0;'><strong>📝 Description:</strong> " + descVal + "</p>");
        out.println("<p style='margin: 0.5rem 0;'><strong>✨ Condition:</strong> " + condVal + "</p>");
        
        if (isSeller) {
            if (minBid != 0.0f) {
                out.println("<div class='reserve-badge' style='display: inline-block; margin: 0.5rem 0;'>🔒 Reserve: $" + minBid + " (Hidden)</div>");
            } else {
                out.println("<div class='reserve-badge' style='display: inline-block; margin: 0.5rem 0;'>No Reserve</div>");
            }
        }
        
        out.println("<div class='item-price'>Current Bid: $" + String.format("%.2f", startOrCurrent) + "</div>");
        out.println("<p style='color: var(--text-secondary); font-size: 0.9rem;'><strong>⏰ Closes:</strong> " + auctionDateVal + " at " + auctionTimeVal + "</p>");
        out.println("</div>");
        
        out.println("<div class='item-footer'>");
        out.println("<form method='get' action='shoes.jsp' style='display:inline;'>");
        out.println("<input type='hidden' name='similarId' value='" + shoeIdVal + "'>");
        out.println("<input type='hidden' name='similarSize' value='" + (sizeVal != null ? sizeVal : "") + "'>");
        out.println("<input type='hidden' name='similarGender' value='" + (genderVal != null ? genderVal : "") + "'>");
        out.println("<input type='hidden' name='similarMinPrice' value='" + simMinPrice + "'>");
        out.println("<input type='hidden' name='similarMaxPrice' value='" + simMaxPrice + "'>");
        out.println("<button type='submit' class='btn btn-outline' style='font-size: 0.9rem; padding: 0.5rem 1rem;'>🔍 Show Similars</button>");
        out.println("</form>");
        out.println("</div>");
        out.println("</div>");
    }

    if (!found) {
        out.println("</div>");
        out.println("<div class='card'>");
        out.println("<p style='text-align: center; color: var(--text-secondary); font-size: 1.1rem;'>No shoes found matching your criteria.</p>");
        out.println("</div>");
    } else {
        out.println("</div>");
    }

    rs.close();
    st.close();
    con.close();
%>
    </div>
</body>
</html>
