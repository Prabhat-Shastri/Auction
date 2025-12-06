<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>

<%
    // Load MySQL Driver
    Class.forName("com.mysql.cj.jdbc.Driver");

    // Connect to DB
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/thriftShop","root", "12345");
    Statement st = con.createStatement();

    // Ensure user is logged in
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    out.println("<h3>User: " + session.getAttribute("username") + "</h3>");
    out.println("<a href='../WebsitePages/mainPage.jsp'>Main Page</a>");
    out.println("<br/>This is the shoes page<br/><br/>");

    // Handle shoe submission
    String gender = request.getParameter("shoeGender");
    if (gender != null) {

        Integer userIdValue = (Integer) session.getAttribute("userIdValue");
        String size        = request.getParameter("shoeSize");
        String color       = request.getParameter("shoeColor");
        String description = request.getParameter("Description");
        String condition   = request.getParameter("Condition");
        String minimum     = request.getParameter("Minimum");
        String startingorcurrentbidprice = request.getParameter("StartingOrCurrentBidPrice");
        String auctionDate = request.getParameter("AuctionCloseDateShoes");
        String auctionTime = request.getParameter("AuctionCloseTimeShoes");

        if (minimum == null || minimum.isEmpty()) {
            minimum = "0.0";
        }

        // Insert into shoes table
        String insert =
                "INSERT INTO shoes " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " descriptionValue, conditionValue, minimumBidPriceValue, " +
                        " startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) VALUES (" +
                        "'" + userIdValue + "', '" + gender + "', '" + size + "', '" + color + "', " +
                        "'" + description + "', '" + condition + "', '" + minimum + "', " +
                        "'" + startingorcurrentbidprice + "', '" + auctionDate + "', '" + auctionTime + "')";

        st.executeUpdate(insert);
    }
    // Query shoes WITH seller username from users table
    String shoesQuery =
            "SELECT s.*, u.usernameValue AS sellerUsername " +
                    "FROM shoes s " +
                    "JOIN users u ON s.auctionSellerIdValue = u.userIdValue " +
                    "ORDER BY s.shoeIdValue DESC";

    ResultSet rs = st.executeQuery(shoesQuery);

    // Display shoes
    while (rs.next()) {

        String sellerUsername  = rs.getString("sellerUsername");
        String genderVal       = rs.getString("genderValue");
        String sizeVal         = rs.getString("sizeValue");
        String colorVal        = rs.getString("colorValue");
        String descVal         = rs.getString("descriptionValue");
        String condVal         = rs.getString("conditionValue");
        float minBid           = rs.getFloat("minimumBidPriceValue");
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

        out.println("<p><strong>Auction Close Date:</strong> " + auctionDateVal + "</p>");
        out.println("<p><strong>Auction Close Time:</strong> " + auctionTimeVal + "</p>");

        out.println("</div>");
    }

    rs.close();
    st.close();
    con.close();
%>
