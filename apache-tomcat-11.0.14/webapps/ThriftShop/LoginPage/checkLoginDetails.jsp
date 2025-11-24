<%@ page import ="java.sql.*" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root",
"Xcrafty!3my");
Statement st = con.createStatement();
ResultSet rs;
rs = st.executeQuery("select * from users where usernameValue ='" + username + "' and passwordValue='" + password + "'");
if (rs.next()) {
session.setAttribute("user", username); 
out.println("welcome " + username);
out.println("<a href='logout.jsp'>Log out</a>");
response.sendRedirect("success.jsp");
} else {
out.println("Invalid password <a href='login.jsp'>try again</a>");
}
%>