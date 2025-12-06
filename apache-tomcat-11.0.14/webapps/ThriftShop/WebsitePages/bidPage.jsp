<%@ page import="jakarta.servlet.http.Part" %>
    <%@ page import="java.io.*" %>
        <%@ page import="java.sql.*" %>
            <%@ page import="jakarta.servlet.annotation.MultipartConfig" %>
                <% Class.forName("com.mysql.jdbc.Driver"); Connection
                    con=DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root", "12345" );
                    Statement st=con.createStatement(); Integer
                    topIdValue=Integer.parseInt(request.getParameter("topIdValue")); if(topIdValue> 0) {
                    Float setnewbid = Float.parseFloat(request.getParameter("setNewBid"));
                    Integer userIdValue = (Integer) session.getAttribute("userIdValue");
                    String setautomaticbidincrementprice = request.getParameter("SetAutomaticBidIncrementPrice");
                    String maxbidprice = request.getParameter("maxBidPrice");

                    String returnCurrentBidPrice = "select startingOrCurrentBidPriceValue from tops where topIdValue =
                    '" + topIdValue + "'";
                    ResultSet currentBidPrice = st.executeQuery(returnCurrentBidPrice);

                    if(currentBidPrice.next()) {
                    Float currentBidPriceValue = currentBidPrice.getFloat("startingOrCurrentBidPriceValue");
                    if(setnewbid > currentBidPriceValue) {
                    String insertPlaceBidInformation = "insert into topsIncrementBids (topIdValue, buyerIdValue,
                    newBidValue, bidIncrementValue, bidMaxValue) values ('" + topIdValue + "','" + userIdValue + "' ,'"
                    + setnewbid + "' ,'" + setautomaticbidincrementprice + "','" + maxbidprice + "')";
                    int insertedRows = st.executeUpdate(insertPlaceBidInformation);
                    String insertUpdatedBidInformation = "update tops set startingOrCurrentBidPriceValue = '" +
                    setnewbid + "' where topIdValue = '" + topIdValue + "'";
                    int updatedRows = st.executeUpdate(insertUpdatedBidInformation);
                    session.setAttribute("alertMessage", "success");
                    }
                    else {
                    session.setAttribute("alertMessage", "fail");
                    }
                    }
                    }

                    st.close();
                    con.close();
                    response.sendRedirect("tops.jsp");
                    %>