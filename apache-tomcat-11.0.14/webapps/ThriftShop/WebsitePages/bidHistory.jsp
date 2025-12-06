<%@ page import="java.sql.*" %>

<%
    // check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Bid History</title>
</head>
<body>
<h3>User: <%= username %></h3>
<a href="notifications.jsp">Back to Notifications</a>
<hr/>

<%
    String itemType   = request.getParameter("itemType");     // tops, bottoms, shoes
    String itemIdParam = request.getParameter("itemIdValue"); // id in that table

    if (itemType == null || itemType.trim().isEmpty()
            || itemIdParam == null || itemIdParam.trim().isEmpty()) {

        out.println("<p style='color:red;'>No item selected.</p>");
    } else {

        itemType = itemType.trim();
        int itemIdValue = Integer.parseInt(itemIdParam);

        // decide which table and id column to use
        String tableName;
        String idColumn;

        if ("tops".equals(itemType)) {
            tableName = "tops";
            idColumn  = "topIdValue";
        } else if ("bottoms".equals(itemType)) {
            tableName = "bottoms";
            idColumn  = "bottomIdValue";
        } else if ("shoes".equals(itemType)) {
            tableName = "shoes";
            idColumn  = "shoeIdValue";
        } else {
            out.println("<p style='color:red;'>Invalid item type.</p>");
            tableName = null;
            idColumn = null;
        }

        if (tableName != null) {

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = null;
            PreparedStatement psItem = null;
            PreparedStatement psBids = null;
            ResultSet rsItem = null;
            ResultSet rsBids = null;

            try {
                con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/thriftShop", "root", "12345");

                // 1. get item info (tops or bottoms or shoes)
                String sqlItem =
                        "select i.*, u.usernameValue as sellerUsername " +
                                "from " + tableName + " i " +
                                "join users u on i.auctionSellerIdValue = u.userIdValue " +
                                "where i." + idColumn + " = ?";

                psItem = con.prepareStatement(sqlItem);
                psItem.setInt(1, itemIdValue);
                rsItem = psItem.executeQuery();

                if (rsItem.next()) {
                    String sellerUsername = rsItem.getString("sellerUsername");
                    String genderValueDisplay = rsItem.getString("genderValue");
                    String sizeValueDisplay = rsItem.getString("sizeValue");
                    String colorValueDisplay = rsItem.getString("colorValue");
                    String descriptionValueDisplay = rsItem.getString("descriptionValue");
                    String conditionValueDisplay = rsItem.getString("conditionValue");
                    float minimumBidPriceValueDisplay = rsItem.getFloat("minimumBidPriceValue");
                    float startingOrCurrentBidPriceValueDisplay = rsItem.getFloat("startingOrCurrentBidPriceValue");
                    String auctionCloseDateValueDisplay = rsItem.getString("auctionCloseDateValue");
                    String auctionCloseTimeValueDisplay = rsItem.getString("auctionCloseTimeValue");

                    out.println("<h2>Bid History for " + itemType +
                            " item id: " + itemIdValue + "</h2>");
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
                    out.println("<p><strong>Current Bid Price:</strong> " + startingOrCurrentBidPriceValueDisplay + "</p>");
                    out.println("<p><strong>Auction Close Date:</strong> " + auctionCloseDateValueDisplay + "</p>");
                    out.println("<p><strong>Auction Close Time:</strong> " + auctionCloseTimeValueDisplay + "</p>");
                    out.println("<hr/>");
                } else {
                    out.println("<p style='color:red;'>Item not found.</p>");
                }

                if (rsItem != null) rsItem.close();
                if (psItem != null) psItem.close();

                // 2. get bid history for this item type and id
                String sqlBids =
                        "select b.bidIdValue, b.newBidValue, b.bidIncrementValue, b.bidMaxValue, " +
                                "       b.buyerIdValue, u.usernameValue as bidderUsername " +
                                "from incrementbids b " +
                                "join users u on b.buyerIdValue = u.userIdValue " +
                                "where b.itemTypeValue = ? and b.itemIdValue = ? " +
                                "order by b.bidIdValue desc";

                psBids = con.prepareStatement(sqlBids);
                psBids.setString(1, itemType);
                psBids.setInt(2, itemIdValue);
                rsBids = psBids.executeQuery();

                boolean hasBids = false;

                out.println("<h3>Bid History</h3>");
                out.println("<table border='1' cellpadding='5' cellspacing='0'>");
                out.println("<tr>");
                out.println("<th>Bid ID</th>");
                out.println("<th>Bidder</th>");
                out.println("<th>Bid Amount</th>");
                out.println("<th>Increment</th>");
                out.println("<th>Max Auto Bid</th>");
                out.println("</tr>");

                while (rsBids.next()) {
                    hasBids = true;
                    int bidId = rsBids.getInt("bidIdValue");
                    String bidderUsername = rsBids.getString("bidderUsername");
                    float newBidValue = rsBids.getFloat("newBidValue");
                    String bidIncrementValue = rsBids.getString("bidIncrementValue");
                    String bidMaxValue = rsBids.getString("bidMaxValue");

                    out.println("<tr>");
                    out.println("<td>" + bidId + "</td>");
                    out.println("<td>" + bidderUsername + "</td>");
                    out.println("<td>" + newBidValue + "</td>");
                    out.println("<td>" + bidIncrementValue + "</td>");
                    out.println("<td>" + bidMaxValue + "</td>");
                    out.println("</tr>");
                }

                out.println("</table>");

                if (!hasBids) {
                    out.println("<p>No bids have been placed yet for this item.</p>");
                }

                if (rsBids != null) rsBids.close();
                if (psBids != null) psBids.close();
                if (con != null) con.close();

            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            }
        }
    }
%>

</body>
</html>
