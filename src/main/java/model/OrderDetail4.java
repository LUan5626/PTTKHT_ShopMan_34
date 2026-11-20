package model;

/** Chi tiết đơn hàng. */
public class OrderDetail4 {
    private int id;
    private int quantity;
    private double sellingPrice;
    private Product4 product;

    public OrderDetail4() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(double sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public Product4 getProduct() {
        return product;
    }

    public void setProduct(Product4 product) {
        this.product = product;
    }

    /** Thành tiền = số lượng x đơn giá bán (không lưu trong CSDL). */
    public double getTotalAmount() {
        return quantity * sellingPrice;
    }

}
