<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Đã đăng nhập thì chuyển thẳng tới trang chủ theo vai trò
    Object current = session.getAttribute("loginUser");
    if (current instanceof Customer4) {
        response.sendRedirect(request.getContextPath() + "/view/khachhang/HomeUI4.jsp");
        return;
    } else if (current instanceof SalesStaff4) {
        response.sendRedirect(request.getContextPath() + "/view/nhanvienbanhang/HomeUI4.jsp");
        return;
    }

    // Thông báo từ lượt trước (ví dụ: vừa đăng ký xong)
    String notice = (String) session.getAttribute("authMessage");
    session.removeAttribute("authMessage");

    String userName = "";
    String error = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        userName = request.getParameter("userName") == null ? "" : request.getParameter("userName").trim();
        String password = request.getParameter("passWord") == null ? "" : request.getParameter("passWord");

        if (userName.isEmpty() || password.isEmpty()) {
            error = "Vui lòng nhập tên đăng nhập và mật khẩu.";
        } else {
            User4 user = null;
            try (UserDAO4 dao = new UserDAO4()) {
                user = dao.login(userName, password);
            } catch (SQLException e) {
                error = "Không kết nối được cơ sở dữ liệu. Vui lòng thử lại sau.";
            }
            if (error == null) {
                if (user == null) {
                    error = "Tên đăng nhập hoặc mật khẩu không đúng.";
                } else if (user instanceof DeliveryStaff4) {
                    error = "Tài khoản nhân viên giao hàng không đăng nhập vào giao diện web này.";
                } else {
                    // Tạo phiên mới sau khi đăng nhập để tránh session fixation
                    session.invalidate();
                    javax.servlet.http.HttpSession newSession = request.getSession(true);
                    newSession.setAttribute("loginUser", user);
                    response.sendRedirect(request.getContextPath()
                            + (user instanceof Customer4 ? "/view/khachhang/HomeUI4.jsp"
                                                         : "/view/nhanvienbanhang/HomeUI4.jsp"));
                    return;
                }
            }
        }
    }
%>
<% String pageTitle = "Đăng nhập", roleLabel = "", pageClass = "LoginUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="card auth-card">
  <h1 class="page-title">Đăng nhập</h1>
  <p class="page-sub">Đăng nhập để sử dụng hệ thống ShopMan.</p>

  <% if (notice != null) { %><div class="alert info"><%=h(notice)%></div><% } %>
  <% if (error != null) { %><div class="alert error"><%=h(error)%></div><% } %>

  <form method="post" action="LoginUI4.jsp" autocomplete="on">
    <div class="form-row">
      <label for="userName">Tên đăng nhập</label>
      <input type="text" id="userName" name="userName" value="<%=h(userName)%>" maxlength="255" autofocus required>
    </div>
    <div class="form-row">
      <label for="passWord">Mật khẩu</label>
      <input type="password" id="passWord" name="passWord" maxlength="255" required>
    </div>
    <div class="actions">
      <button type="submit" class="btn">Đăng nhập</button>
    </div>
  </form>

  <p class="auth-switch">Chưa có tài khoản? <a href="RegisterUI4.jsp">Đăng ký khách hàng</a></p>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
