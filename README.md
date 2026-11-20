# ShopMan – Module 1 (Tìm kiếm mặt hàng) và Module 2 (Duyệt đơn + Xuất kho)

Ứng dụng web Java (JSP + DAO + MySQL) cài đặt đúng theo thiết kế: gói `view` → `dao` → `model`,
không dùng lớp `do`, giao diện (JSP) gọi thẳng DAO.

## Yêu cầu
- JDK 8 trở lên, Apache Tomcat 9 (javax.servlet), MySQL 8, Maven (hoặc Eclipse/IntelliJ/NetBeans).

## Chạy thử
1. Tạo CSDL và dữ liệu mẫu: chạy `database/shopman.sql` trong MySQL (Workbench hoặc `mysql -u root -p < database/shopman.sql`).
2. Mở `src/main/java/dao/DAO4.java`, sửa `USER` và `PASSWORD` cho đúng MySQL của máy bạn.
3. Đóng gói: `mvn clean package` rồi chép `target/shopman.war` vào thư mục `webapps` của Tomcat 9
   (hoặc import dự án Maven vào IDE và Run on Server).
4. Mở `http://localhost:8080/shopman/` (tự chuyển tới trang đăng nhập). Mật khẩu mẫu của mọi tài khoản: `123456`.
   - `khach01` (khách hàng) → Tìm kiếm mặt hàng (thử từ khóa "sữa").
   - `banhang01` (nhân viên bán hàng) → Duyệt đơn (có sẵn 3 đơn DH001, DH002, DH003 "Chưa xuất").
   - Khách mới tự đăng ký ở trang "Đăng ký khách hàng".
   - Tài khoản giao hàng (`giaohang01`–`03`) không đăng nhập được giao diện web này.

## Ánh xạ thiết kế → mã nguồn
| Thiết kế | Mã nguồn |
|---|---|
| Gói `view/khachhang` | `webapp/view/khachhang/`: `HomeUI4.jsp`, `SearchProductUI4.jsp`, `ProductDetailUI4.jsp` |
| Gói `view/nhanvienbanhang` | `webapp/view/nhanvienbanhang/`: `HomeUI4.jsp`, `OrderListUI4.jsp`, `AssignDeliveryUI4.jsp`, `InvoiceDetailUI4.jsp`, `PrintInvoiceUI4.jsp` |
| Gói `dao` | `DAO4`, `ProductDAO4` (`searchProduct`, `viewProductDetails`, `updateStock`), `OrderDAO4` (`getOrderList`, `assignDelivery`), `DeliveryStaffDAO4` (`getDeliveryStaffList`), `InvoiceDAO4` (`createInvoice`, `printInvoice`) |
| Gói `model` | `User4`, `Staff4`, `Customer4`, `SalesStaff4`, `DeliveryStaff4`, `Product4`, `ProductCategory4`, `Order4`, `OrderDetail4`, `Invoice4` |

## Lưu ý khi đối chiếu với tài liệu
- Mảng `X4[]` trong thiết kế được cài bằng `ArrayList<X4>`.
- Duyệt theo lô: `AssignDeliveryUI4.jsp` lặp từng đơn đã chọn. Mỗi đơn là một transaction
  (trừ kho + phân công + tạo hóa đơn); đơn thiếu hàng hoặc đã bị xử lý sẽ hoàn tác riêng,
  không ảnh hưởng các đơn khác, và được báo trong thông báo kết quả.
- Trừ kho dùng câu UPDATE có điều kiện `inventory >= quantity` nên hai nhân viên không trừ vượt tồn kho.
  `assignDelivery` có điều kiện `status = 'Chưa xuất'` nên một đơn không bị xuất hai lần.
- `InvoiceDAO4.printInvoice(Invoice4)` nhận một hóa đơn; `PrintInvoiceUI4.jsp` gọi lặp cho từng hóa đơn
  để hiển thị kết quả từng dòng. Việc ra giấy do trình duyệt thực hiện (`window.print()`), vì máy in nối
  với máy nhân viên bán hàng (như biểu đồ triển khai), không nối với máy chủ.
- Bảng `Invoice4` có thêm cột `totalAmount` so với sơ đồ CSDL hiện tại – bạn cần bổ sung cột này vào sơ đồ.
- Đăng nhập / đăng ký / đăng xuất (thư mục `view/nguoidung`, lớp `UserDAO4`, `util/PasswordUtil4`):
  mật khẩu lưu dạng băm PBKDF2-HmacSHA256 + muối (cột `passWord`), truy vấn dùng PreparedStatement, đăng nhập xong tạo phiên mới,
  thông báo lỗi đăng nhập chung chung. Mỗi trang trong `view/khachhang` và `view/nhanvienbanhang` có
  `WEB-INF/jspf/auth.jspf` kiểm tra vai trò (khách hàng / nhân viên bán hàng), sai thì chuyển về trang đăng nhập.
  Đăng ký chỉ tạo tài khoản khách hàng (ghi `User4` + `Customer4` trong một giao dịch).
  Muốn thêm tài khoản mới bằng SQL thì sinh băm bằng `java -cp target/classes util.PasswordUtil4 <matKhau>`.
  Đây là use case riêng, chưa có trong các sơ đồ hiện tại của hai module.
