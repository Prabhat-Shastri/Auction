
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root", "Xcrafty!3my");
Statement st = con.createStatement();



String gender = request.getParameter("shoeGender");
if(gender != null) {
    Integer userIdValue = (Integer) session.getAttribute("userIdValue");
    String size = request.getParameter("shoeSize");
    String color = request.getParameter("shoeColor");
    String description = request.getParameter("Description");
    String condition = request.getParameter("Condition");
    String minimum = request.getParameter("Minimum");
    String auctionclosedate = request.getParameter("AuctionCloseDateShoes");
    String auctionclosetime = request.getParameter("AuctionCloseTimeShoes");

    if(minimum != null && !minimum.isEmpty() && !minimum.equals("0.0")) {
        String insertShoeInformation = "insert into shoes (auctionSellerIdValue, genderValue, sizeValue, colorValue, descriptionValue, conditionValue, minimumBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) values ('" + userIdValue + "','" + gender + "' ,'" + size + "' ,'" + color + "','" + description + "','" + condition + "', '" + minimum + "', '" + auctionclosedate + "', '" + auctionclosetime + "')"; 
        int insertedRows = st.executeUpdate(insertShoeInformation);
    }
    else {
        minimum = "0.0";
        String insertShoeInformation = "insert into shoes (auctionSellerIdValue, genderValue, sizeValue, colorValue, descriptionValue, conditionValue, minimumBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) values ('" + userIdValue + "','" + gender + "' ,'" + size + "' ,'" + color + "','" + description + "','" + condition + "', '" + minimum + "', '" + auctionclosedate + "', '" + auctionclosetime + "')"; 
        int insertedRows = st.executeUpdate(insertShoeInformation);
    }
}

ResultSet rs = st.executeQuery("select * from shoes order by shoeIdValue desc");
while(rs.next()) {  
    String genderValueDisplay = rs.getString("genderValue");
    String sizeValueDisplay = rs.getString("sizeValue");
    String colorValueDisplay = rs.getString("colorValue");
    String descriptionValueDisplay = rs.getString("descriptionValue");
    String conditionValueDisplay = rs.getString("conditionValue");
    Float minimumBidPriceValueDisplay = rs.getFloat("minimumBidPriceValue");
    String auctionCloseDateValueDisplay = rs.getString("auctionCloseDateValue");
    String auctionCloseTimeValueDisplay = rs.getString("auctionCloseTimeValue");

    out.println("<div class='post' style='margin-bottom: 100px;'>");
    out.println("<p>Gender: " + genderValueDisplay + "</p>");
    out.println("<p>Size: " + sizeValueDisplay + "</p>");
    out.println("<p>Color: " + colorValueDisplay + "</p>");
    out.println("<p>Description: " + descriptionValueDisplay + "</p>");
    out.println("<p>Condition: " + conditionValueDisplay + "</p>");
    if(minimumBidPriceValueDisplay != null || minimumBidPriceValueDisplay != 0.0f) {
        out.println("<p>Minimum Bid Price: " + minimumBidPriceValueDisplay + "</p>");
    }
    else {
        out.println("<p>Minimum Bid Price: " + "None" + "</p>");
    }    
    out.println("<p>Auction Close Date: " + auctionCloseDateValueDisplay + "</p>");
    out.println("<p>Auction Close Time: " + auctionCloseTimeValueDisplay + "</p>");
    out.println("</div>");
}

out.println("<a href='../WebsitePages/profile.jsp'>Profile Page</a>");

rs.close();
st.close();
con.close();
%>