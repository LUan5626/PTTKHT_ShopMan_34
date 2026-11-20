package model;

/** Mặt hàng. */
public class Product4 {
    private int id;
    private String productName;
    private double sellingPrice;
    private String image;
    private String description;
    private int inventory;
    private ProductCategory4 category;

    public Product4() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public double getSellingPrice() {
        return sellingPrice;
    }

    public void setSellingPrice(double sellingPrice) {
        this.sellingPrice = sellingPrice;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getInventory() {
        return inventory;
    }

    public void setInventory(int inventory) {
        this.inventory = inventory;
    }

    public ProductCategory4 getCategory() {
        return category;
    }

    public void setCategory(ProductCategory4 category) {
        this.category = category;
    }

}
