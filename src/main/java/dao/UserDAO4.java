package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import model.Customer4;
import model.DeliveryStaff4;
import model.SalesStaff4;
import model.Staff4;
import model.User4;


/** DAO cho người dùng: đăng nhập và đăng ký. */
public class UserDAO4 extends DAO4 {

    /** Mật khẩu giả để vẫn tốn thời gian băm khi tên đăng nhập không tồn tại. */
    private static final String DUMMY_HASH = PasswordUtil4.hash("dummy-password");

    public UserDAO4() {
        super();
    }

    public UserDAO4(Connection con) {
        super(con);
    }

    /**
     * Đăng nhập. Trả về Customer4 / SalesStaff4 / DeliveryStaff4 (không chứa mật khẩu)
     * nếu đúng tên đăng nhập và mật khẩu, ngược lại trả về null.
     */
    public User4 login(String userName, String password) throws SQLException {
        String sql = "SELECT u.id, u.userName, u.passWord, u.fullName, u.phone, u.email, u.address, "
                   + "       c.User4id AS cid, c.memberShipCode, c.memberShipDate, "
                   + "       s.jobPosition, sa.Staff4User4id AS sid, d.Staff4User4id AS did "
                   + "FROM User4 u "
                   + "LEFT JOIN Customer4 c      ON c.User4id = u.id "
                   + "LEFT JOIN Staff4 s         ON s.User4id = u.id "
                   + "LEFT JOIN SalesStaff4 sa   ON sa.Staff4User4id = u.id "
                   + "LEFT JOIN DeliveryStaff4 d ON d.Staff4User4id = u.id "
                   + "WHERE u.userName = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userName);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    PasswordUtil4.verify(password, DUMMY_HASH);
                    return null;
                }
                if (!PasswordUtil4.verify(password, rs.getString("passWord"))) {
                    return null;
                }
                User4 u;
                if (rs.getObject("cid") != null) {
                    Customer4 c = new Customer4();
                    c.setMembershipCode(rs.getString("memberShipCode"));
                    c.setMembershipDate(rs.getDate("memberShipDate"));
                    u = c;
                } else if (rs.getObject("sid") != null) {
                    Staff4 s = new SalesStaff4();
                    s.setJobPosition(rs.getString("jobPosition"));
                    u = s;
                } else if (rs.getObject("did") != null) {
                    Staff4 s = new DeliveryStaff4();
                    s.setJobPosition(rs.getString("jobPosition"));
                    u = s;
                } else {
                    return null; // tài khoản chưa gán vai trò
                }
                u.setId(rs.getInt("id"));
                u.setUserName(rs.getString("userName"));
                u.setFullName(rs.getString("fullName"));
                u.setPhone(rs.getString("phone"));
                u.setEmail(rs.getString("email"));
                u.setAddress(rs.getString("address"));
                return u;
            }
        }
    }

    /** Tên đăng nhập đã tồn tại chưa. */
    public boolean userNameExists(String userName) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT 1 FROM User4 WHERE userName = ?")) {
            ps.setString(1, userName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Đăng ký tài khoản khách hàng (ghi User4 và Customer4 trong một giao dịch).
     * Trả về false nếu tên đăng nhập đã tồn tại.
     */
    public boolean registerCustomer(Customer4 c, String plainPassword) throws SQLException {
        boolean oldAuto = con.getAutoCommit();
        con.setAutoCommit(false);
        try {
            int newId;
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO User4 (userName, passWord, fullName, phone, email, address) VALUES (?,?,?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, c.getUserName());
                ps.setString(2, PasswordUtil4.hash(plainPassword));
                ps.setString(3, c.getFullName());
                ps.setString(4, c.getPhone());
                ps.setString(5, c.getEmail());
                ps.setString(6, c.getAddress());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    newId = keys.getInt(1);
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO Customer4 (User4id, memberShipCode, memberShipDate) VALUES (?, NULL, NULL)")) {
                ps.setInt(1, newId);
                ps.executeUpdate();
            }
            con.commit();
            c.setId(newId);
            return true;
        } catch (SQLException e) {
            con.rollback();
            if (e.getErrorCode() == 1062 || "23000".equals(e.getSQLState())) {
                return false; // trùng userName (UNIQUE)
            }
            throw e;
        } finally {
            con.setAutoCommit(oldAuto);
        }
    }
}
