package model;

import java.util.ArrayList;

/** Đơn hàng, trạng thái: "Chưa xuất" hoặc "Đã xuất". */
public class Order4 {
    private int id;
    private java.sql.Date orderDate;
    private String status;
    private double totalAmount;
    private ArrayList<OrderDetail4> orderDetail = new ArrayList<OrderDetail4>();
    private Customer4 customer;
    private SalesStaff4 salesStaff;
    private DeliveryStaff4 deliveryStaff;

    public Order4() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public java.sql.Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(java.sql.Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public ArrayList<OrderDetail4> getOrderDetail() {
        return orderDetail;
    }

    public void setOrderDetail(ArrayList<OrderDetail4> orderDetail) {
        this.orderDetail = orderDetail;
    }

    public Customer4 getCustomer() {
        return customer;
    }

    public void setCustomer(Customer4 customer) {
        this.customer = customer;
    }

    public SalesStaff4 getSalesStaff() {
        return salesStaff;
    }

    public void setSalesStaff(SalesStaff4 salesStaff) {
        this.salesStaff = salesStaff;
    }

    public DeliveryStaff4 getDeliveryStaff() {
        return deliveryStaff;
    }

    public void setDeliveryStaff(DeliveryStaff4 deliveryStaff) {
        this.deliveryStaff = deliveryStaff;
    }

}
