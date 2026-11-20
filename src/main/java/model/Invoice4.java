package model;

/** Hóa đơn. */
public class Invoice4 {
    private int id;
    private java.sql.Date createdDate;
    private double totalAmount;
    private Order4 order;

    public Invoice4() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public java.sql.Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(java.sql.Date createdDate) {
        this.createdDate = createdDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Order4 getOrder() {
        return order;
    }

    public void setOrder(Order4 order) {
        this.order = order;
    }

}
