<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root", "Xcrafty!3my");
Statement st = con.createStatement();

int counter = 0;
%>


<script>
function createBid(counter) {
    var SetNewBidLabel = document.getElementById('SetNewBidLabel' + counter);
    var SetNewBid = document.getElementById('SetNewBid' + counter);
    var SetAutomaticBidLabel = document.getElementById('SetAutomaticBidLabel' + counter);
    var SetAutomaticBid = document.getElementById('SetAutomaticBid' + counter);
    var cancel = document.getElementById('cancel' + counter);
    var PlaceBid = document.getElementById('TopPlaceBid' + counter);
    
    SetNewBidLabel.style.display = 'block';
    SetNewBid.style.display = 'block';
    SetAutomaticBidLabel.style.display = 'block';
    SetAutomaticBid.style.display = 'block';
    cancel.style.display = 'block';
    PlaceBid.style.display = 'block';
    
    SetAutomaticBid.addEventListener("change", function() {
        handleAutomaticBidChange(counter);
    });
}

function handleAutomaticBidChange(counter) {
    var SetAutomaticBid = document.getElementById('SetAutomaticBid' + counter);
    var SetAutomaticBidPriceLabel = document.getElementById('SetAutomaticBidPriceLabel' + counter);
    var SetAutomaticBidPrice = document.getElementById('SetAutomaticBidPrice' + counter);
    var SetAutomaticBidIncrementPriceLabel = document.getElementById('SetAutomaticBidIncrementPriceLabel' + counter);
    var SetAutomaticBidIncrementPrice = document.getElementById('SetAutomaticBidIncrementPrice' + counter);
    
    const value = SetAutomaticBid.value;
    
    if(value === 'true') {
        SetAutomaticBidPriceLabel.style.display = 'block';
        SetAutomaticBidPrice.style.display = 'block';
        SetAutomaticBidIncrementPriceLabel.style.display = 'block';
        SetAutomaticBidIncrementPrice.style.display = 'block';
    } else {
        SetAutomaticBidPriceLabel.style.display = 'none';
        SetAutomaticBidPrice.style.display = 'none';
        SetAutomaticBidIncrementPriceLabel.style.display = 'none';
        SetAutomaticBidIncrementPrice.style.display = 'none';
    }
}

function removeBid(counter) {
    var SetNewBidLabel = document.getElementById('SetNewBidLabel' + counter);
    var SetNewBid = document.getElementById('SetNewBid' + counter);
    var SetAutomaticBidLabel = document.getElementById('SetAutomaticBidLabel' + counter);
    var SetAutomaticBid = document.getElementById('SetAutomaticBid' + counter);
    var SetAutomaticBidPriceLabel = document.getElementById('SetAutomaticBidPriceLabel' + counter);
    var SetAutomaticBidPrice = document.getElementById('SetAutomaticBidPrice' + counter);
    var SetAutomaticBidIncrementPriceLabel = document.getElementById('SetAutomaticBidIncrementPriceLabel' + counter);
    var SetAutomaticBidIncrementPrice = document.getElementById('SetAutomaticBidIncrementPrice' + counter);
    var cancel = document.getElementById('cancel' + counter);
    var PlaceBid = document.getElementById('TopPlaceBid' + counter);
    
    SetNewBidLabel.style.display = 'none';
    SetNewBid.style.display = 'none';
    SetAutomaticBidLabel.style.display = 'none';
    SetAutomaticBid.style.display = 'none';
    SetAutomaticBidPriceLabel.style.display = 'none';
    SetAutomaticBidPrice.style.display = 'none';
    SetAutomaticBidIncrementPriceLabel.style.display = 'none';
    SetAutomaticBidIncrementPrice.style.display = 'none';
    cancel.style.display = 'none';
    PlaceBid.style.display = 'none';
}

function placeBid(counter) {
    
}
</script>

</script>

<%

String gender = request.getParameter("topGender");
if(gender != null) {
    Integer userIdValue = (Integer) session.getAttribute("userIdValue");
    String size = request.getParameter("topSize");
    String color = request.getParameter("topColor");
    Float frontlength = Float.parseFloat(request.getParameter("FrontLength"));
    Float chestlength = Float.parseFloat(request.getParameter("ChestLength"));
    Float sleevelength = Float.parseFloat(request.getParameter("SleeveLength"));
    String description = request.getParameter("Description");
    String condition = request.getParameter("Condition");
    String minimum = request.getParameter("Minimum");
    String startingorcurrentbidprice = request.getParameter("StartingOrCurrentBidPrice");
    String auctionclosedate = request.getParameter("AuctionCloseDateTops");
    String auctionclosetime = request.getParameter("AuctionCloseTimeTops");

    if(minimum != null && !minimum.isEmpty() && !minimum.equals("0.0")) {
        String insertTopInformation = "insert into tops (auctionSellerIdValue, genderValue, sizeValue, colorValue, frontLengthValue, chestLengthValue, sleeveLengthValue, descriptionValue, conditionValue, minimumBidPriceValue, startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) values ('" + userIdValue + "','" + gender + "' ,'" + size + "' ,'" + color + "','" + frontlength + "','" + chestlength + "','" + sleevelength + "','" + description + "','" + condition + "', '" + minimum + "', '" + startingorcurrentbidprice + "', '" + auctionclosedate + "', '" + auctionclosetime + "')"; 
        int insertedRows = st.executeUpdate(insertTopInformation);
    }
    else {
        minimum = "0.0";
        String insertTopInformation = "insert into tops (auctionSellerIdValue, genderValue, sizeValue, colorValue, frontLengthValue, chestLengthValue, sleeveLengthValue, descriptionValue, conditionValue, minimumBidPriceValue, startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) values ('" + userIdValue + "','" + gender + "' ,'" + size + "' ,'" + color + "','" + frontlength + "','" + chestlength + "','" + sleevelength + "','" + description + "','" + condition + "', '" + minimum + "', '" + startingorcurrentbidprice + "', '" + auctionclosedate + "', '" + auctionclosetime + "')"; 
        int insertedRows = st.executeUpdate(insertTopInformation);
    }
}

