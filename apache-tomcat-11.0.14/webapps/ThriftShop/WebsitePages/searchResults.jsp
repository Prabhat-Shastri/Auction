<%@ page import="java.sql.*,java.util.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Search Results</title>
</head>
<body>
<h3>Search Results</h3>
<a href="mainPage.jsp">Back to Main Page</a>
<hr />

<%
    String itemType  = request.getParameter("itemType");   // tops, bottoms, shoes, any
    String sortBy    = request.getParameter("sortBy");     // price, type
    String sortOrder = request.getParameter("sortOrder");  // asc, desc

    // Parameters for "Show Similars" feature
    String similarTo = request.getParameter("similarTo");
    String similarId = request.getParameter("similarId");
    String similarSize = request.getParameter("similarSize");
    String similarGender = request.getParameter("similarGender");
    String similarMinPrice = request.getParameter("similarMinPrice");
    String similarMaxPrice = request.getParameter("similarMaxPrice");

    if (sortOrder == null || sortOrder.trim().isEmpty()) {
        sortOrder = "asc";
    }

    boolean showingSimilar = (similarTo != null && !similarTo.isEmpty() &&
            similarSize != null && !similarSize.isEmpty());
%>

<% if (showingSimilar) { %>
<p><strong>Showing Similar Items:</strong> Gender "<%= similarGender %>" | Size "<%= similarSize %>" | Price: $<%= similarMinPrice %> - $<%= similarMaxPrice %>
    &nbsp;&nbsp;<a href="searchResults.jsp?itemType=<%= itemType != null ? itemType : "any" %>">Clear Filter</a>
</p>
<hr />
<% } %>

<form method="get" action="searchResults.jsp" style="margin-bottom: 15px;">
    <input type="hidden" name="itemType" value="<%= itemType == null ? "" : itemType %>">
    <% if (showingSimilar) { %>
    <input type="hidden" name="similarTo" value="<%= similarTo %>">
    <input type="hidden" name="similarId" value="<%= similarId %>">
    <input type="hidden" name="similarSize" value="<%= similarSize %>">
    <input type="hidden" name="similarGender" value="<%= similarGender %>">
    <input type="hidden" name="similarMinPrice" value="<%= similarMinPrice %>">
    <input type="hidden" name="similarMaxPrice" value="<%= similarMaxPrice %>">
    <% } %>

    <label>Sort by:</label>
    <select name="sortBy">
        <option value="" <%= (sortBy == null || sortBy.isEmpty()) ? "selected" : "" %>>Default</option>
        <option value="price" <%= "price".equalsIgnoreCase(sortBy) ? "selected" : "" %>>Price</option>
        <option value="type"  <%= "type".equalsIgnoreCase(sortBy)  ? "selected" : "" %>>Type (only Any)</option>
    </select>

    <select name="sortOrder">
        <option value="asc"  <%= !"desc".equalsIgnoreCase(sortOrder) ? "selected" : "" %>>Ascending</option>
        <option value="desc" <%=  "desc".equalsIgnoreCase(sortOrder) ? "selected" : "" %>>Descending</option>
    </select>

    <input type="submit" value="Apply" />
</form>

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
        // handled by bidPage.jsp
    }
</script>

