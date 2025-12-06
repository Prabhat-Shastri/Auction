<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page import="java.time.LocalDate,java.time.LocalTime,java.time.LocalDateTime" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // load MySQL driver
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/thriftShop","root", "12345");
    Statement st = con.createStatement();

    // check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    out.println("<h3>User: " + session.getAttribute("username") + "</h3>");
    out.println("<a href='../WebsitePages/mainPage.jsp'>Main Page</a>");
    out.println("<br/>This is the shoes page<br/><br/>");

    // handle new shoe auction submit
    String gender = request.getParameter("shoeGender");
    if (gender != null) {

        // read date and time
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

        // date and time are ok, read rest of fields
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

        // your form for shoes does not have StartingOrCurrentBidPrice
        // so if it is missing or empty, use minimum as starting price
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

    // query shoes with seller username
    String shoesQuery =
            "SELECT s.*, u.usernameValue AS sellerUsername " +
                    "FROM shoes s " +
                    "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                    "ORDER BY s.shoeIdValue DESC";

    ResultSet rs = st.executeQuery(shoesQuery);

    // display shoes
    while (rs.next()) {

        String sellerUsername  = rs.getString("sellerUsername");
        String genderVal       = rs.getString("genderValue");
        String sizeVal         = rs.getString("sizeValue");
        String colorVal        = rs.getString("colorValue");
        String descVal         = rs.getString("descriptionValue");
        String condVal         = rs.getString("conditionValue");
        float minBid           = rs.getFloat("minimumBidPriceValue");
        float startOrCurrent   = rs.getFloat("startingOrCurrentBidPriceValue");
        String auctionDateVal  = rs.getString("auctionCloseDateValue");
        String auctionTimeVal  = rs.getString("auctionCloseTimeValue");

        out.println("<div class='post' style='margin-bottom: 100px;'>");

        out.println("<p><strong>Seller:</strong> " + sellerUsername + "</p>");
        out.println("<p><strong>Gender:</strong> " + genderVal + "</p>");
        out.println("<p><strong>Size:</strong> " + sizeVal + "</p>");
        out.println("<p><strong>Color:</strong> " + colorVal + "</p>");
        out.println("<p><strong>Description:</strong> " + descVal + "</p>");
        out.println("<p><strong>Condition:</strong> " + condVal + "</p>");

        if (minBid != 0.0f) {
            out.println("<p><strong>Minimum Bid Price:</strong> " + minBid + "</p>");
        } else {
            out.println("<p><strong>Minimum Bid Price:</strong> None</p>");
        }

        out.println("<p><strong>Starting or Current Bid Price:</strong> " + startOrCurrent + "</p>");
        out.println("<p><strong>Auction Close Date:</strong> " + auctionDateVal + "</p>");
        out.println("<p><strong>Auction Close Time:</strong> " + auctionTimeVal + "</p>");

        out.println("</div>");
    }

    rs.close();
    st.close();
    con.close();
%>
