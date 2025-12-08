<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page import="java.time.LocalDate,java.time.LocalTime,java.time.LocalDateTime" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tops - ThriftShop Auction</title>
    <link rel="stylesheet" href="../css/auction-style.css">
</head>
<body>
    <!-- Header -->
    <header class="header">
        <div class="header-container">
            <a href="mainPage.jsp" class="logo">🏛️ ThriftShop</a>
            <nav>
                <ul class="nav-menu">
                    <li><a href="tops.jsp">Tops</a></li>
                    <li><a href="bottoms.jsp">Bottoms</a></li>
                    <li><a href="shoes.jsp">Shoes</a></li>
                    <li><a href="sellers.jsp">Sellers</a></li>
                    <li><a href="notifications.jsp">Notifications</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                    <li><a href="../LoginPage/logout.jsp">Logout</a></li>
                </ul>
            </nav>
            <div class="user-info">👤 <%=session.getAttribute("username")%></div>
        </div>
    </header>

    <div class="container">

<%
    // load MySQL driver
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
    Statement st = con.createStatement();

    // check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }
%>
        <div class="page-header">
    <h1>👔 Tops</h1>
    <p>Browse and bid on premium tops</p>
    <a href="mainPage.jsp" class="btn btn-outline" style="margin-top: 1rem;">← Back to Main Page</a>
</div>
<%

    // Get Show Similars parameters
    String similarId = request.getParameter("similarId");
    String similarSize = request.getParameter("similarSize");
    String similarGender = request.getParameter("similarGender");
    String similarMinPrice = request.getParameter("similarMinPrice");
    String similarMaxPrice = request.getParameter("similarMaxPrice");

    boolean showingSimilar = (similarSize != null && !similarSize.isEmpty() &&
            similarGender != null && !similarGender.isEmpty());

    if (showingSimilar) {
        out.println("<p><strong>Showing Similar Tops:</strong> Gender \"" + similarGender + "\" | Size \"" + similarSize + "\" | Price: $" + similarMinPrice + " - $" + similarMaxPrice);
        out.println("&nbsp;&nbsp;<a href='tops.jsp'>Clear Filter</a></p>");
        out.println("<hr/>");
    }

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
        // submit handled by bidPage.jsp
    }
</script>

