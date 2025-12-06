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
    out.println("<br/>This is the bottoms page<br/><br/>");

    // Handle bottoms submission
    String gender = request.getParameter("bottomGender");
    if (gender != null) {

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
        String auctionDate = request.getParameter("AuctionCloseDateBottoms");
        String auctionTime = request.getParameter("AuctionCloseTimeBottoms");

        if (minimum == null || minimum.isEmpty()) {
            minimum = "0.0";
        }

        String insert =
                "INSERT INTO bottoms " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " waistLengthValue, inseamLengthValue, outseamLengthValue, " +
                        " hipLengthValue, riseLengthValue, descriptionValue, conditionValue, " +
                        " minimumBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) VALUES (" +
                        "'" + userIdValue + "', '" + gender + "', '" + size + "', '" + color + "', " +
                        "'" + waistLength + "', '" + inseamLength + "', '" + outseamLength + "', " +
                        "'" + hipLength + "', '" + riseLength + "', '" + description + "', '" + condition + "', " +
                        "'" + minimum + "', '" + auctionDate + "', '" + auctionTime + "')";

        st.executeUpdate(insert);
    }

    // Query bottoms WITH seller username from users table
    String bottomsQuery =
            "SELECT b.*, u.usernameValue AS sellerUsername " +
                    "FROM bottoms b " +
                    "JOIN users u ON b.auctionSellerIdValue = u.userIdValue " +
                    "ORDER BY b.bottomIdValue DESC";

    ResultSet rs = st.executeQuery(bottomsQuery);

    // Display bottoms
    while (rs.next()) {

        String sellerUsername   = rs.getString("sellerUsername");
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
        String auctionDateVal   = rs.getString("auctionCloseDateValue");
        String auctionTimeVal   = rs.getString("auctionCloseTimeValue");

        out.println("<div style='margin-bottom: 100px;'>");

        out.println("<p><strong>Seller:</strong> " + sellerUsername + "</p>");
        out.println("<p><strong>Gender:</strong> " + genderVal + "</p>");
        out.println("<p><strong>Size:</strong> " + sizeVal + "</p>");
        out.println("<p><strong>Color:</strong> " + colorVal + "</p>");

        out.println("<p><strong>Waist Length:</strong> " + waistVal + "</p>");
        out.println("<p><strong>Inseam Length:</strong> " + inseamVal + "</p>");
        out.println("<p><strong>Outseam Length:</strong> " + outseamVal + "</p>");
        out.println("<p><strong>Hip Length:</strong> " + hipVal + "</p>");
        out.println("<p><strong>Rise Length:</strong> " + riseVal + "</p>");

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

    out.println("<a href='../WebsitePages/profile.jsp'>Profile Page</a>");

    rs.close();
    st.close();
    con.close();
%>
