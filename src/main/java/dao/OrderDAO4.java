package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import model.Customer4;
import model.DeliveryStaff4;
import model.Order4;
import model.SalesStaff4;
import model.OrderDetail4;
import model.Product4;

/** DAO cho đơn hàng (Module 2). */
public class OrderDAO4 extends DAO4 {

    public static final String CHUA_XUAT = "Chưa xuất";
    public static final String DA_XUAT = "Đã xuất";

    public OrderDAO4() {
        super();
    }

    public OrderDAO4(Connection con) {
        super(con);
    }

    /** Lấy các đơn hàng "Chưa xuất", kèm khách hàng và danh sách chi tiết đơn (orderDetail). */
    public ArrayList<Order4> getOrderList() throws SQLException {
        ArrayList<Order4> list = new ArrayList<Order4>();
        String sql = "SELECT o.id, o.orderDate, o.status, o.totalAmount, "
                   + "       u.id AS customerId, u.fullName, u.phone, u.address "
                   + "FROM Order4 o "
                   + "JOIN Customer4 c ON c.User4id = o.Customer4User4id "
                   + "JOIN User4 u ON u.id = c.User4id "
                   + "WHERE o.status = ? ORDER BY o.orderDate, o.id";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, CHUA_XUAT);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order4 o = new Order4();
                    o.setId(rs.getInt("id"));
                    o.setOrderDate(rs.getDate("orderDate"));
                    o.setStatus(rs.getString("status"));
                    o.setTotalAmount(rs.getDouble("totalAmount"));
                    Customer4 c = new Customer4();
                    c.setId(rs.getInt("customerId"));
                    c.setFullName(rs.getString("fullName"));
                    c.setPhone(rs.getString("phone"));
                    c.setAddress(rs.getString("address"));
                    o.setCustomer(c);
                    list.add(o);
                }
            }
        }

        String sqlDetail = "SELECT d.id, d.quantity, d.sellingPrice, "
                         + "       p.id AS productId, p.productName, p.sellingPrice AS productPrice, p.inventory "
                         + "FROM OrderDetail4 d JOIN Product4 p ON p.id = d.Product4id "
                         + "WHERE d.Order4id = ? ORDER BY d.id";
        try (PreparedStatement ps = con.prepareStatement(sqlDetail)) {
            for (Order4 o : list) {
                ps.setInt(1, o.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Product4 p = new Product4();
                        p.setId(rs.getInt("productId"));
                        p.setProductName(rs.getString("productName"));
                        p.setSellingPrice(rs.getDouble("productPrice"));
                        p.setInventory(rs.getInt("inventory"));
                        OrderDetail4 d = new OrderDetail4();
                        d.setId(rs.getInt("id"));
                        d.setQuantity(rs.getInt("quantity"));
                        d.setSellingPrice(rs.getDouble("sellingPrice"));
                        d.setProduct(p);
                        o.getOrderDetail().add(d);
                    }
                }
            }
        }
        return list;
    }

    /**
     * Lưu đơn hàng đã được đóng gói
     */
    public boolean assignDelivery(Order4 order) throws SQLException {
        String sql = "UPDATE Order4 SET status = ?, DeliveryStaff4Staff4User4id = ?, "
                   + "SalesStaff4Staff4User4id = ? WHERE id = ? AND status = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, order.getStatus());
            ps.setInt(2, order.getDeliveryStaff().getId());
            ps.setInt(3, order.getSalesStaff().getId());
            ps.setInt(4, order.getId());
            ps.setString(5, CHUA_XUAT);
            return ps.executeUpdate() == 1;
        }
    }
}
