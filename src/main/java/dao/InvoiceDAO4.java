package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import model.Invoice4;
import model.Order4;

/** DAO cho hóa đơn (Module 2). */
public class InvoiceDAO4 extends DAO4 {

    public InvoiceDAO4() {
        super();
    }

    public InvoiceDAO4(Connection con) {
        super(con);
    }

    /** Tạo hóa đơn cho đơn hàng (ngày lập = hôm nay, tổng tiền = tổng tiền đơn). */
    public Invoice4 createInvoice(Order4 order) throws SQLException {
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        String sql = "INSERT INTO Invoice4 (createdDate, totalAmount, Order4id) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setDate(1, today);
            ps.setDouble(2, order.getTotalAmount());
            ps.setInt(3, order.getId());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    Invoice4 invoice = new Invoice4();
                    invoice.setId(keys.getInt(1));
                    invoice.setCreatedDate(today);
                    invoice.setTotalAmount(order.getTotalAmount());
                    invoice.setOrder(order);
                    return invoice;
                }
            }
        }
        return null;
    }

    /**
     * In một hóa đơn.
     */
    public boolean printInvoice(Invoice4 invoice) throws SQLException {
        String sql = "SELECT 1 FROM Invoice4 WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, invoice.getId());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
