// src/main/java/auction/dbo/DBConnection.java
package auction.dbo;

import java.sql.*;
import io.github.cdimascio.dotenv.Dotenv;

public class DBConnection {
    private static final Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();

    private static String env(String k, String d) {
        String v = System.getenv(k);
        if (v == null || v.isEmpty()) v = dotenv.get(k);
        return (v == null || v.isEmpty()) ? d : v;
    }

    private static final String HOST = env("MYSQL_HOST", "localhost");
    private static final String PORT = env("MYSQL_PORT", "3306");
    private static final String USER = env("MYSQL_USER", "root");
    private static final String PASS = env("MYSQL_PASS", "");
    private static final String DB   = env("DB_NAME", "buyme");

    private static final String URL =
        "jdbc:mysql://" + HOST + ":" + PORT + "/" + DB +
        "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
