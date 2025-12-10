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
    <title>Bottoms - ThriftShop Auction</title>
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
    // Load MySQL Driver
    Class.forName("com.mysql.cj.jdbc.Driver");

    // Connect to DB
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
            <h1>👖 Bottoms</h1>
            <p>Browse and bid on premium bottoms</p>
            <a href="mainPage.jsp" class="btn btn-outline" style="margin-top: 1rem;">← Back to Main Page</a>
        </div>
<%

    // Get Show Similars parameters
    String similarId = request.getParameter("similarId");
    String similarSize = request.getParameter("similarSize");
    String similarGender = request.getParameter("similarGender");
    String similarMinPrice = request.getParameter("similarMinPrice");
    String similarMaxPrice = request.getParameter("similarMaxPrice");

    boolean showingSimilar = (similarSize != null && !similarSize.isEmpty() &&
            similarGender != null && !similarGender.isEmpty());

    if (showingSimilar) {
        out.println("<p><strong>Showing Similar Bottoms:</strong> Gender \"" + similarGender + "\" | Size \"" + similarSize + "\" | Price: $" + similarMinPrice + " - $" + similarMaxPrice);
        out.println("&nbsp;&nbsp;<a href='bottoms.jsp'>Clear Filter</a></p>");
        out.println("<hr/>");
    }


    String gender = request.getParameter("bottomGender");
    if (gender != null) {


        String dateStr = request.getParameter("AuctionCloseDateBottoms");
        String timeStr = request.getParameter("AuctionCloseTimeBottoms");

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
        String size        = request.getParameter("bottomSize");
        String color       = request.getParameter("bottomColor");

        Float waistLength  = Float.parseFloat(request.getParameter("WaistLength"));
        Float inseamLength = Float.parseFloat(request.getParameter("InseamLength"));
        Float outseamLength= Float.parseFloat(request.getParameter("OutseamLength"));
        Float hipLength    = Float.parseFloat(request.getParameter("HipLength"));
        Float riseLength   = Float.parseFloat(request.getParameter("RiseLength"));

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
                "INSERT INTO bottoms " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " waistLengthValue, inseamLengthValue, outseamLengthValue, " +
                        " hipLengthValue, riseLengthValue, descriptionValue, conditionValue, " +
                        " minimumBidPriceValue, startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) VALUES (" +
                        "'" + userIdValue + "', '" + gender + "', '" + size + "', '" + color + "', " +
                        "'" + waistLength + "', '" + inseamLength + "', '" + outseamLength + "', " +
                        "'" + hipLength + "', '" + riseLength + "', '" + description + "', '" + condition + "', " +
                        "'" + minimum + "', '" + startingorcurrentbidprice + "', '" + auctionDate + "', '" + auctionTime + "')";

        st.executeUpdate(insert);
    }

    StringBuilder bottomsQuery = new StringBuilder(
            "SELECT b.*, u.usernameValue AS sellerUsername " +
                    "FROM bottoms b " +
                    "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
                    "WHERE 1=1");

    if (showingSimilar) {

        if (similarGender != null && !similarGender.isEmpty()) {
            String safeGender = similarGender.replace("'", "''");
            bottomsQuery.append(" AND b.genderValue = '").append(safeGender).append("'");
        }

        if (similarSize != null && !similarSize.isEmpty()) {
            String safeSize = similarSize.replace("'", "''");
            bottomsQuery.append(" AND b.sizeValue = '").append(safeSize).append("'");
        }
        if (similarMinPrice != null && !similarMinPrice.isEmpty()) {
            bottomsQuery.append(" AND b.minimumBidPriceValue >= ").append(similarMinPrice);
        }
        if (similarMaxPrice != null && !similarMaxPrice.isEmpty()) {
            bottomsQuery.append(" AND b.minimumBidPriceValue <= ").append(similarMaxPrice);
        }

        if (similarId != null && !similarId.isEmpty()) {
            bottomsQuery.append(" AND b.bottomIdValue != ").append(similarId);
        }
    }

    bottomsQuery.append(" ORDER BY b.bottomIdValue DESC");

    ResultSet rs = st.executeQuery(bottomsQuery.toString());
    boolean found = false;
    
    out.println("<div class='items-grid'>");


    while (rs.next()) {
        found = true;

        String sellerUsername   = rs.getString("sellerUsername");
        String bottomIdVal      = rs.getString("bottomIdValue");
        String genderVal        = rs.getString("genderValue");
        String sizeVal          = rs.getString("sizeValue");
        String colorVal         = rs.getString("colorValue");
        String waistVal         = rs.getString("waistLengthValue");
        String inseamVal        = rs.getString("inseamLengthValue");
        String outseamVal       = rs.getString("outseamLengthValue");
        String hipVal           = rs.getString("hipLengthValue");
        String riseVal          = rs.getString("riseLengthValue");
        String descVal          = rs.getString("descriptionValue");
        String condVal          = rs.getString("conditionValue");
        float minBid            = rs.getFloat("minimumBidPriceValue");
        float startOrCurrent    = rs.getFloat("startingOrCurrentBidPriceValue");
        String auctionDateVal   = rs.getString("auctionCloseDateValue");
        String auctionTimeVal   = rs.getString("auctionCloseTimeValue");


        double simMinPrice = Math.round(minBid * 0.9 * 100.0) / 100.0;
        double simMaxPrice = Math.round(minBid * 1.1 * 100.0) / 100.0;

        Integer currentUserId = (Integer) session.getAttribute("userIdValue");
        String sellerIdStr = rs.getString("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && sellerIdStr != null && 
                           currentUserId.toString().equals(sellerIdStr));

        out.println("<div class='item-card'>");
        out.println("<div class='item-image'>👖</div>");
        out.println("<div class='item-body'>");
        out.println("<div class='item-title'>" + (descVal != null && !descVal.isEmpty() ? descVal : "Bottom #" + bottomIdVal) + "</div>");
        out.println("<div class='item-meta'>");
        out.println("<span>👤 Seller: " + sellerUsername + "</span> | ");
        out.println("<span>" + genderVal + "</span> | ");
        out.println("<span>Size: " + sizeVal + "</span> | ");
        out.println("<span>Color: " + colorVal + "</span>");
        out.println("</div>");
        
        out.println("<div style='margin: 1rem 0; padding: 1rem; background: var(--bg-light); border-radius: 8px;'>");
        out.println("<p style='margin: 0.5rem 0;'><strong>📏 Measurements:</strong></p>");
        out.println("<p style='margin: 0.25rem 0; color: var(--text-secondary);'>Waist: " + waistVal + "cm | Inseam: " + inseamVal + "cm | Outseam: " + outseamVal + "cm</p>");
        out.println("<p style='margin: 0.25rem 0; color: var(--text-secondary);'>Hip: " + hipVal + "cm | Rise: " + riseVal + "cm</p>");
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
        out.println("<form method='get' action='bottoms.jsp' style='display:inline;'>");
        out.println("<input type='hidden' name='similarId' value='" + bottomIdVal + "'>");
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
        out.println("<p style='text-align: center; color: var(--text-secondary); font-size: 1.1rem;'>No bottoms found matching your criteria.</p>");
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
