<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root", "Xcrafty!3my");
Statement st = con.createStatement();
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
<%

String counter = "select bidIdValue from topsIncrementBids order by bidIdValue desc LIMIT 1";
ResultSet counterResult = st.executeQuery(counter);
Integer counterValue = 0;
while(counterResult.next()) {
    counterValue = counterResult.getInt("bidIdValue");
}

Integer userIdValue = (Integer) session.getAttribute("userIdValue");
String bidNotifications = "select distinct topIdValue from topsIncrementBids where buyerIdValue = '" + userIdValue + "' order by topIdValue desc";
ResultSet bidNotificationsResult = st.executeQuery(bidNotifications);

List<Integer> topIdValueOfItemsBiddedOnByBidder = new ArrayList<>();
while(bidNotificationsResult.next()) {
    Integer topIdValue = bidNotificationsResult.getInt("topIdValue");  
    topIdValueOfItemsBiddedOnByBidder.add(topIdValue);
}

for(int i = 0; i < topIdValueOfItemsBiddedOnByBidder.size(); i++) {
    String buyersBidPrice = "select newBidValue from topsIncrementBids where buyerIdValue = '" + userIdValue + "' and topIdValue = '" + topIdValueOfItemsBiddedOnByBidder.get(i) + "' order by bidIdValue desc LIMIT 1";
    ResultSet buyersBidPriceResult = st.executeQuery(buyersBidPrice);
    
    Integer buyersBidPriceValue = null;
    if(buyersBidPriceResult.next()) {  
        buyersBidPriceValue = buyersBidPriceResult.getInt("newBidValue"); 
    }

    String currentBidPrice = "select newBidValue from topsIncrementBids where topIdValue = '" + topIdValueOfItemsBiddedOnByBidder.get(i) + "' order by bidIdValue desc LIMIT 1";
    ResultSet currentBidPriceResult = st.executeQuery(currentBidPrice);
    
    Integer currentBidPriceValue = null;
    if(currentBidPriceResult.next()) { 
        currentBidPriceValue = currentBidPriceResult.getInt("newBidValue"); 
    }

    if(buyersBidPriceValue != null && currentBidPriceValue != null && buyersBidPriceValue < currentBidPriceValue) {
        String topInformation = "select * from tops where topIdValue = '" + topIdValueOfItemsBiddedOnByBidder.get(i) + "'";  // FIXED: select all columns
        ResultSet topInformationResult = st.executeQuery(topInformation);
        Integer topInformationValue = topIdValueOfItemsBiddedOnByBidder.get(i);

        if(topInformationResult.next()) {  
            
            String genderValueDisplay = topInformationResult.getString("genderValue");
            String sizeValueDisplay = topInformationResult.getString("sizeValue");
            String colorValueDisplay = topInformationResult.getString("colorValue");
            String frontLengthValueDisplay = topInformationResult.getString("frontLengthValue");
            String sleeveLengthValueDisplay = topInformationResult.getString("sleeveLengthValue");
            String descriptionValueDisplay = topInformationResult.getString("descriptionValue");
            String conditionValueDisplay = topInformationResult.getString("conditionValue");
            Float minimumBidPriceValueDisplay = topInformationResult.getFloat("minimumBidPriceValue");
            Float startingOrCurrentBidPriceValueDisplay = topInformationResult.getFloat("startingOrCurrentBidPriceValue");
            String auctionCloseDateValueDisplay = topInformationResult.getString("auctionCloseDateValue");
            String auctionCloseTimeValueDisplay = topInformationResult.getString("auctionCloseTimeValue");

            out.println("<div>");
            out.println("<p>Gender: " + genderValueDisplay + "</p>");
            out.println("<p>Size: " + sizeValueDisplay + "</p>");
            out.println("<p>Color: " + colorValueDisplay + "</p>");
            out.println("<p>Front Length: " + frontLengthValueDisplay + "</p>");
            out.println("<p>Sleeve Length: " + sleeveLengthValueDisplay + "</p>");
            out.println("<p>Description: " + descriptionValueDisplay + "</p>");
            out.println("<p>Condition: " + conditionValueDisplay + "</p>");
            if(minimumBidPriceValueDisplay != null && minimumBidPriceValueDisplay != 0.0f) {  
                out.println("<p>Minimum Bid Price: " + minimumBidPriceValueDisplay + "</p>");
            }
            else {
                out.println("<p>Minimum Bid Price: None</p>");
            }    
            out.println("<p>Starting or Current Bid Price: " + startingOrCurrentBidPriceValueDisplay + "</p>");
            out.println("<p>Auction Close Date: " + auctionCloseDateValueDisplay + "</p>");
            out.println("<p>Auction Close Time: " + auctionCloseTimeValueDisplay + "</p>");
            out.println("<p>The bid price for the following top has gone to " + currentBidPriceValue + "</p>");
            out.println("<input type='submit' value='Create New Bid' onclick='createBid(" + counterValue + ")' id='TopCreateBid" + counterValue + "' style='margin-bottom: 100px;'>");
            out.println("<form method='post' action='bidPage.jsp'>");
            out.println("<input type='hidden' name='topIdValue' value='" + topInformationValue +"'>");
            out.println("<label for='setNewBid' id='SetNewBidLabel" + counterValue + "' style='display: none;'>Set Bid (USD): </label>");
            out.println("<input type='number' name='setNewBid' id='SetNewBid" + counterValue + "' style='display: none;' required>");
            out.println("<label for='setAutomaticBid' id='SetAutomaticBidLabel" + counterValue + "' style='display: none;'>Set Automatic Bid: </label>");
            out.println("<select name='setAutomaticBid' id='SetAutomaticBid" + counterValue + "' style='display: none;' required>");
            out.println("<option value='selectAnItem' disabled selected>Select Item...</option>");
            out.println("<option value='true' id='true'>Yes</option>");
            out.println("<option value='false' id='false'>No</option>");
            out.println("</select>");
            out.println("<label for='maxBidPrice' id='SetAutomaticBidPriceLabel" + counterValue + "' style='display: none;'>Set Bid Price (USD): </label>");
            out.println("<input type='number' name='maxBidPrice' id='SetAutomaticBidPrice" + counterValue + "' style='display: none;'>");
            out.println("<label for='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPriceLabel" + counterValue + "' style='display: none;'>Bid Increment Price (USD): </label>");
            out.println("<input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice" + counterValue + "' style='display: none;'>");
            out.println("<input type='submit' value='Cancel Bid' onclick='removeBid(" + counterValue + ")' id='cancel" + counterValue + "' style='display: none;'>");
            out.println("<input type='submit' value='Place Bid' onclick='placeBid(" + counterValue +")' id='TopPlaceBid" + counterValue + "' style='display: none;'>");
            out.println("</form>");
            out.println("</div>");
            counterValue++;

            out.println("</div>");
        }
    }
    else if (buyersBidPriceValue != null && currentBidPriceValue != null && buyersBidPriceValue.equals(currentBidPriceValue)) {
        String topInformation = "select * from tops where topIdValue = '" + topIdValueOfItemsBiddedOnByBidder.get(i) + "'";  
        ResultSet topInformationResult = st.executeQuery(topInformation);

        if(topInformationResult.next()) {  
            
            String genderValueDisplay = topInformationResult.getString("genderValue");
            String sizeValueDisplay = topInformationResult.getString("sizeValue");
            String colorValueDisplay = topInformationResult.getString("colorValue");
            String frontLengthValueDisplay = topInformationResult.getString("frontLengthValue");
            String sleeveLengthValueDisplay = topInformationResult.getString("sleeveLengthValue");
            String descriptionValueDisplay = topInformationResult.getString("descriptionValue");
            String conditionValueDisplay = topInformationResult.getString("conditionValue");
            Float minimumBidPriceValueDisplay = topInformationResult.getFloat("minimumBidPriceValue");
            Float startingOrCurrentBidPriceValueDisplay = topInformationResult.getFloat("startingOrCurrentBidPriceValue");
            String auctionCloseDateValueDisplay = topInformationResult.getString("auctionCloseDateValue");
            String auctionCloseTimeValueDisplay = topInformationResult.getString("auctionCloseTimeValue");

            out.println("<div>");
            out.println("<p>Gender: " + genderValueDisplay + "</p>");
            out.println("<p>Size: " + sizeValueDisplay + "</p>");
            out.println("<p>Color: " + colorValueDisplay + "</p>");
            out.println("<p>Front Length: " + frontLengthValueDisplay + "</p>");
            out.println("<p>Sleeve Length: " + sleeveLengthValueDisplay + "</p>");
            out.println("<p>Description: " + descriptionValueDisplay + "</p>");
            out.println("<p>Condition: " + conditionValueDisplay + "</p>");
            if(minimumBidPriceValueDisplay != null && minimumBidPriceValueDisplay != 0.0f) {  
                out.println("<p>Minimum Bid Price: " + minimumBidPriceValueDisplay + "</p>");
            }
            else {
                out.println("<p>Minimum Bid Price: None</p>");
            }    
            out.println("<p>Starting or Current Bid Price: " + startingOrCurrentBidPriceValueDisplay + "</p>");
            out.println("<p>Auction Close Date: " + auctionCloseDateValueDisplay + "</p>");
            out.println("<p>Auction Close Time: " + auctionCloseTimeValueDisplay + "</p>");
            out.println("<p>You are currently the highest bidder you are winning!</p>");
            out.println("</div>");
        }
    }
}
%>

//add the logic for when the value of the bid increases and then we want to automatically update the bid value and then if the bid value added exceed the current price then we want to ask the user do they want to bid extra which will surpass the bid or do we want to just keep the current bid and add the remaining amount to reach the max