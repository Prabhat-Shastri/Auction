<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/thriftShop","root", "12345");
    Statement st = con.createStatement();

    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }
    out.println("<h3>User: " + session.getAttribute("username") + "</h3>");

    out.println("<a href='../WebsitePages/mainPage.jsp'>Main Page</a>");
    out.println("<br/>This is the Bottoms page<br/><br/>");

    String gender = request.getParameter("bottomGender");
    if (gender != null) {
        Integer userIdValue = (Integer) session.getAttribute("userIdValue");
        String size = request.getParameter("bottomSize");
        String color = request.getParameter("bottomColor");
        Float waistlength  = Float.parseFloat(request.getParameter("WaistLength"));
        Float inseamlength = Float.parseFloat(request.getParameter("InseamLength"));
        Float outseamlength= Float.parseFloat(request.getParameter("OutseamLength"));
        Float hiplength    = Float.parseFloat(request.getParameter("HipLength"));
        Float riselength   = Float.parseFloat(request.getParameter("RiseLength"));
        String description = request.getParameter("Description");
        String condition   = request.getParameter("Condition");
        String minimum     = request.getParameter("Minimum");
        String auctionclosedate = request.getParameter("AuctionCloseDateBottoms");
        String auctionclosetime = request.getParameter("AuctionCloseTimeBottoms");

        if (minimum == null || minimum.isEmpty()) {
            minimum = "0.0";
        }

        String insertBottomInformation =
                "insert into bottoms " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " waistLengthValue, inseamLengthValue, outseamLengthValue, " +
                        " hipLengthValue, riseLengthValue, descriptionValue, conditionValue, " +
                        " minimumBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) " +
                        "values ('" + userIdValue + "','" + gender + "','" + size + "','" + color + "'," +
                        "'" + waistlength + "','" + inseamlength + "','" + outseamlength + "'," +
                        "'" + hiplength + "','" + riselength + "','" + description + "','" + condition + "'," +
                        "'" + minimum + "','" + auctionclosedate + "','" + auctionclosetime + "')";

        int insertedRows = st.executeUpdate(insertBottomInformation);
    }

    ResultSet rs = st.executeQuery("select * from bottoms order by bottomIdValue desc");
    while (rs.next()) {
        String genderValueDisplay       = rs.getString("genderValue");
        String sizeValueDisplay         = rs.getString("sizeValue");
        String colorValueDisplay        = rs.getString("colorValue");
        String waistLengthValueDisplay  = rs.getString("waistLengthValue");
        String inseamLengthValueDisplay = rs.getString("inseamLengthValue");
        String outseamLengthValueDisplay= rs.getString("outseamLengthValue");
        String hipLengthValueDisplay    = rs.getString("hipLengthValue");
        String riseLengthValueDisplay   = rs.getString("riseLengthValue");
        String descriptionValueDisplay  = rs.getString("descriptionValue");
        String conditionValueDisplay    = rs.getString("conditionValue");
        float minimumBidPriceValueDisplay = rs.getFloat("minimumBidPriceValue");
        String auctionCloseDateValueDisplay = rs.getString("auctionCloseDateValue");
        String auctionCloseTimeValueDisplay = rs.getString("auctionCloseTimeValue");

        out.println("<div style='margin-bottom: 100px;'>");
        out.println("<p>Gender: " + genderValueDisplay + "</p>");
        out.println("<p>Size: " + sizeValueDisplay + "</p>");
        out.println("<p>Color: " + colorValueDisplay + "</p>");

        out.println("<p>Waist Length: " + waistLengthValueDisplay + "</p>");
        out.println("<p>Inseam Length: " + inseamLengthValueDisplay + "</p>");
        out.println("<p>Outseam Length: " + outseamLengthValueDisplay + "</p>");
        out.println("<p>Hip Length: " + hipLengthValueDisplay + "</p>");
        out.println("<p>Rise Length: " + riseLengthValueDisplay + "</p>");

        out.println("<p>Description: " + descriptionValueDisplay + "</p>");
        out.println("<p>Condition: " + conditionValueDisplay + "</p>");

        if (minimumBidPriceValueDisplay != 0.0f) {
            out.println("<p>Minimum Bid Price: " + minimumBidPriceValueDisplay + "</p>");
        } else {
            out.println("<p>Minimum Bid Price: None</p>");
        }

        out.println("<p>Auction Close Date: " + auctionCloseDateValueDisplay + "</p>");
        out.println("<p>Auction Close Time: " + auctionCloseTimeValueDisplay + "</p>");
        out.println("</div>");
    }



    rs.close();
    st.close();
    con.close();
%>
