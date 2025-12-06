<%
if ((session.getAttribute("username") == null)) {
%>
You are not logged in<br/>
<a href="login.jsp">Please Login</a>
<%} else {
%>
        Welcome <%=session.getAttribute("username")%>
            session.
            <a href='logout.jsp'>Log out</a>
            <a href='../WebsitePages/mainPage.jsp'>Main Page</a>
<%
}
%>