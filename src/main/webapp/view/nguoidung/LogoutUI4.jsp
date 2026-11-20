<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Hủy toàn bộ phiên làm việc rồi quay về trang đăng nhập
    session.invalidate();
    response.sendRedirect(request.getContextPath() + "/view/nguoidung/LoginUI4.jsp");
%>
