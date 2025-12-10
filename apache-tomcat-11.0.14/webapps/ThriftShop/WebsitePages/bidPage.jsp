<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%
    if (session.getAttribute("userIdValue") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

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

    String topIdParam = request.getParameter("topIdValue");

    if (topIdParam != null && !topIdParam.trim().isEmpty()) {

        Integer topIdValue = Integer.parseInt(topIdParam);
        Float setnewbid = Float.parseFloat(request.getParameter("setNewBid"));
        Integer userIdValue = (Integer) session.getAttribute("userIdValue");
        String setautomaticbidincrementprice = request.getParameter("SetAutomaticBidIncrementPrice");
        String maxbidprice = request.getParameter("maxBidPrice");

        // get current bid from tops
        String returnCurrentBidPrice =
                "select startingOrCurrentBidPriceValue " +
                        "from tops where topIdValue = " + topIdValue;
        ResultSet currentBidPrice = st.executeQuery(returnCurrentBidPrice);

        if (currentBidPrice.next()) {
            Float currentBidPriceValue =
                    currentBidPrice.getFloat("startingOrCurrentBidPriceValue");

            if (setnewbid > currentBidPriceValue) {

                //use itemTypeValue + itemIdValue
                String insertSql =
                        "insert into incrementbids " +
                                " (buyerIdValue, newBidValue, bidIncrementValue, bidMaxValue, " +
                                "  itemTypeValue, itemIdValue) " +
                                " values (?, ?, ?, ?, ?, ?)";

                PreparedStatement psInsert = con.prepareStatement(insertSql);
                psInsert.setInt(1, userIdValue);
                psInsert.setFloat(2, setnewbid);
                psInsert.setString(3, setautomaticbidincrementprice);
                psInsert.setString(4, maxbidprice);
                psInsert.setString(5, "tops");
                psInsert.setInt(6, topIdValue);
                psInsert.executeUpdate();
                psInsert.close();

                String updateSql =
                        "update tops set startingOrCurrentBidPriceValue = ? " +
                                "where topIdValue = ?";
                PreparedStatement psUpdate = con.prepareStatement(updateSql);
                psUpdate.setFloat(1, setnewbid);
                psUpdate.setInt(2, topIdValue);
                psUpdate.executeUpdate();
                psUpdate.close();

                session.setAttribute("alertMessage", "success");
            } else {
                session.setAttribute("alertMessage", "fail");
            }
        }
        currentBidPrice.close();
    }

    st.close();
    con.close();

    response.sendRedirect("tops.jsp");
%>
