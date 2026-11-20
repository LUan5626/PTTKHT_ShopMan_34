package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import model.Product4;
import model.ProductCategory4;

/** DAO cho mặt hàng: tìm kiếm, xem chi tiết (Module 1) và trừ tồn kho (Module 2). */
public class ProductDAO4 extends DAO4 {

    private static final String SELECT_PRODUCT =
            "SELECT p.id, p.productName, p.sellingPrice, p.image, p.description, p.inventory, "
          + "       c.id AS categoryId, c.categoryName "
          + "FROM Product4 p JOIN ProductCategory4 c ON c.id = p.ProductCategory4id ";

    public ProductDAO4() {
        super();
    }

    public ProductDAO4(Connection con) {
        super(con);
    }

    /** Tìm các mặt hàng có tên chứa từ khóa (từ khóa rỗng: trả về tất cả). */
    public ArrayList<Product4> searchProduct(String productName) throws SQLException {
        ArrayList<Product4> list = new ArrayList<Product4>();
        String keyword = productName == null ? "" : productName.trim();
        String sql = SELECT_PRODUCT + "WHERE p.productName LIKE ? ORDER BY p.productName";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProduct(rs));
                }
            }
        }
        return list;
    }

    /** Lấy thông tin chi tiết của một mặt hàng, trả về null nếu không tồn tại. */
    public Product4 viewProductDetails(int productId) throws SQLException {
        String sql = SELECT_PRODUCT + "WHERE p.id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        }
        return null;
    }

    /**
     * Trừ tồn kho của mặt hàng. 
     */
    public boolean updateStock(Product4 product, int quantity) throws SQLException {
        String sql = "UPDATE Product4 SET inventory = inventory - ? WHERE id = ? AND inventory >= ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, product.getId());
            ps.setInt(3, quantity);
            if (ps.executeUpdate() == 1) {
                product.setInventory(product.getInventory() - quantity);
                return true;
            }
            return false;
        }
    }

    private Product4 mapProduct(ResultSet rs) throws SQLException {
        Product4 p = new Product4();
        p.setId(rs.getInt("id"));
        p.setProductName(rs.getString("productName"));
        p.setSellingPrice(rs.getDouble("sellingPrice"));
        p.setImage(rs.getString("image"));
        p.setDescription(rs.getString("description"));
        p.setInventory(rs.getInt("inventory"));
        ProductCategory4 c = new ProductCategory4();
        c.setId(rs.getInt("categoryId"));
        c.setCategoryName(rs.getString("categoryName"));
        p.setCategory(c);
        return p;
    }
}
