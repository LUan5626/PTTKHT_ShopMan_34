ShopMan – Module 1 (Tìm kiếm mặt hàng) và Module 2 (Duyệt đơn + Xuất kho)

Đồ án môn Phân tích thiết kế hệ thống thông tin – Đề số 34. Ứng dụng web Java (JSP + DAO + MySQL), tổ chức theo gói view → dao → model. Giao diện (JSP) gọi trực tiếp lớp DAO, không dùng servlet/controller riêng.

Yêu cầu
JDK 8 trở lên
Apache Tomcat 9 (javax.servlet; không dùng Tomcat 10 trở lên)
MySQL 8
Maven (hoặc import vào Eclipse / IntelliJ / NetBeans)
Chạy thử
Tạo CSDL và dữ liệu mẫu: chạy database/shopman.sql (MySQL Workbench, hoặc mysql --default-character-set=utf8mb4 -u root -p < database/shopman.sql).
Mở src/main/java/dao/DAO4.java, sửa URL, USER, PASSWORD cho đúng MySQL của máy bạn. Không commit mật khẩu thật lên GitHub: trước khi đẩy code, thay PASSWORD bằng giá trị giả (ví dụ "your_password").
Đóng gói: mvn clean package, chép target/shopman.war vào thư mục webapps của Tomcat 9 (hoặc import dự án Maven vào IDE và Run on Server).
Mở http://localhost:8080/shopman/ (tự chuyển tới trang đăng nhập).
Tài khoản mẫu (mật khẩu của tất cả: 123456)
Tài khoản	Vai trò	Dùng cho
khach01, khach02, khach03	Khách hàng	Module 1: Tìm kiếm mặt hàng (thử từ khóa "sữa")
banhang01	Nhân viên bán hàng	Module 2: Duyệt đơn (có sẵn 3 đơn DH001, DH002, DH003 "Chưa xuất")
giaohang01–giaohang03	Nhân viên giao hàng	Chỉ xuất hiện trong danh sách phân công; không đăng nhập được giao diện web này

Khách mới có thể tự đăng ký ở trang "Đăng ký khách hàng".

Dữ liệu mẫu

shopman.sql có 8 mặt hàng, 4 loại mặt hàng, 3 khách hàng, 1 nhân viên bán hàng, 3 nhân viên giao hàng và 3 đơn hàng. Cột Product4.image của dữ liệu mẫu để NULL nên giao diện hiện "Chưa có ảnh". Muốn hiển thị ảnh: tạo thư mục src/main/webapp/images/products/, chép ảnh vào và ghi đường dẫn tương đối vào cột image (ví dụ images/products/gao-st25.jpg).

Cấu trúc thư mục
shopman/
├── database/shopman.sql
├── docs/man-hinh/                  # ảnh chụp giao diện
└── src/main/
    ├── java/
    │   ├── model/                  # User4, Staff4, Customer4, SalesStaff4, DeliveryStaff4,
    │   │                           # Product4, ProductCategory4, Order4, OrderDetail4, Invoice4
    │   └── dao/                    # DAO4, UserDAO4, ProductDAO4, OrderDAO4,
    │                               # DeliveryStaffDAO4, InvoiceDAO4,
    │                               # PasswordUtil4 (băm / kiểm tra mật khẩu)
    └── webapp/
        ├── view/nguoidung/         # LoginUI4, RegisterUI4, LogoutUI4
        ├── view/khachhang/         # HomeUI4, SearchProductUI4, ProductDetailUI4
        ├── view/nhanvienbanhang/   # HomeUI4, OrderListUI4, AssignDeliveryUI4,
        │                           # InvoiceDetailUI4, PrintInvoiceUI4
        ├── WEB-INF/jspf/           # common, header, footer, auth (phần dùng chung)
        ├── css/style.css
        └── index.jsp               # chuyển hướng theo vai trò
