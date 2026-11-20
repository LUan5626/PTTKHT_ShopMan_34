<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Đã đăng nhập thì không cần đăng ký
    if (session.getAttribute("loginUser") != null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String userName = "", fullName = "", phone = "", email = "", address = "";
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        userName = request.getParameter("userName") == null ? "" : request.getParameter("userName").trim();
        fullName = request.getParameter("fullName") == null ? "" : request.getParameter("fullName").trim();
        phone    = request.getParameter("phone")    == null ? "" : request.getParameter("phone").trim();
        email    = request.getParameter("email")    == null ? "" : request.getParameter("email").trim();
        address  = request.getParameter("address")  == null ? "" : request.getParameter("address").trim();
        String password = request.getParameter("passWord")  == null ? "" : request.getParameter("passWord");
        String confirm  = request.getParameter("confirm")   == null ? "" : request.getParameter("confirm");

        if (!userName.matches("[A-Za-z0-9_.]{3,30}")) {
            error = "Tên đăng nhập gồm 3–30 ký tự: chữ cái không dấu, số, dấu chấm hoặc gạch dưới.";
        } else if (fullName.isEmpty() || fullName.length() > 255) {
            error = "Vui lòng nhập họ tên (tối đa 255 ký tự).";
        } else if (password.length() < 6 || password.length() > 100) {
            error = "Mật khẩu phải từ 6 đến 100 ký tự.";
        } else if (!password.equals(confirm)) {
            error = "Mật khẩu nhập lại không khớp.";
        } else if (!phone.isEmpty() && !phone.matches("[0-9 .+\\-]{8,15}")) {
            error = "Số điện thoại không hợp lệ.";
        } else if (!email.isEmpty() && (email.length() > 255 || !email.matches("[^@\\s]+@[^@\\s]+\\.[^@\\s]+"))) {
            error = "Email không hợp lệ.";
        } else if (address.length() > 255) {
            error = "Địa chỉ tối đa 255 ký tự.";
        } else {
            Customer4 c = new Customer4();
            c.setUserName(userName);
            c.setFullName(fullName);
            c.setPhone(phone.isEmpty() ? null : phone);
            c.setEmail(email.isEmpty() ? null : email);
            c.setAddress(address.isEmpty() ? null : address);
            try (UserDAO4 dao = new UserDAO4()) {
                if (dao.registerCustomer(c, password)) {
                    session.setAttribute("authMessage", "Đăng ký thành công. Vui lòng đăng nhập.");
                    response.sendRedirect(request.getContextPath() + "/view/nguoidung/LoginUI4.jsp");
                    return;
                }
                error = "Tên đăng nhập đã được sử dụng. Vui lòng chọn tên khác.";
            } catch (SQLException e) {
                error = "Không đăng ký được do lỗi cơ sở dữ liệu. Vui lòng thử lại sau.";
            }
        }
    }
%>
<% String pageTitle = "Đăng ký", roleLabel = "", pageClass = "RegisterUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="card auth-card">
  <h1 class="page-title">Đăng ký tài khoản khách hàng</h1>
  <p class="page-sub">Các mục có dấu * là bắt buộc.</p>

  <% if (error != null) { %><div class="alert error"><%=h(error)%></div><% } %>

  <form method="post" action="RegisterUI4.jsp" autocomplete="on">
    <div class="form-row">
      <label for="userName">Tên đăng nhập *</label>
      <input type="text" id="userName" name="userName" value="<%=h(userName)%>" maxlength="30" autofocus required>
    </div>
    <div class="form-row">
      <label for="passWord">Mật khẩu * (tối thiểu 6 ký tự)</label>
      <input type="password" id="passWord" name="passWord" maxlength="100" required>
    </div>
    <div class="form-row">
      <label for="confirm">Nhập lại mật khẩu *</label>
      <input type="password" id="confirm" name="confirm" maxlength="100" required>
    </div>
    <div class="form-row">
      <label for="fullName">Họ và tên *</label>
      <input type="text" id="fullName" name="fullName" value="<%=h(fullName)%>" maxlength="255" required>
    </div>
    <div class="form-row">
      <label for="phone">Số điện thoại</label>
      <input type="tel" id="phone" name="phone" value="<%=h(phone)%>" maxlength="15">
    </div>
    <div class="form-row">
      <label for="email">Email</label>
      <input type="email" id="email" name="email" value="<%=h(email)%>" maxlength="255">
    </div>
    <div class="form-row">
      <label for="address">Địa chỉ</label>
      <input type="text" id="address" name="address" value="<%=h(address)%>" maxlength="255">
    </div>
    <div class="actions">
      <button type="submit" class="btn">Đăng ký</button>
      <a class="btn btn-outline" href="LoginUI4.jsp">Quay lại đăng nhập</a>
    </div>
  </form>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
