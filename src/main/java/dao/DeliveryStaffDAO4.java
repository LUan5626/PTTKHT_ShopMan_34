package dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import model.DeliveryStaff4;

/** DAO cho nhân viên giao hàng (Module 2). */
public class DeliveryStaffDAO4 extends DAO4 {

    public DeliveryStaffDAO4() {
        super();
    }

    public DeliveryStaffDAO4(Connection con) {
        super(con);
    }

    /** Lấy tất cả nhân viên giao hàng. */
    public ArrayList<DeliveryStaff4> getDeliveryStaffList() throws SQLException {
        ArrayList<DeliveryStaff4> list = new ArrayList<DeliveryStaff4>();
        String sql = "SELECT u.id, u.fullName, u.phone, s.jobPosition "
                   + "FROM DeliveryStaff4 d "
                   + "JOIN Staff4 s ON s.User4id = d.Staff4User4id "
                   + "JOIN User4 u ON u.id = s.User4id "
                   + "ORDER BY u.id";
        try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                DeliveryStaff4 d = new DeliveryStaff4();
                d.setId(rs.getInt("id"));
                d.setFullName(rs.getString("fullName"));
                d.setPhone(rs.getString("phone"));
                d.setJobPosition(rs.getString("jobPosition"));
                list.add(d);
            }
        }
        return list;
    }
}