<%
    if (itemType == null || itemType.trim().isEmpty()) {
        out.println("<p>Please select an item type to search.</p>");
    } else {

        itemType = itemType.trim();

        String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
        String dbUser  = "root";
        String dbPass  = "12345";

        Class.forName("com.mysql.cj.jdbc.Driver");

        int counter = 0;

        if ("any".equals(itemType)) {

            try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
                 Statement st = con.createStatement()) {

                String gender      = request.getParameter("searchGender");
                String size        = request.getParameter("searchSize");
                String color       = request.getParameter("searchColor");
                String description = request.getParameter("searchDescription");
                String condition   = request.getParameter("searchCondition");
                String minPrice    = request.getParameter("searchMinPrice");
                String maxPrice    = request.getParameter("searchMaxPrice");
                String seller      = request.getParameter("searchSeller");

                if (gender != null)      gender      = gender.trim();
                if (size != null)        size        = size.trim();
                if (color != null)       color       = color.trim();
                if (description != null) description = description.trim();
                if (condition != null)   condition   = condition.trim();
                if (minPrice != null)    minPrice    = minPrice.trim();
                if (maxPrice != null)    maxPrice    = maxPrice.trim();
                if (seller != null)      seller      = seller.trim();

                if ("Any Gender".equalsIgnoreCase(gender)) gender = null;
                if ("Any Size".equalsIgnoreCase(size))     size   = null;
                if ("Any Color".equalsIgnoreCase(color))   color  = null;
                if ("Any Seller".equalsIgnoreCase(seller)) seller = null;

                String safeSeller = null;
                if (seller != null && !seller.isEmpty()) {
                    safeSeller = seller.replace("'", "''");
                }

                if (showingSimilar) {
                    size = similarSize;
                    gender = similarGender;
                    minPrice = similarMinPrice;
                    maxPrice = similarMaxPrice;
                }

                StringBuilder whereT = new StringBuilder(" WHERE 1=1");
                StringBuilder whereB = new StringBuilder(" WHERE 1=1");
                StringBuilder whereS = new StringBuilder(" WHERE 1=1");

                if (gender != null && !gender.isEmpty()) {
                    String safe = gender.replace("'", "''");
                    whereT.append(" AND t.genderValue = '").append(safe).append("'");
                    whereB.append(" AND b.genderValue = '").append(safe).append("'");
                    whereS.append(" AND s.genderValue = '").append(safe).append("'");
                }
                if (size != null && !size.isEmpty()) {
                    String safe = size.replace("'", "''");
                    whereT.append(" AND t.sizeValue = '").append(safe).append("'");
                    whereB.append(" AND b.sizeValue = '").append(safe).append("'");
                    whereS.append(" AND s.sizeValue = '").append(safe).append("'");
                }
                if (color != null && !color.isEmpty()) {
                    String safe = color.replace("'", "''");
                    whereT.append(" AND t.colorValue = '").append(safe).append("'");
                    whereB.append(" AND b.colorValue = '").append(safe).append("'");
                    whereS.append(" AND s.colorValue = '").append(safe).append("'");
                }
                if (description != null && !description.isEmpty()) {
                    String safeDesc = description.replace("'", "''");
                    whereT.append(" AND t.descriptionValue LIKE '%").append(safeDesc).append("%'");
                    whereB.append(" AND b.descriptionValue LIKE '%").append(safeDesc).append("%'");
                    whereS.append(" AND s.descriptionValue LIKE '%").append(safeDesc).append("%'");
                }
                if (condition != null && !condition.isEmpty()) {
                    String safe = condition.replace("'", "''");
                    whereT.append(" AND t.conditionValue = '").append(safe).append("'");
                    whereB.append(" AND b.conditionValue = '").append(safe).append("'");
                    whereS.append(" AND s.conditionValue = '").append(safe).append("'");
                }
                if (minPrice != null && !minPrice.isEmpty()) {
                    whereT.append(" AND t.minimumBidPriceValue >= ").append(minPrice);
                    whereB.append(" AND b.minimumBidPriceValue >= ").append(minPrice);
                    whereS.append(" AND s.minimumBidPriceValue >= ").append(minPrice);
                }
                if (maxPrice != null && !maxPrice.isEmpty()) {
                    whereT.append(" AND t.minimumBidPriceValue <= ").append(maxPrice);
                    whereB.append(" AND b.minimumBidPriceValue <= ").append(maxPrice);
                    whereS.append(" AND s.minimumBidPriceValue <= ").append(maxPrice);
                }
                if (safeSeller != null) {
                    whereT.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                    whereB.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                    whereS.append(" AND u.usernameValue = '").append(safeSeller).append("'");
                }

                if (showingSimilar && similarId != null && !similarId.isEmpty()) {
                    if ("tops".equals(similarTo)) {
                        whereT.append(" AND t.topIdValue != ").append(similarId);
                    } else if ("bottoms".equals(similarTo)) {
                        whereB.append(" AND b.bottomIdValue != ").append(similarId);
                    } else if ("shoes".equals(similarTo)) {
                        whereS.append(" AND s.shoeIdValue != ").append(similarId);
                    }
                }

                String sqlTops =
                        "SELECT 'tops' AS itemType, t.topIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " t.genderValue AS genderValue, t.sizeValue AS sizeValue, t.colorValue AS colorValue, " +
                                " t.descriptionValue AS descriptionValue, t.conditionValue AS conditionValue, " +
                                " t.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM tops t JOIN users u ON t.auctionSellerIdValue = u.userIdValue" +
                                whereT.toString();

                String sqlBottoms =
                        "SELECT 'bottoms' AS itemType, b.bottomIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " b.genderValue AS genderValue, b.sizeValue AS sizeValue, b.colorValue AS colorValue, " +
                                " b.descriptionValue AS descriptionValue, b.conditionValue AS conditionValue, " +
                                " b.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM bottoms b JOIN users u ON b.auctionSellerIdValue = u.userIdValue" +
                                whereB.toString();

                String sqlShoes =
                        "SELECT 'shoes' AS itemType, s.shoeIdValue AS itemId, u.usernameValue AS sellerUsername, " +
                                " s.genderValue AS genderValue, s.sizeValue AS sizeValue, s.colorValue AS colorValue, " +
                                " s.descriptionValue AS descriptionValue, s.conditionValue AS conditionValue, " +
                                " s.minimumBidPriceValue AS minimumBidPriceValue " +
                                "FROM shoes s JOIN users u ON s.auctionSellerIdValue = u.userIdValue" +
                                whereS.toString();

                String orderClause = " ORDER BY itemType, itemId";

                if ("price".equalsIgnoreCase(sortBy)) {
                    if ("desc".equalsIgnoreCase(sortOrder)) {
                        orderClause = " ORDER BY minimumBidPriceValue DESC, itemType, itemId";
                    } else {
                        orderClause = " ORDER BY minimumBidPriceValue ASC, itemType, itemId";
                    }
                } else if ("type".equalsIgnoreCase(sortBy)) {
                    if ("desc".equalsIgnoreCase(sortOrder)) {
                        orderClause = " ORDER BY itemType DESC, itemId";
                    } else {
                        orderClause = " ORDER BY itemType ASC, itemId";
                    }
                }

                String finalSql =
                        sqlTops + " UNION ALL " +
                                sqlBottoms + " UNION ALL " +
                                sqlShoes + orderClause;

                ResultSet rs = st.executeQuery(finalSql);
                boolean found = false;

                while (rs.next()) {
                    found = true;

                    int currentCounter = counter++;

                    String sellerUsername = rs.getString("sellerUsername");
                    String sellerLink =
                            "searchResults.jsp?itemType=any&searchSeller=" +
                                    java.net.URLEncoder.encode(sellerUsername, "UTF-8");

                    String currentItemType = rs.getString("itemType");
                    String itemId = rs.getString("itemId");
                    String idParamName = null;
                    if ("tops".equals(currentItemType)) {
                        idParamName = "topIdValue";
                    } else if ("bottoms".equals(currentItemType)) {
                        idParamName = "bottomIdValue";
                    } else if ("shoes".equals(currentItemType)) {
                        idParamName = "shoeIdValue";
                    }

                    double price = rs.getDouble("minimumBidPriceValue");
                    double simMinPrice = Math.round(price * 0.9 * 100.0) / 100.0;
                    double simMaxPrice = Math.round(price * 1.1 * 100.0) / 100.0;
                    String itemSize = rs.getString("sizeValue");
                    String itemGender = rs.getString("genderValue");
%>

<div style="border:1px solid #ccc; margin:10px; padding:10px;">
    <p><strong>Item Type:</strong> <%= rs.getString("itemType") %></p>

    <p><strong>Seller:</strong>
        <a href="<%= sellerLink %>"><%= sellerUsername %></a>
    </p>

    <p><strong>Gender:</strong> <%= rs.getString("genderValue") %></p>
    <p><strong>Size:</strong> <%= rs.getString("sizeValue") %></p>
    <p><strong>Color:</strong> <%= rs.getString("colorValue") %></p>
    <p><strong>Description:</strong> <%= rs.getString("descriptionValue") %></p>
    <p><strong>Condition:</strong> <%= rs.getString("conditionValue") %></p>
    <p><strong>Price:</strong> $<%= rs.getString("minimumBidPriceValue") %></p>

    <form method="get" action="bidHistory.jsp" style="display:inline;">
        <input type="hidden" name="itemType" value="<%= currentItemType %>" />
        <input type="hidden" name="itemIdValue" value="<%= itemId %>" />
        <input type="submit" value="View Bid History" />
    </form>

    <form method="get" action="searchResults.jsp" style="display:inline;">
        <input type="hidden" name="itemType" value="any" />
        <input type="hidden" name="similarTo" value="<%= currentItemType %>" />
        <input type="hidden" name="similarId" value="<%= itemId %>" />
        <input type="hidden" name="similarSize" value="<%= itemSize != null ? itemSize : "" %>" />
        <input type="hidden" name="similarGender" value="<%= itemGender != null ? itemGender : "" %>" />
        <input type="hidden" name="similarMinPrice" value="<%= simMinPrice %>" />
        <input type="hidden" name="similarMaxPrice" value="<%= simMaxPrice %>" />
        <input type="submit" value="Show Similars" />
    </form>

    <br/><br/>

    <input type='button'
           value='Create Bid'
           onclick='createBid(<%= currentCounter %>)'
           id='TopCreateBid<%= currentCounter %>'
           style='margin-bottom: 20px;'>

    <form method='post' action='bidPage.jsp'>
        <% if (idParamName != null) { %>
        <input type='hidden' name='<%= idParamName %>' value='<%= itemId %>'>
        <% } %>

        <label for='setNewBid' id='SetNewBidLabel<%= currentCounter %>' style='display: none;'>Set Bid (USD): </label>
        <input type='number' name='setNewBid' id='SetNewBid<%= currentCounter %>' style='display: none;' required>

        <label for='setAutomaticBid' id='SetAutomaticBidLabel<%= currentCounter %>' style='display: none;'>Set Automatic Bid: </label>
        <select name='setAutomaticBid' id='SetAutomaticBid<%= currentCounter %>' style='display: none;' required>
            <option value='selectAnItem' disabled selected>Select Item...</option>
            <option value='true' id='true'>Yes</option>
            <option value='false' id='false'>No</option>
        </select>

        <label for='maxBidPrice' id='SetAutomaticBidPriceLabel<%= currentCounter %>' style='display: none;'>Set Max Bid Price (USD): </label>
        <input type='number' name='maxBidPrice' id='SetAutomaticBidPrice<%= currentCounter %>' style='display: none;'>

        <label for='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPriceLabel<%= currentCounter %>' style='display: none;'>Set Bid Increment Price (USD): </label>
        <input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice<%= currentCounter %>' style='display: none;'>

        <input type='button' value='Cancel Bid' onclick='removeBid(<%= currentCounter %>)' id='cancel<%= currentCounter %>' style='display: none;'>
        <input type='submit' value='Place Bid' onclick='placeBid(<%= currentCounter %>)' id='TopPlaceBid<%= currentCounter %>' style='display: none;'>
    </form>
</div>

<%
        }

        if (!found) {
            out.println("<p>No items found matching your criteria.</p>");
        }

        rs.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }

} else {

    try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
         Statement st = con.createStatement()) {

        String seller = request.getParameter("searchSeller");
        if (seller != null) seller = seller.trim();
        if ("Any Seller".equalsIgnoreCase(seller)) seller = null;
        boolean filterBySeller = (seller != null && !seller.isEmpty());
        String safeSeller = null;
        if (filterBySeller) safeSeller = seller.replace("'", "''");

        String gender      = null;
        String size        = null;
        String color       = null;
        String description = null;
        String condition   = null;

        String frontLen  = null;
        String chestLen  = null;
        String sleeveLen = null;

        String waistLen   = null;
        String inseamLen  = null;
        String outseamLen = null;
        String hipLen     = null;
        String riseLen    = null;

        String minPrice = request.getParameter("searchMinPrice");
        String maxPrice = request.getParameter("searchMaxPrice");

        if ("tops".equals(itemType)) {
            gender      = request.getParameter("searchTopGender");
            size        = request.getParameter("searchTopSize");
            color       = request.getParameter("searchTopColor");
            frontLen    = request.getParameter("searchTopFrontLength");
            chestLen    = request.getParameter("searchTopChestLength");
            sleeveLen   = request.getParameter("searchTopSleeveLength");
            description = request.getParameter("searchTopDescription");
            condition   = request.getParameter("searchTopCondition");
        } else if ("bottoms".equals(itemType)) {
            gender      = request.getParameter("searchBottomGender");
            size        = request.getParameter("searchBottomSize");
            color       = request.getParameter("searchBottomColor");
            waistLen    = request.getParameter("searchBottomWaistLength");
            inseamLen   = request.getParameter("searchBottomInseamLength");
            outseamLen  = request.getParameter("searchBottomOutseamLength");
            hipLen      = request.getParameter("searchBottomHipLength");
            riseLen     = request.getParameter("searchBottomRiseLength");
            description = request.getParameter("searchBottomDescription");
            condition   = request.getParameter("searchBottomCondition");
        } else if ("shoes".equals(itemType)) {
            gender      = request.getParameter("searchShoeGender");
            size        = request.getParameter("searchShoeSize");
            color       = request.getParameter("searchShoeColor");
            description = request.getParameter("searchShoeDescription");
            condition   = request.getParameter("searchShoeCondition");
        }

        if (gender != null)      gender      = gender.trim();
        if (size != null)        size        = size.trim();
        if (color != null)       color       = color.trim();
        if (frontLen != null)    frontLen    = frontLen.trim();
        if (chestLen != null)    chestLen    = chestLen.trim();
        if (sleeveLen != null)   sleeveLen   = sleeveLen.trim();
        if (waistLen != null)    waistLen    = waistLen.trim();
        if (inseamLen != null)   inseamLen   = inseamLen.trim();
        if (outseamLen != null)  outseamLen  = outseamLen.trim();
        if (hipLen != null)      hipLen      = hipLen.trim();
        if (riseLen != null)     riseLen     = riseLen.trim();
        if (description != null) description = description.trim();
        if (condition != null)   condition   = condition.trim();
        if (minPrice != null)    minPrice    = minPrice.trim();
        if (maxPrice != null)    maxPrice    = maxPrice.trim();

        if ("Any Gender".equalsIgnoreCase(gender)) gender = null;
        if ("Any Size".equalsIgnoreCase(size))     size   = null;
        if ("Any Color".equalsIgnoreCase(color))   color  = null;

        if (showingSimilar) {
            size = similarSize;
            gender = similarGender;
            minPrice = similarMinPrice;
            maxPrice = similarMaxPrice;
        }

        String tableAlias = "i";
        StringBuilder sql =
                new StringBuilder("SELECT " + tableAlias + ".*, u.usernameValue AS sellerUsername " +
                        "FROM " + itemType + " " + tableAlias +
                        " JOIN users u ON " + tableAlias + ".auctionSellerIdValue = u.userIdValue" +
                        " WHERE 1=1");

        if (gender != null && !gender.isEmpty()) {
            String safe = gender.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".genderValue = '").append(safe).append("'");
        }
        if (size != null && !size.isEmpty()) {
            String safe = size.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".sizeValue = '").append(safe).append("'");
        }
        if (color != null && !color.isEmpty()) {
            String safe = color.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".colorValue = '").append(safe).append("'");
        }

        if ("tops".equals(itemType)) {
            if (frontLen != null && !frontLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".frontLengthValue = ").append(frontLen);
            }
            if (chestLen != null && !chestLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".chestLengthValue = ").append(chestLen);
            }
            if (sleeveLen != null && !sleeveLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".sleeveLengthValue = ").append(sleeveLen);
            }
        }

        if ("bottoms".equals(itemType)) {
            if (waistLen != null && !waistLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".waistLengthValue = ").append(waistLen);
            }
            if (inseamLen != null && !inseamLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".inseamLengthValue = ").append(inseamLen);
            }
            if (outseamLen != null && !outseamLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".outseamLengthValue = ").append(outseamLen);
            }
            if (hipLen != null && !hipLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".hipLengthValue = ").append(hipLen);
            }
            if (riseLen != null && !riseLen.isEmpty()) {
                sql.append(" AND ").append(tableAlias).append(".riseLengthValue = ").append(riseLen);
            }
        }

        if (description != null && !description.isEmpty()) {
            String safeDesc = description.replace("'", "''");
            sql.append(" AND ").append(tableAlias)
                    .append(".descriptionValue LIKE '%").append(safeDesc).append("%'");
        }
        if (condition != null && !condition.isEmpty()) {
            String safe = condition.replace("'", "''");
            sql.append(" AND ").append(tableAlias).append(".conditionValue = '").append(safe).append("'");
        }
        if (minPrice != null && !minPrice.isEmpty()) {
            sql.append(" AND ").append(tableAlias).append(".minimumBidPriceValue >= ").append(minPrice);
        }
        if (maxPrice != null && !maxPrice.isEmpty()) {
            sql.append(" AND ").append(tableAlias).append(".minimumBidPriceValue <= ").append(maxPrice);
        }

        if (filterBySeller && safeSeller != null) {
            sql.append(" AND u.usernameValue = '").append(safeSeller).append("'");
        }

        if (showingSimilar && similarId != null && !similarId.isEmpty() && itemType.equals(similarTo)) {
            String idColumn = null;
            if ("tops".equals(itemType)) {
                idColumn = "topIdValue";
            } else if ("bottoms".equals(itemType)) {
                idColumn = "bottomIdValue";
            } else if ("shoes".equals(itemType)) {
                idColumn = "shoeIdValue";
            }
            if (idColumn != null) {
                sql.append(" AND ").append(tableAlias).append(".").append(idColumn).append(" != ").append(similarId);
            }
        }

        if ("price".equalsIgnoreCase(sortBy)) {
            if ("desc".equalsIgnoreCase(sortOrder)) {
                sql.append(" ORDER BY ").append(tableAlias).append(".minimumBidPriceValue DESC");
            } else {
                sql.append(" ORDER BY ").append(tableAlias).append(".minimumBidPriceValue ASC");
            }
        } else {
            if ("tops".equals(itemType)) {
                sql.append(" ORDER BY ").append(tableAlias).append(".topIdValue");
            } else if ("bottoms".equals(itemType)) {
                sql.append(" ORDER BY ").append(tableAlias).append(".bottomIdValue");
            } else if ("shoes".equals(itemType)) {
                sql.append(" ORDER BY ").append(tableAlias).append(".shoeIdValue");
            }
        }

        ResultSet rs = st.executeQuery(sql.toString());
        boolean found = false;

        String idCol = null;
        if ("tops".equals(itemType)) {
            idCol = "topIdValue";
        } else if ("bottoms".equals(itemType)) {
            idCol = "bottomIdValue";
        } else if ("shoes".equals(itemType)) {
            idCol = "shoeIdValue";
        }

        String idParamName = idCol;

        while (rs.next()) {
            found = true;

            int currentCounter = counter++;

            String sellerUsername = rs.getString("sellerUsername");
            String sellerLink =
                    "searchResults.jsp?itemType=any&searchSeller=" +
                            java.net.URLEncoder.encode(sellerUsername, "UTF-8");

            double price = rs.getDouble("minimumBidPriceValue");
            double simMinPrice = Math.round(price * 0.9 * 100.0) / 100.0;
            double simMaxPrice = Math.round(price * 1.1 * 100.0) / 100.0;
            String itemSize = rs.getString("sizeValue");
            String itemGender = rs.getString("genderValue");
            String itemId = rs.getString(idCol);
%>

<div style="border:1px solid #ccc; margin:10px; padding:10px;">
    <% if (idCol != null) { %>
    <p><strong>Item ID:</strong> <%= rs.getString(idCol) %></p>
    <% } %>

    <p><strong>Seller:</strong>
        <a href="<%= sellerLink %>"><%= sellerUsername %></a>
    </p>

    <p><strong>Gender:</strong> <%= rs.getString("genderValue") %></p>
    <p><strong>Size:</strong> <%= rs.getString("sizeValue") %></p>
    <p><strong>Color:</strong> <%= rs.getString("colorValue") %></p>
    <p><strong>Description:</strong> <%= rs.getString("descriptionValue") %></p>
    <p><strong>Condition:</strong> <%= rs.getString("conditionValue") %></p>
    <p><strong>Price:</strong> $<%= rs.getString("minimumBidPriceValue") %></p>

    <% if (idCol != null && idParamName != null) { %>
    <form method="get" action="bidHistory.jsp" style="display:inline;">
        <input type="hidden" name="itemType" value="<%= itemType %>" />
        <input type="hidden" name="itemIdValue" value="<%= rs.getString(idCol) %>" />
        <input type="submit" value="View Bid History" />
    </form>
    <% } %>

    <form method="get" action="searchResults.jsp" style="display:inline;">
        <input type="hidden" name="itemType" value="any" />
        <input type="hidden" name="similarTo" value="<%= itemType %>" />
        <input type="hidden" name="similarId" value="<%= itemId != null ? itemId : "" %>" />
        <input type="hidden" name="similarSize" value="<%= itemSize != null ? itemSize : "" %>" />
        <input type="hidden" name="similarGender" value="<%= itemGender != null ? itemGender : "" %>" />
        <input type="hidden" name="similarMinPrice" value="<%= simMinPrice %>" />
        <input type="hidden" name="similarMaxPrice" value="<%= simMaxPrice %>" />
        <input type="submit" value="Show Similars" />
    </form>

    <br/><br/>

    <input type='button'
           value='Create Bid'
           onclick='createBid(<%= currentCounter %>)'
           id='TopCreateBid<%= currentCounter %>'
           style='margin-bottom: 20px;'>

    <form method='post' action='bidPage.jsp'>
        <% if (idCol != null && idParamName != null) { %>
        <input type='hidden' name='<%= idParamName %>' value='<%= rs.getString(idCol) %>'>
        <% } %>

        <label for='setNewBid' id='SetNewBidLabel<%= currentCounter %>' style='display: none;'>Set Bid (USD): </label>
        <input type='number' name='setNewBid' id='SetNewBid<%= currentCounter %>' style='display: none;' required>

        <label for='setAutomaticBid' id='SetAutomaticBidLabel<%= currentCounter %>' style='display: none;'>Set Automatic Bid: </label>
        <select name='setAutomaticBid' id='SetAutomaticBid<%= currentCounter %>' style='display: none;' required>
            <option value='selectAnItem' disabled selected>Select Item...</option>
            <option value='true' id='true'>Yes</option>
            <option value='false' id='false'>No</option>
        </select>

        <label for='maxBidPrice' id='SetAutomaticBidPriceLabel<%= currentCounter %>' style='display: none;'>Set Max Bid Price (USD): </label>
        <input type='number' name='maxBidPrice' id='SetAutomaticBidPrice<%= currentCounter %>' style='display: none;'>

        <label for='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPriceLabel<%= currentCounter %>' style='display: none;'>Set Bid Increment Price (USD): </label>
        <input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice<%= currentCounter %>' style='display: none;'>

        <input type='button' value='Cancel Bid' onclick='removeBid(<%= currentCounter %>)' id='cancel<%= currentCounter %>' style='display: none;'>
        <input type='submit' value='Place Bid' onclick='placeBid(<%= currentCounter %>)' id='TopPlaceBid<%= currentCounter %>' style='display: none;'>
    </form>
</div>

<%
                }

                if (!found) {
                    out.println("<p>No items found matching your criteria.</p>");
                }

                rs.close();
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
            }
        }
    }
%>

</body>
</html>
