import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ApplicationDB {
    public Connection getConnection() {

        String connectionUrl = "jdbc:mysql://localhost:3306/thriftShop";
        Connection connection = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch (InstantiationError e) {
            e.printStackTrace();
        }
        catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        try {
            connection = DriverManager.getConnection(connectionUrl, "root", "Xcrafty!3my");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return connection;
    }
}