Ánh xạ thiết kế → mã nguồn
Thiết kế	Mã nguồn
Gói view/khachhang	HomeUI4, SearchProductUI4, ProductDetailUI4
Gói view/nhanvienbanhang	HomeUI4, OrderListUI4, AssignDeliveryUI4, InvoiceDetailUI4, PrintInvoiceUI4
Gói view/nguoidung	LoginUI4, RegisterUI4, LogoutUI4
ProductDAO4	searchProduct, viewProductDetails, updateStock
OrderDAO4	getOrderList, assignDelivery
DeliveryStaffDAO4	getDeliveryStaffList
InvoiceDAO4	createInvoice, printInvoice
UserDAO4	login, registerCustomer, userNameExists (dùng PasswordUtil4 cùng gói dao)
Gói model	10 lớp thực thể ở trên (chưa có Manager4, Supplier4, ImportReceipt4... vì ngoài phạm vi hai module)
Các điểm triển khai cần lưu ý khi đối chiếu với báo cáo
Kiểu dữ liệu: mảng X4[] trong thiết kế được cài bằng ArrayList<X4>; tham số Integer được cài bằng int.
Tìm kiếm: tìm theo tên chứa từ khóa (LIKE %từ khóa%). Từ khóa rỗng trả về toàn bộ mặt hàng.
Nút "Thêm vào giỏ": chỉ có nút trên ProductDetailUI4; giỏ hàng thuộc module Đặt mua hàng nên chưa cài, bấm chỉ hiện thông báo.
Duyệt đơn theo lô:
OrderListUI4 chỉ gửi mã các đơn được chọn (selectedOrders) sang AssignDeliveryUI4, không gửi cả đối tượng.
Khi bấm "Xác nhận", AssignDeliveryUI4 gọi lại OrderDAO4.getOrderList() để lấy các đơn còn "Chưa xuất" kèm chi tiết, rồi xử lý lần lượt từng đơn đã chọn.
Mỗi đơn là một transaction (các DAO dùng chung một Connection): trừ kho (updateStock) → phân công (assignDelivery) → tạo hóa đơn (createInvoice). Đủ cả ba bước thì commit, sai bước nào thì rollback riêng đơn đó và các đơn khác không bị ảnh hưởng.
Chống xử lý trùng (không dùng SELECT ... FOR UPDATE):
updateStock dùng UPDATE ... WHERE inventory >= số lượng, nên hai nhân viên không trừ vượt tồn kho. Hàm này tự cập nhật inventory trong CSDL và trong đối tượng Product4; JSP không gọi setInventory.
assignDelivery dùng UPDATE ... WHERE status = 'Chưa xuất', nên một đơn không bị xuất hai lần.
Thông báo lỗi thiếu hàng: hiện mặt hàng đầu tiên không đủ tồn kho và số lượng cần ("không đủ tồn kho X (cần n)"), không liệt kê hết các mặt hàng thiếu.
In hóa đơn:
InvoiceDAO4.printInvoice(Invoice4) nhận một hóa đơn và chỉ kiểm tra hóa đơn còn tồn tại trong CSDL. PrintInvoiceUI4.jsp gọi hàm này cho từng hóa đơn để hiển thị kết quả từng dòng.
Việc ra giấy do trình duyệt thực hiện (window.print()), vì máy in nối với máy nhân viên bán hàng chứ không nối với máy chủ.
Hộp thoại in tự mở khi tất cả hóa đơn kiểm tra thành công. Hệ thống không phát hiện được lỗi máy in và không có nút "In lại"; nếu cần in lại, dùng Ctrl+P (hoặc tải lại trang).
Bảng Invoice4 có cột totalAmount (đã có trong sơ đồ CSDL của báo cáo). Cột Customer4.memberShipCode cho phép NULL (khách mới đăng ký chưa có thẻ thành viên).
Đăng nhập / đăng ký / đăng xuất (view/nguoidung, UserDAO4, PasswordUtil4): đây là use case dùng chung, ngoài sơ đồ của hai module.
Mật khẩu lưu dạng băm PBKDF2-HmacSHA256 kèm muối ngẫu nhiên trong cột passWord; truy vấn dùng PreparedStatement.
Đăng nhập xong tạo phiên mới; thông báo lỗi đăng nhập chung chung.
Đăng ký chỉ tạo tài khoản khách hàng (ghi User4 và Customer4 trong một giao dịch).
Chức năng Quên mật khẩu (có trong use case tổng quát) chưa được cài đặt.
Mỗi trang trong view/khachhang và view/nhanvienbanhang include WEB-INF/jspf/auth.jspf để kiểm tra vai trò; sai vai trò thì chuyển về trang đăng nhập.
Thêm tài khoản bằng SQL: sinh băm bằng java -cp target/classes dao.PasswordUtil4 <matKhau>.
Đối chiếu phần tử giao diện với thuộc tính trong sơ đồ lớp
Trang JSP	Thuộc tính (kiểu)	Phần tử trên giao diện
khachhang/HomeUI4	subSearchProduct (link)	Link "Tìm kiếm mặt hàng"
khachhang/SearchProductUI4	inProductName (textField)	Ô nhập "Tên mặt hàng"
	subSearch (submit)	Nút "Tìm kiếm"
	outProductList (table)	Bảng TT, Hình ảnh, Tên mặt hàng, Giá bán, Tồn kho, Chi tiết
	subSelectProduct (submit)	Nút "Chọn" ở mỗi dòng (kèm selectedProductId, keyWord dạng hidden)