- Chỉ tạo các bảng cần cho hai module (chưa có Manager4, Supplier4, ImportReceipt4...).

## Đối chiếu phần tử giao diện với thuộc tính trong sơ đồ lớp
| Trang JSP | Thuộc tính (kiểu) | Phần tử trên giao diện |
|---|---|---|
| khachhang/HomeUI4 | `subSearchProduct` (link) | Link "Tìm kiếm mặt hàng" |
| khachhang/SearchProductUI4 | `inProductName` (textField) | Ô nhập "Tên mặt hàng" |
| | `subSearch` (submit) | Nút "Tìm kiếm" |
| | `outProductList` (table) | Bảng TT, Hình ảnh, Tên mặt hàng, Giá bán, Tồn kho, Chi tiết |
| | `subSelectProduct` (submit) | Nút "Chọn" ở mỗi dòng (kèm `selectedProductId`, `keyWord` dạng hidden) |
| khachhang/ProductDetailUI4 | `outProductInfo` (table) | Bảng Thuộc tính / Giá trị |
| | `subBack` (link) | Link "Quay lại" (về kết quả tìm kiếm với `keyWord`) |
| | `subAddToCart` (submit) | Nút "Thêm vào giỏ" (chỉ có nút; giỏ hàng thuộc module Đặt mua hàng nên chưa cài, bấm chỉ hiện thông báo) |
| nhanvienbanhang/HomeUI4 | `subApproveOrder` (link) | Link "Duyệt đơn" |
| nhanvienbanhang/OrderListUI4 | `outOrderList` (table) | Bảng Chọn, Mã đơn, Khách hàng, Ngày đặt, Tổng tiền |
| | `selectedOrders` (Order4[]) | Cột checkbox "Chọn" |
| | `subSelectOrder` (submit) | Nút "Tiếp tục" |
| nhanvienbanhang/AssignDeliveryUI4 | `selectedOrders` (Order4[]) | Dòng "Đơn đã chọn: DH001, DH002" (và hidden gửi kèm) |
| | `outDeliveryStaffList` (table) | Bảng Chọn, Mã NV, Họ tên, Số điện thoại |
| | `inDeliveryStaff` (radio) | Cột radio "Chọn" |
| | `subConfirm` (submit) | Nút "Xác nhận" |
| | `subBack` (link) | Link "Quay lại" (về OrderListUI4) |
| | `deliveryStaff`, `invoices` | Biến xử lý trong trang (lưu `invoices` vào session) |
| nhanvienbanhang/InvoiceDetailUI4 | `outInvoice` (table) | Bảng TT, Mã hóa đơn, Mã đơn, Khách hàng, Ngày lập, Tổng tiền |
| | `subPrint` (submit) | Nút "In hóa đơn" |
| | `invoices` (Invoice4[]) | Lấy từ session |
| nhanvienbanhang/PrintInvoiceUI4 | `outPrintResult` (label) | Khung chữ nhiều dòng: mỗi hóa đơn một dòng "In thành công/thất bại" và dòng tổng kết |
| | `subBack` (link) | Link "Quay lại" (về trang chủ nhân viên bán hàng) |
| | `invoices` (Invoice4[]) | Lấy từ session |

Giao diện chỉ có đúng các phần tử trên (không thêm nút ngoài sơ đồ lớp). Hộp thoại in của trình duyệt tự mở khi in thành công; nếu cần in lại, dùng Ctrl+P.

## Giao diện web
- Phong cách đơn giản, màu chủ đạo xanh nước biển, không dùng icon hay ký tự đặc biệt.
- Khung dùng chung nằm trong `WEB-INF/jspf/header.jspf`, `footer.jspf`; CSS ở `css/style.css`.
- Chữ "ShopMan" ở thanh đầu trang là link về trang chủ của khu vực đang xem (khách hàng, nhân viên bán hàng hoặc trang chọn vai trò).
- Thanh đầu trang và thanh các bước (Chọn đơn → Phân công → Hóa đơn → In hóa đơn) chỉ để trang trí,
  không phải phần tử trong sơ đồ lớp. Muốn bỏ thanh các bước, đặt `currentStep = 0` ở từng trang.
- Ảnh chụp các màn hình (dữ liệu mẫu) nằm trong thư mục `docs/man-hinh/`.

## Chống lỗi font chữ tiếng Việt
- `web.xml` có `jsp-property-group` ép mã hóa UTF-8 cho `*.jsp` và `*.jspf` (các tệp include không tự biết mã hóa của trang cha nên trước đây dễ bị lỗi).
- Các tệp `common.jspf`, `header.jspf`, `footer.jspf` chỉ chứa ký tự ASCII (tiếng Việt viết bằng mã `&#...;` và `\uXXXX`).
- `shopman.sql` bắt đầu bằng `SET NAMES utf8mb4;`. Nếu chạy bằng dòng lệnh: `mysql --default-character-set=utf8mb4 -u root -p < database/shopman.sql`.
- Eclipse/IntelliJ: đặt Text file encoding của dự án là UTF-8 (Eclipse: Window > Preferences > General > Workspace).
- Sau khi sửa phải build lại và xóa cache của Tomcat (Clean / Clean Tomcat Work Directory), rồi bấm Ctrl+F5 trên trình duyệt.