ResultSet rs = st.executeQuery("select * from tops order by topIdValue desc");
while(rs.next()) {  
    String topIdValueDisplay = rs.getString("topIdValue");
    String genderValueDisplay = rs.getString("genderValue");
    String sizeValueDisplay = rs.getString("sizeValue");
    String colorValueDisplay = rs.getString("colorValue");
    String frontLengthValueDisplay = rs.getString("frontLengthValue");
    String sleeveLengthValueDisplay = rs.getString("sleeveLengthValue");
    String descriptionValueDisplay = rs.getString("descriptionValue");
    String conditionValueDisplay = rs.getString("conditionValue");
    Float minimumBidPriceValueDisplay = rs.getFloat("minimumBidPriceValue");
    Float startingOrCurrentBidPriceValueDisplay = rs.getFloat("startingOrCurrentBidPriceValue");
    String auctionCloseDateValueDisplay = rs.getString("auctionCloseDateValue");
    String auctionCloseTimeValueDisplay = rs.getString("auctionCloseTimeValue");

    out.println("<div>");
    out.println("<p>Gender: " + genderValueDisplay + "</p>");
    out.println("<p>Size: " + sizeValueDisplay + "</p>");
    out.println("<p>Color: " + colorValueDisplay + "</p>");
    out.println("<p>Front Length: " + frontLengthValueDisplay + "</p>");
    out.println("<p>Sleeve Length: " + sleeveLengthValueDisplay + "</p>");
    out.println("<p>Description: " + descriptionValueDisplay + "</p>");
    out.println("<p>Condition: " + conditionValueDisplay + "</p>");
    if(minimumBidPriceValueDisplay != null || minimumBidPriceValueDisplay != 0.0f) {
        out.println("<p>Minimum Bid Price: " + minimumBidPriceValueDisplay + "</p>");
    }
    else {
        out.println("<p>Minimum Bid Price: " + "None" + "</p>");
    }    
    out.println("<p>Starting or Current Bid Price: " + startingOrCurrentBidPriceValueDisplay + "</p>");
    out.println("<p>Auction Close Date: " + auctionCloseDateValueDisplay + "</p>");
    out.println("<p>Auction Close Time: " + auctionCloseTimeValueDisplay + "</p>");
    out.println("<input type='submit' value='Create Bid' onclick='createBid(" + counter + ")' id='TopCreateBid" + counter + "' style='margin-bottom: 100px;'>");
    out.println("<form method='post' action='bidPage.jsp'>");
    out.println("<input type='hidden' name='topIdValue' value='" + topIdValueDisplay +"'>");
    out.println("<label for='setNewBid' id='SetNewBidLabel" + counter + "' style='display: none;'>Set Bid (USD): </label>");
    out.println("<input type='number' name='setNewBid' id='SetNewBid" + counter + "' style='display: none;' required>");
    out.println("<label for='setAutomaticBid' id='SetAutomaticBidLabel" + counter + "' style='display: none;'>Set Automatic Bid: </label>");
    out.println("<select name='setAutomaticBid' id='SetAutomaticBid" + counter + "' style='display: none;' required>");
    out.println("<option value='selectAnItem' disabled selected>Select Item...</option>");
    out.println("<option value='true' id='true'>Yes</option>");
    out.println("<option value='false' id='false'>No</option>");
    out.println("</select>");
    out.println("<label for='maxBidPrice' id='SetAutomaticBidPriceLabel" + counter + "' style='display: none;'>Set Max Bid Price (USD): </label>");
    out.println("<input type='number' name='maxBidPrice' id='SetAutomaticBidPrice" + counter + "' style='display: none;'>");
    out.println("<label for='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPriceLabel" + counter + "' style='display: none;'>Set Bid Increment Price (USD): </label>");
    out.println("<input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice" + counter + "' style='display: none;'>");
    out.println("<input type='submit' value='Cancel Bid' onclick='removeBid(" + counter + ")' id='cancel" + counter + "' style='display: none;'>");
    out.println("<input type='submit' value='Place Bid' onclick='placeBid(" + counter +")' id='TopPlaceBid" + counter + "' style='display: none;'>");
    out.println("</form>");
    out.println("</div>");
    counter++;
}

String alertMessage = (String) session.getAttribute("alertMessage");
if (alertMessage != null) {
    session.removeAttribute("alertMessage");
    if (alertMessage.equals("success")) {
%>
<script>
    alert("Your bid has been successfully placed!")
</script>
<%
    } else if (alertMessage.equals("fail")) {
%>
<script>
    alert("Your bid must be higher than the original price!")
</script>
<%
    }
}

out.println("<a href='../WebsitePages/profile.jsp'>Profile Page</a>");

rs.close();
st.close();
con.close();
%>