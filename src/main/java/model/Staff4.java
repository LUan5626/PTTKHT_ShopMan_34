package model;

/** Nhân viên (lớp cha của SalesStaff4, DeliveryStaff4). */
public class Staff4 extends User4 {
    private String jobPosition;

    public Staff4() {
    }

    public String getJobPosition() {
        return jobPosition;
    }

    public void setJobPosition(String jobPosition) {
        this.jobPosition = jobPosition;
    }

}
