package main.java.auction.dbo;

import java.sql.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import io.github.cdimascio.dotenv.Dotenv;

public class DBConnection {
    private static final Dotenv dotenv = Dotenv.load();
    private static final String HOST = getenvOr("MYSQL_HOST", "localhost");
    private static final String PORT = getenvOr("MYSQL_PORT", "3306");
    private static final String USER = getenvOr("MYSQL_USER", "root");
    private static final String PASS = getenvOr("MYSQL_PASSWORD", "rootpassword");
    private static final String DB   = getenvOr("DB_NAME", "buyme");

    private static final String URL =
    "jdbc:mysql://" + HOST + ":" + PORT + "/" + DB +
    "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS); 
    }

    private static String getenvOr(String k, String d) {
        String v = System.getenv(k);
        return (v == null || v.isEmpty()) ? d : v;
    }
}