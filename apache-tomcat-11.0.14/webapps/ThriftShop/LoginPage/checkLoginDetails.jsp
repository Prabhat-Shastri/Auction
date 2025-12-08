<%@ page import ="java.sql.*" %>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
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