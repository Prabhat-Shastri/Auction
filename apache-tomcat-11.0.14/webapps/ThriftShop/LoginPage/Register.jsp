<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - ThriftShop Auction</title>
    <link rel="stylesheet" href="../css/auction-style.css">
</head>
<body>
    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>🏛️ ThriftShop</h1>
                <p>Join our premium auction platform</p>
            </div>
            
            <form action="<%=request.getContextPath()%>/register" method="POST">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" 
                           id="username" 
                           name="username" 
                           class="form-control" 
                           placeholder="Choose a username"
                           required 
                           autofocus>
                </div>
                
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" 
                           id="password" 
                           name="password" 
                           class="form-control" 
                           placeholder="Create a password"
                           required>
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%;">
                    Create Account
                </button>
            </form>
            
            <div class="auth-link">
                Already have an account? <a href="login.jsp">Sign in here</a>
            </div>
        </div>
    </div>
</body>
</html>
