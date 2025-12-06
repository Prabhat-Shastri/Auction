<%@ page import="java.sql.*" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <title>Sellers</title>
</head>

<body>
<h3>User: <%= session.getAttribute("username") %></h3>

<nav>
    <ul>
        <li><a href="mainPage.jsp">Main Page</a></li>
        <li><a href="notifications.jsp">Notifications</a></li>
        <li><a href="profile.jsp">Profile</a></li>
    </ul>
</nav>

<hr />
<h1>All Sellers</h1>
<h2>Browse by Seller</h2>
<p>Click on a seller to view all their items:</p>

<%
    // Check login
    if (session.getAttribute("username") == null) {
        response.sendRedirect("../LoginPage/login.jsp");
        return;
    }

    String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
    String dbUser  = "root";
    String dbPass  = "12345";

    // Query for sellers who have items
    String query =
            "SELECT DISTINCT u.usernameValue, u.userIdValue " +
                    "FROM users u " +
                    "WHERE u.userIdValue IN (" +
                    "  SELECT auctionSellerIdValue FROM tops " +
                    "  UNION " +
                    "  SELECT auctionSellerIdValue FROM bottoms " +
                    "  UNION " +
                    "  SELECT auctionSellerIdValue FROM shoes" +
                    ") " +
                    "ORDER BY u.usernameValue";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (
                Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass);
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery(query)
        ) {

            out.println("<ul>");

            boolean foundSellers = false;

            while (rs.next()) {
                foundSellers = true;

                String sellerUsername = rs.getString("usernameValue");

                // Always use itemType=any
                String link =
                        "searchResults.jsp?itemType=any&searchSeller=" +
                                java.net.URLEncoder.encode(sellerUsername, "UTF-8");

                out.println("<li><a href='" + link + "'>" + sellerUsername + "</a></li>");
            }

            out.println("</ul>");

            if (!foundSellers) {
                out.println("<p>No sellers found with active listings.</p>");
            }
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
