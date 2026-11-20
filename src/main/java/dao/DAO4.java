package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DAO4 implements AutoCloseable {

    private static final String URL = "jdbc:mysql://localhost:3306/shopman"
            + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh"
            + "&useUnicode=true&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "13112005";

    protected Connection con;
    private final boolean ownsConnection;

    public static Connection openConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy MySQL JDBC driver", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public DAO4() {
        try {
            this.con = openConnection();
        } catch (SQLException e) {
            throw new RuntimeException("Không kết nối được cơ sở dữ liệu: " + e.getMessage(), e);
        }
        this.ownsConnection = true;
    }

    public DAO4(Connection con) {
        this.con = con;
        this.ownsConnection = false;
    }

    @Override
    public void close() {
        if (ownsConnection && con != null) {
            try {
                con.close();
            } catch (SQLException ignore) {
                // bỏ qua
            }
        }
    }
}