khachhang/ProductDetailUI4	outProductInfo (table)	Bảng Thuộc tính / Giá trị
	subBack (link)	Link "Quay lại" (về kết quả tìm kiếm với keyWord)
	subAddToCart (submit)	Nút "Thêm vào giỏ" (chưa cài giỏ hàng, bấm chỉ hiện thông báo)
nhanvienbanhang/HomeUI4	subApproveOrder (link)	Link "Duyệt đơn"
nhanvienbanhang/OrderListUI4	outOrderList (table)	Bảng Chọn, Mã đơn, Khách hàng, Ngày đặt, Tổng tiền
	selectedOrders (checkbox)	Cột "Chọn"
	subSelectOrder (submit)	Nút "Tiếp tục"
nhanvienbanhang/AssignDeliveryUI4	selectedOrders	Dòng "Đơn đã chọn: DH001, DH002" (và hidden gửi kèm)
	outDeliveryStaffList (table)	Bảng Chọn, Mã NV, Họ tên, Số điện thoại
	inDeliveryStaff (radio)	Cột radio "Chọn"
	subConfirm (submit)	Nút "Xác nhận"
	subBack (link)	Link "Quay lại" (về OrderListUI4)
	deliveryStaff, invoices	Biến xử lý trong trang; invoices được lưu vào session
nhanvienbanhang/InvoiceDetailUI4	outInvoice (table)	Bảng TT, Mã hóa đơn, Mã đơn, Khách hàng, Ngày lập, Tổng tiền
	subPrint (submit)	Nút "In hóa đơn"
	invoices	Lấy từ session
nhanvienbanhang/PrintInvoiceUI4	outPrintResult (label)	Mỗi hóa đơn một dòng "In thành công/thất bại" và dòng tổng kết
	subBack (link)	Link "Quay lại" (về trang chủ nhân viên bán hàng)
	invoices	Lấy từ session

Giao diện chỉ có các phần tử trên. Thanh đầu trang và thanh các bước (Chọn đơn → Phân công → Hóa đơn → In hóa đơn) chỉ để trang trí, không thuộc sơ đồ lớp; muốn bỏ thanh các bước thì đặt currentStep = 0 ở từng trang.

Giao diện web
Phong cách đơn giản, màu chủ đạo xanh nước biển.
Khung dùng chung nằm trong WEB-INF/jspf/header.jspf và footer.jspf; CSS ở css/style.css (có phần @media print cho hóa đơn).
Chữ "ShopMan" ở thanh đầu trang là link về index.jsp, trang này tự chuyển theo vai trò đang đăng nhập.
Ảnh chụp các màn hình nằm trong docs/man-hinh/.
Chống lỗi font chữ tiếng Việt
web.xml có jsp-property-group ép mã hóa UTF-8 cho *.jsp và *.jspf.
common.jspf, header.jspf, footer.jspf chỉ chứa ký tự ASCII (tiếng Việt viết bằng mã &#...; và \uXXXX).
shopman.sql bắt đầu bằng SET NAMES utf8mb4;. Nếu chạy bằng dòng lệnh, thêm --default-character-set=utf8mb4.
Eclipse/IntelliJ: đặt Text file encoding của dự án là UTF-8 (Eclipse: Window > Preferences > General > Workspace).
Sau khi sửa, build lại, xóa cache của Tomcat (Clean / Clean Tomcat Work Directory) rồi bấm Ctrl+F5 trên trình duyệt.
Phạm vi chưa cài đặt
Các chức năng của Nhân viên quản lý (quản lý mặt hàng, nhà cung cấp, nhập hàng, thống kê).
Đăng ký thẻ thành viên, đặt mua hàng trực tuyến (giỏ hàng), theo dõi đơn hàng.
Quên mật khẩu.
Giao diện cho nhân viên giao hàng.
