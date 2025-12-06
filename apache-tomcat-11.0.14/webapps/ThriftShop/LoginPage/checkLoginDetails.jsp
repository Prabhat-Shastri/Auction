<%@ page import ="java.sql.*" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
Class.forName("com.mysql.jdbc.Driver");
Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/thriftShop","root",
"12345");
Statement st = con.createStatement();
ResultSet rs;
rs = st.executeQuery("select userIdValue from users where usernameValue ='" + username + "' and passwordValue='" + password + "'");
if (rs.next()) {
int userIdValue = rs.getInt("userIdValue");
session.setAttribute("userIdValue", userIdValue);
session.setAttribute("username", username); 
out.println("welcome " + username);
response.sendRedirect("success.jsp");
} else {
out.println("Invalid password <a href='login.jsp'>try again</a>");
}

rs.close();
st.close();
con.close();
%>