<%
    // handle new top auction submit
    String gender = request.getParameter("topGender");
    if (gender != null) {

        // read date and time
        String dateStr = request.getParameter("AuctionCloseDateTops");
        String timeStr = request.getParameter("AuctionCloseTimeTops");

        if (dateStr == null || timeStr == null ||
                dateStr.isEmpty() || timeStr.isEmpty()) {

            out.println("<p style='color:red'>Error. Auction close date or time is missing.</p>");
            out.println("<a href='../WebsitePages/mainPage.jsp'>Go back to Main Page</a>");
            st.close();
            con.close();
            return;
        }

        LocalDate closeDate = LocalDate.parse(dateStr);
        LocalTime closeTime = LocalTime.parse(timeStr);
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
        String size = request.getParameter("topSize");
        String color = request.getParameter("topColor");
        Float frontlength = Float.parseFloat(request.getParameter("FrontLength"));
        Float chestlength = Float.parseFloat(request.getParameter("ChestLength"));
        Float sleevelength = Float.parseFloat(request.getParameter("SleeveLength"));
        String description = request.getParameter("Description");
        String condition = request.getParameter("Condition");
        String minimum = request.getParameter("Minimum");
        String startingorcurrentbidprice = request.getParameter("StartingOrCurrentBidPrice");

        String auctionclosedate = dateStr;
        String auctionclosetime = timeStr;

        if (minimum == null || minimum.isEmpty()) {
            minimum = "0.0";
        }

        String insertTopInformation =
                "INSERT INTO tops " +
                        "(auctionSellerIdValue, genderValue, sizeValue, colorValue, " +
                        " frontLengthValue, chestLengthValue, sleeveLengthValue, " +
                        " descriptionValue, conditionValue, minimumBidPriceValue, " +
                        " startingOrCurrentBidPriceValue, auctionCloseDateValue, auctionCloseTimeValue) " +
                        "VALUES ('" + userIdValue + "','" + gender + "','" + size + "','" + color + "'," +
                        "'" + frontlength + "','" + chestlength + "','" + sleevelength + "'," +
                        "'" + description + "','" + condition + "','" + minimum + "','" +
                        startingorcurrentbidprice + "','" + auctionclosedate + "','" + auctionclosetime + "')";

        st.executeUpdate(insertTopInformation);
    }

    // Build query - with or without similarity filter
    StringBuilder topsQuery = new StringBuilder(
            "SELECT t.*, u.usernameValue AS sellerUsername " +
                    "FROM tops t " +
                    "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                    "WHERE 1=1");

    if (showingSimilar) {
        // Filter by gender
        if (similarGender != null && !similarGender.isEmpty()) {
            String safeGender = similarGender.replace("'", "''");
            topsQuery.append(" AND t.genderValue = '").append(safeGender).append("'");
        }
        // Filter by size
        if (similarSize != null && !similarSize.isEmpty()) {
            String safeSize = similarSize.replace("'", "''");
            topsQuery.append(" AND t.sizeValue = '").append(safeSize).append("'");
        }
        // Filter by price range
        if (similarMinPrice != null && !similarMinPrice.isEmpty()) {
            topsQuery.append(" AND t.minimumBidPriceValue >= ").append(similarMinPrice);
        }
        if (similarMaxPrice != null && !similarMaxPrice.isEmpty()) {
            topsQuery.append(" AND t.minimumBidPriceValue <= ").append(similarMaxPrice);
        }
        // Exclude the original item
        if (similarId != null && !similarId.isEmpty()) {
            topsQuery.append(" AND t.topIdValue != ").append(similarId);
        }
    }

    topsQuery.append(" ORDER BY t.topIdValue DESC");

    ResultSet rs = st.executeQuery(topsQuery.toString());
    boolean found = false;
    
    out.println("<div class='items-grid'>");
    
    while (rs.next()) {
        found = true;
        String sellerUsername  = rs.getString("sellerUsername");
        String topIdValueDisplay = rs.getString("topIdValue");
        String genderValueDisplay = rs.getString("genderValue");
        String sizeValueDisplay = rs.getString("sizeValue");
        String colorValueDisplay = rs.getString("colorValue");
        String frontLengthValueDisplay = rs.getString("frontLengthValue");
        String chestLengthValueDisplay = rs.getString("chestLengthValue");
        String sleeveLengthValueDisplay = rs.getString("sleeveLengthValue");
        String descriptionValueDisplay = rs.getString("descriptionValue");
        String conditionValueDisplay = rs.getString("conditionValue");
        float minimumBidPriceValueDisplay = rs.getFloat("minimumBidPriceValue");
        float startingOrCurrentBidPriceValueDisplay = rs.getFloat("startingOrCurrentBidPriceValue");
        String auctionCloseDateValueDisplay = rs.getString("auctionCloseDateValue");
        String auctionCloseTimeValueDisplay = rs.getString("auctionCloseTimeValue");

        // Calculate price range for Show Similars (±10%)
        double simMinPrice = Math.round(minimumBidPriceValueDisplay * 0.9 * 100.0) / 100.0;
        double simMaxPrice = Math.round(minimumBidPriceValueDisplay * 1.1 * 100.0) / 100.0;

        // Only show minimum bid price (reserve) to the seller who created the auction
        Integer currentUserId = (Integer) session.getAttribute("userIdValue");
        String sellerIdStr = rs.getString("auctionSellerIdValue");
        boolean isSeller = (currentUserId != null && sellerIdStr != null && 
                           currentUserId.toString().equals(sellerIdStr));

        out.println("<div class='item-card'>");
        out.println("<div class='item-image'>👔</div>");
        out.println("<div class='item-body'>");
        out.println("<div class='item-title'>" + (descriptionValueDisplay != null && !descriptionValueDisplay.isEmpty() ? descriptionValueDisplay : "Top #" + topIdValueDisplay) + "</div>");
        out.println("<div class='item-meta'>");
        out.println("<span>👤 Seller: " + sellerUsername + "</span> | ");
        out.println("<span>" + genderValueDisplay + "</span> | ");
        out.println("<span>Size: " + sizeValueDisplay + "</span> | ");
        out.println("<span>Color: " + colorValueDisplay + "</span>");
        out.println("</div>");
        
        out.println("<div style='margin: 1rem 0; padding: 1rem; background: var(--bg-light); border-radius: 8px;'>");
        out.println("<p style='margin: 0.5rem 0;'><strong>📏 Measurements:</strong></p>");
        out.println("<p style='margin: 0.25rem 0; color: var(--text-secondary);'>Front: " + frontLengthValueDisplay + "cm | Chest: " + chestLengthValueDisplay + "cm | Sleeve: " + sleeveLengthValueDisplay + "cm</p>");
        out.println("</div>");
        
        out.println("<p style='margin: 0.5rem 0;'><strong>📝 Description:</strong> " + descriptionValueDisplay + "</p>");
        out.println("<p style='margin: 0.5rem 0;'><strong>✨ Condition:</strong> " + conditionValueDisplay + "</p>");
        
        if (isSeller) {
            if (minimumBidPriceValueDisplay != 0.0f) {
                out.println("<div class='reserve-badge' style='display: inline-block; margin: 0.5rem 0;'>🔒 Reserve: $" + minimumBidPriceValueDisplay + " (Hidden)</div>");
            } else {
                out.println("<div class='reserve-badge' style='display: inline-block; margin: 0.5rem 0;'>No Reserve</div>");
            }
        }
        
        out.println("<div class='item-price'>Current Bid: $" + String.format("%.2f", startingOrCurrentBidPriceValueDisplay) + "</div>");
        out.println("<p style='color: var(--text-secondary); font-size: 0.9rem;'><strong>⏰ Closes:</strong> " + auctionCloseDateValueDisplay + " at " + auctionCloseTimeValueDisplay + "</p>");
        out.println("</div>");
        
        out.println("<div class='item-footer'>");
        out.println("<form method='get' action='tops.jsp' style='display:inline;'>");
        out.println("<input type='hidden' name='similarId' value='" + topIdValueDisplay + "'>");
        out.println("<input type='hidden' name='similarSize' value='" + (sizeValueDisplay != null ? sizeValueDisplay : "") + "'>");
        out.println("<input type='hidden' name='similarGender' value='" + (genderValueDisplay != null ? genderValueDisplay : "") + "'>");
        out.println("<input type='hidden' name='similarMinPrice' value='" + simMinPrice + "'>");
        out.println("<input type='hidden' name='similarMaxPrice' value='" + simMaxPrice + "'>");
        out.println("<button type='submit' class='btn btn-outline' style='font-size: 0.9rem; padding: 0.5rem 1rem;'>🔍 Show Similars</button>");
        out.println("</form>");
        
        out.println("<button type='button' onclick='createBid(" + counter + ")' class='btn btn-primary' id='TopCreateBid" + counter + "' style='font-size: 0.9rem; padding: 0.5rem 1rem;'>💰 Place Bid</button>");

        out.println("<form method='post' action='bidPage.jsp' style='margin-top: 1rem; padding-top: 1rem; border-top: 1px solid var(--border-color);'>");
        out.println("<input type='hidden' name='topIdValue' value='" + topIdValueDisplay + "'>");
        out.println("<div class='form-group' id='SetNewBidLabel" + counter + "' style='display: none;'>");
        out.println("<label for='setNewBid" + counter + "'>Bid Amount (USD)</label>");
        out.println("<input type='number' name='setNewBid' id='SetNewBid" + counter + "' class='form-control' step='0.01' min='" + startingOrCurrentBidPriceValueDisplay + "' required>");
        out.println("</div>");
        out.println("<div class='form-group' id='SetAutomaticBidLabel" + counter + "' style='display: none;'>");
        out.println("<label for='setAutomaticBid" + counter + "'>Enable Automatic Bidding?</label>");
        out.println("<select name='setAutomaticBid' id='SetAutomaticBid" + counter + "' class='form-control' required>");
        out.println("<option value='selectAnItem' disabled selected>Select...</option>");
        out.println("<option value='true'>Yes</option>");
        out.println("<option value='false'>No</option>");
        out.println("</select>");
        out.println("</div>");
        out.println("<div class='form-group' id='SetAutomaticBidPriceLabel" + counter + "' style='display: none;'>");
        out.println("<label for='maxBidPrice" + counter + "'>Maximum Bid (USD)</label>");
        out.println("<input type='number' name='maxBidPrice' id='SetAutomaticBidPrice" + counter + "' class='form-control' step='0.01' min='0'>");
        out.println("</div>");
        out.println("<div class='form-group' id='SetAutomaticBidIncrementPriceLabel" + counter + "' style='display: none;'>");
        out.println("<label for='SetAutomaticBidIncrementPrice" + counter + "'>Bid Increment (USD)</label>");
        out.println("<input type='number' name='SetAutomaticBidIncrementPrice' id='SetAutomaticBidIncrementPrice" + counter + "' class='form-control' step='0.01' min='0'>");
        out.println("</div>");
        out.println("<div style='display: flex; gap: 0.5rem; margin-top: 1rem;'>");
        out.println("<button type='button' onclick='removeBid(" + counter + ")' class='btn btn-outline' id='cancel" + counter + "' style='display: none;'>Cancel</button>");
        out.println("<button type='submit' class='btn btn-primary' id='TopPlaceBid" + counter + "' style='display: none;'>Submit Bid</button>");
        out.println("</div>");
        out.println("</form>");
        out.println("</div>");
        out.println("</div>");

        counter++;
    }

    if (!found) {
        out.println("</div>"); // Close items-grid
        out.println("<div class='card'>");
        out.println("<p style='text-align: center; color: var(--text-secondary); font-size: 1.1rem;'>No tops found matching your criteria.</p>");
        out.println("</div>");
    } else {
        out.println("</div>"); // Close items-grid
    }

    // show alerts from bidPage.jsp
    String alertMessage = (String) session.getAttribute("alertMessage");
    if (alertMessage != null) {
        session.removeAttribute("alertMessage");
        if (alertMessage.equals("success")) {
%>
<script>
    alert("Your bid has been successfully placed!");
</script>
<%
} else if (alertMessage.equals("fail")) {
%>
<script>
    alert("Your bid must be higher than the original price!");
</script>
<%
        }
    }

    rs.close();
    st.close();
    con.close();
%>
    </div>
</body>
</html>
