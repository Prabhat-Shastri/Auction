<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
<%@ page import="java.time.LocalDate,java.time.LocalTime,java.time.LocalDateTime" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    // load MySQL driver
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/thriftShop","root", "12345");
    Statement st = con.createStatement();

    // check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    out.println("<h3>User: " + session.getAttribute("username") + "</h3>");
    out.println("<a href='../WebsitePages/mainPage.jsp'>Main Page</a>");
    out.println("<br/>This is the Tops page<br/><br/>");

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

    // query tops joined with users to get seller username
    String topsQuery =
            "SELECT t.*, u.usernameValue AS sellerUsername " +
                    "FROM tops t " +
                    "JOIN users u ON t.auctionSellerIdValue = u.userIdValue " +
                    "ORDER BY t.topIdValue DESC";

    ResultSet rs = st.executeQuery(topsQuery);
    while (rs.next()) {
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

        out.println("<div>");
        out.println("<p><strong>Seller:</strong> " + sellerUsername + "</p>");
        out.println("<p><strong>Gender:</strong> " + genderValueDisplay + "</p>");
        out.println("<p><strong>Size:</strong> " + sizeValueDisplay + "</p>");
        out.println("<p><strong>Color:</strong> " + colorValueDisplay + "</p>");
        out.println("<p><strong>Front Length:</strong> " + frontLengthValueDisplay + "</p>");
        out.println("<p><strong>Chest Length:</strong> " + chestLengthValueDisplay + "</p>");
        out.println("<p><strong>Sleeve Length:</strong> " + sleeveLengthValueDisplay + "</p>");
        out.println("<p><strong>Description:</strong> " + descriptionValueDisplay + "</p>");
        out.println("<p><strong>Condition:</strong> " + conditionValueDisplay + "</p>");

        if (minimumBidPriceValueDisplay != 0.0f) {
            out.println("<p><strong>Minimum Bid Price: </strong>" + minimumBidPriceValueDisplay + "</p>");
        } else {
            out.println("<p><strong>Minimum Bid Price:</strong> None</p>");
        }

        out.println("<p><strong>Starting or Current Bid Price: </strong>" + startingOrCurrentBidPriceValueDisplay + "</p>");
        out.println("<p><strong>Auction Close Date: </strong>" + auctionCloseDateValueDisplay + "</p>");
        out.println("<p><strong>Auction Close Time: </strong>" + auctionCloseTimeValueDisplay + "</p>");

        out.println("<input type='button' value='Create Bid' onclick='createBid(" + counter + ")' id='TopCreateBid" + counter + "' style='margin-bottom: 100px;'>");

        out.println("<form method='post' action='bidPage.jsp'>");
        out.println("<input type='hidden' name='topIdValue' value='" + topIdValueDisplay + "'>");
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
        out.println("<input type='button' value='Cancel Bid' onclick='removeBid(" + counter + ")' id='cancel" + counter + "' style='display: none;'>");
        out.println("<input type='submit' value='Place Bid' onclick='placeBid(" + counter +")' id='TopPlaceBid" + counter + "' style='display: none;'>");
        out.println("</form>");
        out.println("</div>");

        counter++;
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
