package com.yourpackage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException(e);
        }

        String jdbcUrl = "jdbc:mysql://localhost:3306/thriftShop";
        String dbUser = "root";
        String dbPass = "12345";

        try (Connection con = DriverManager.getConnection(jdbcUrl, dbUser, dbPass)) {
            // Check if username already exists
            String checkSql = "SELECT userIdValue FROM users WHERE usernameValue = ?";
            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setString(1, username);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {
                    // Username already exists
                    response.getWriter().println("Username already exists. <a href='LoginPage/register.jsp'>Try again</a>");
                    return;
                }
            }

            // Insert new user
            String insertSql = "INSERT INTO users (usernameValue, passwordValue) VALUES (?, ?)";
            try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                insertPs.setString(1, username);
                insertPs.setString(2, password);
                insertPs.executeUpdate();
            }

            // Redirect to login page
            response.sendRedirect(request.getContextPath() + "/LoginPage/login.jsp");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
