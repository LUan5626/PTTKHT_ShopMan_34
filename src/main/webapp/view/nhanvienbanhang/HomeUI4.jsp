<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "SALES"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    // Bắt đầu một lượt duyệt đơn mới: xóa dữ liệu của lượt trước (nếu có)
    session.removeAttribute("invoices");
    session.removeAttribute("processingMessage");
%>
<% String pageTitle = "Trang chủ", roleLabel = "Nhân viên bán hàng", pageClass = "HomeUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="card hero">
  <h1>Xin chào, nhân viên bán hàng</h1>
  <p class="lead">Duyệt các đơn hàng trực tuyến chưa xuất, phân công nhân viên giao hàng và in hóa đơn.</p>
  <!-- subApproveOrder : link -->
  <a class="tile" href="OrderListUI4.jsp">
    <span class="tile-title">Duyệt đơn</span>
  </a>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
