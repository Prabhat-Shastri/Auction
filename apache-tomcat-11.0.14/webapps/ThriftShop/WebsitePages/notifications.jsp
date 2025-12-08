<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>

<%
    // check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");

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
%>

<!DOCTYPE html>
<html>
<head>
    <title>Bid Notifications</title>
</head>
<body>
<h3>User: <%= username %></h3>
<a href="mainPage.jsp">Back to Main Page</a>
<hr/>

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

        if (value === 'true') {
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
        // handled by bidPage.jsp on submit
    }
</script>

<%
    Integer userIdValue = (Integer) session.getAttribute("userIdValue");

    if (userIdValue == null) {
        out.println("<p style='color:red;'>User id not in session. Please log in again.</p>");
    } else {

        try {
            int counterValue = 0;

            // all items this user has ever bid on (by item type and item id)
            String sqlItems =
                    "select distinct itemTypeValue, itemIdValue " +
                            "from incrementbids " +
                            "where buyerIdValue = ? " +
                            "order by itemTypeValue, itemIdValue desc";

            PreparedStatement psItems = con.prepareStatement(sqlItems);
            psItems.setInt(1, userIdValue);
            ResultSet rsItems = psItems.executeQuery();

            List<String> itemTypes = new ArrayList<String>();
            List<Integer> itemIds = new ArrayList<Integer>();

            while (rsItems.next()) {
                itemTypes.add(rsItems.getString("itemTypeValue"));
                itemIds.add(rsItems.getInt("itemIdValue"));
            }
            rsItems.close();
            psItems.close();

            if (itemIds.isEmpty()) {
                out.println("<p>You have no bid notifications yet.</p>");
            }

            for (int i = 0; i < itemIds.size(); i++) {

                String itemTypeVal = itemTypes.get(i);   // "tops", "bottoms", "shoes"
                int itemIdVal = itemIds.get(i);

                // get the column name for that table
                String tableName;
                String idColumn;

                if ("tops".equals(itemTypeVal)) {
                    tableName = "tops";
                    idColumn  = "topIdValue";
                } else if ("bottoms".equals(itemTypeVal)) {
                    tableName = "bottoms";
                    idColumn  = "bottomIdValue";
                } else if ("shoes".equals(itemTypeVal)) {
                    tableName = "shoes";
                    idColumn  = "shoeIdValue";
                } else {
                    continue;  // skip unknown type
                }

                // user last bid for this item
                String sqlUserBid =
                        "select newBidValue " +
                                "from incrementbids " +
                                "where buyerIdValue = ? and itemTypeValue = ? and itemIdValue = ? " +
                                "order by bidIdValue desc limit 1";
                PreparedStatement psUserBid = con.prepareStatement(sqlUserBid);
                psUserBid.setInt(1, userIdValue);
                psUserBid.setString(2, itemTypeVal);
                psUserBid.setInt(3, itemIdVal);
                ResultSet rsUserBid = psUserBid.executeQuery();

                Float userBid = null;
                if (rsUserBid.next()) {
                    userBid = rsUserBid.getFloat("newBidValue");
                }
                rsUserBid.close();
                psUserBid.close();

                // current highest bid for this item
                String sqlCurrentBid =
                        "select newBidValue " +
                                "from incrementbids " +
                                "where itemTypeValue = ? and itemIdValue = ? " +
                                "order by bidIdValue desc limit 1";
                PreparedStatement psCurrentBid = con.prepareStatement(sqlCurrentBid);
                psCurrentBid.setString(1, itemTypeVal);
                psCurrentBid.setInt(2, itemIdVal);
                ResultSet rsCurrentBid = psCurrentBid.executeQuery();

                Float currentBid = null;
                if (rsCurrentBid.next()) {
                    currentBid = rsCurrentBid.getFloat("newBidValue");
                }
                rsCurrentBid.close();
                psCurrentBid.close();

                // get item information from the correct table
                String sqlItemInfo =
                        "select i.*, u.usernameValue as sellerUsername " +
                                "from " + tableName + " i " +
                                "join users u on i.auctionSellerIdValue = u.userIdValue " +
                                "where i." + idColumn + " = ?";
                PreparedStatement psItemInfo = con.prepareStatement(sqlItemInfo);
                psItemInfo.setInt(1, itemIdVal);
                ResultSet rsItemInfo = psItemInfo.executeQuery();

                if (!rsItemInfo.next()) {
                    rsItemInfo.close();
                    psItemInfo.close();
                    continue;
                }

                String sellerUsername = rsItemInfo.getString("sellerUsername");
                String genderValueDisplay = rsItemInfo.getString("genderValue");
                String sizeValueDisplay = rsItemInfo.getString("sizeValue");
                String colorValueDisplay = rsItemInfo.getString("colorValue");
                String descriptionValueDisplay = rsItemInfo.getString("descriptionValue");
                String conditionValueDisplay = rsItemInfo.getString("conditionValue");
                float minimumBidPriceValueDisplay = rsItemInfo.getFloat("minimumBidPriceValue");
                float startingOrCurrentBidPriceValueDisplay = rsItemInfo.getFloat("startingOrCurrentBidPriceValue");
                String auctionCloseDateValueDisplay = rsItemInfo.getString("auctionCloseDateValue");
                String auctionCloseTimeValueDisplay = rsItemInfo.getString("auctionCloseTimeValue");

                rsItemInfo.close();
                psItemInfo.close();

                out.println("<div style='border:1px solid #ccc; margin:10px; padding:10px;'>");
                out.println("<p><strong>Item Type:</strong> " + itemTypeVal + "</p>");
                out.println("<p><strong>Item ID:</strong> " + itemIdVal + "</p>");
                out.println("<p><strong>Seller:</strong> " + sellerUsername + "</p>");
                out.println("<p><strong>Gender:</strong> " + genderValueDisplay + "</p>");
                out.println("<p><strong>Size:</strong> " + sizeValueDisplay + "</p>");
                out.println("<p><strong>Color:</strong> " + colorValueDisplay + "</p>");
                out.println("<p><strong>Description:</strong> " + descriptionValueDisplay + "</p>");
                out.println("<p><strong>Condition:</strong> " + conditionValueDisplay + "</p>");

                if (minimumBidPriceValueDisplay != 0.0f) {
                    out.println("<p><strong>Minimum Bid Price:</strong> " + minimumBidPriceValueDisplay + "</p>");
                } else {
                    out.println("<p><strong>Minimum Bid Price:</strong> None</p>");
                }

                out.println("<p><strong>Current price on item field:</strong> "
                        + startingOrCurrentBidPriceValueDisplay + "</p>");
                out.println("<p><strong>Auction Close Date:</strong> " + auctionCloseDateValueDisplay + "</p>");
                out.println("<p><strong>Auction Close Time:</strong> " + auctionCloseTimeValueDisplay + "</p>");

                if (userBid != null && currentBid != null) {
                    out.println("<p><strong>Your last bid:</strong> " + userBid + "</p>");
                    out.println("<p><strong>Current highest bid:</strong> " + currentBid + "</p>");

                    if (userBid < currentBid) {
                        out.println("<p style='color:red;'>You have been outbid.</p>");
                    } else if (userBid.equals(currentBid)) {
                        out.println("<p style='color:green;'>You are currently the highest bidder.</p>");
                    }
                } else {
                    out.println("<p>No bid information found for this item.</p>");
                }

                // view bid history button (uses itemType + itemIdValue)
                out.println("<form method='get' action='bidHistory.jsp' style='margin-top:10px;'>");
                out.println("<input type='hidden' name='itemType' value='" + itemTypeVal + "'/>");
                out.println("<input type='hidden' name='itemIdValue' value='" + itemIdVal + "'/>");
                out.println("<input type='submit' value='View Bid History'/>");
                out.println("</form>");

                // show bid form only when user is outbid
                if (userBid != null && currentBid != null && userBid < currentBid) {

                    int localCounter = counterValue++;

                    out.println("<hr/>");
                    out.println("<input type='button' value='Create New Bid' " +
                            "onclick='createBid(" + localCounter + ")' " +
                            "id='TopCreateBid" + localCounter + "' style='margin-bottom: 20px;'>");

                    out.println("<form method='post' action='bidPage.jsp'>");
                    out.println("<input type='hidden' name='itemType' value='" + itemTypeVal + "'>");
                    out.println("<input type='hidden' name='itemIdValue' value='" + itemIdVal + "'>");

                    out.println("<label for='setNewBid' id='SetNewBidLabel" + localCounter + "' style='display: none;'>Set Bid (USD): </label>");
                    out.println("<input type='number' name='setNewBid' id='SetNewBid" + localCounter + "' style='display: none;' required>");

                    out.println("<label for='setAutomaticBid' id='SetAutomaticBidLabel" + localCounter + "' style='display: none;'>Set Automatic Bid: </label>");
                    out.println("<select name='setAutomaticBid' id='SetAutomaticBid" + localCounter + "' style='display: none;' required>");
                    out.println("<option value='selectAnItem' disabled selected>Select Item...</option>");
                    out.println("<option value='true'>Yes</option>");
                    out.println("<option value='false'>No</option>");
                    out.println("</select>");

                    out.println("<label for='maxBidPrice' id='SetAutomaticBidPriceLabel" + localCounter + "' style='display: none;'>Set Max Bid Price (USD): </label>");
                    out.println("<input type='number' name='maxBidPrice' id='SetAutomaticBidPrice" + localCounter + "' style='display: none;'>");

                    out.println("<label for='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPriceLabel" + localCounter + "' style='display: none;'>Bid Increment Price (USD): </label>");
                    out.println("<input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice" + localCounter + "' style='display: none;'>");

                    out.println("<input type='button' value='Cancel Bid' onclick='removeBid(" + localCounter + ")' id='cancel" + localCounter + "' style='display: none;'>");
                    out.println("<input type='submit' value='Place Bid' onclick='placeBid(" + localCounter + ")' id='TopPlaceBid" + localCounter + "' style='display: none;'>");
                    out.println("</form>");
                }

                out.println("</div>");
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error loading notifications: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
    }

    con.close();
%>

</body>
</html>
