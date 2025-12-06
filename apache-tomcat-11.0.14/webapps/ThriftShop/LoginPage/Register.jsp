    <!DOCTYPE html>
    <html>

    <head>
        <title>Register</title>
    </head>

    <body>
        <h2>Create Account</h2>
    <form action="<%=request.getContextPath()%>/register" method="POST">
                            Username: <input type="text" name="username" required /> <br />
                            Password: <input type="password" name="password" required /> <br />
                            <input type="submit" value="Register" />
                        </form>
                            <br />
                            <a href="login.jsp">Already have an account? Login here</a>
    </body>

    </html>