<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<%
    // Điều hướng theo vai trò của người dùng đang đăng nhập
    Object currentUser = session.getAttribute("loginUser");
    String target = "/view/nguoidung/LoginUI4.jsp";
    if (currentUser instanceof Customer4) {
        target = "/view/khachhang/HomeUI4.jsp";
    } else if (currentUser instanceof SalesStaff4) {
        target = "/view/nhanvienbanhang/HomeUI4.jsp";
    }
    response.sendRedirect(request.getContextPath() + target);
%>
