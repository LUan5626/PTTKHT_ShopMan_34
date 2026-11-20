<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "CUSTOMER"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<% String pageTitle = "Trang chủ", roleLabel = "Khách hàng", pageClass = "HomeUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="card hero">
  <h1>Chào mừng đến ShopMan</h1>
  <p class="lead">Tra cứu mặt hàng bách hóa theo tên, xem giá bán và tình trạng tồn kho ngay trên trang này.</p>
  <!-- subSearchProduct : link -->
  <a class="tile" href="SearchProductUI4.jsp">
    <span class="tile-title">Tìm kiếm mặt hàng</span>
  </a>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
