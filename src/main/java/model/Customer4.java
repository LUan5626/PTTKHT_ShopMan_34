package model;

/** Khách hàng, có thêm mã thẻ thành viên và ngày đăng ký thẻ. */
public class Customer4 extends User4 {
    private String membershipCode;
    private java.sql.Date membershipDate;

    public Customer4() {
    }

    public String getMembershipCode() {
        return membershipCode;
    }

    public void setMembershipCode(String membershipCode) {
        this.membershipCode = membershipCode;
    }

    public java.sql.Date getMembershipDate() {
        return membershipDate;
    }

    public void setMembershipDate(java.sql.Date membershipDate) {
        this.membershipDate = membershipDate;
    }

}
