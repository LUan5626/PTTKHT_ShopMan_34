<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "CUSTOMER"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // selectedProductId : Integer (từ SearchProductUI4), keyWord : từ khóa của lần tìm kiếm trước
    String selectedProductId = request.getParameter("selectedProductId");
    String keyWord = request.getParameter("keyWord");
    if (keyWord == null) keyWord = "";

    // outProductInfo : table
    Product4 outProductInfo = null;
    String error = null;
    try (ProductDAO4 dao = new ProductDAO4()) {
        outProductInfo = dao.viewProductDetails(Integer.parseInt(selectedProductId));
    } catch (NumberFormatException e) {
        error = "Mã mặt hàng không hợp lệ.";
    } catch (Exception e) {
        error = e.getMessage();
    }
    // subBack : link - quay lại kết quả tìm kiếm trước đó
    String backUrl = "SearchProductUI4.jsp?subSearch=1&inProductName=" + java.net.URLEncoder.encode(keyWord, "UTF-8");
%>
<% String pageTitle = "Chi tiết mặt hàng", roleLabel = "Khách hàng", pageClass = "ProductDetailUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<h1 class="page-title">Chi tiết mặt hàng</h1>

<%-- subAddToCart : submit - chi co nut; gio hang thuoc module Dat mua hang nen chua cai dat --%>
<% if (request.getParameter("subAddToCart") != null && outProductInfo != null) { %>
  <div class="alert info">Chức năng giỏ hàng thuộc module Đặt mua hàng nên chưa được cài đặt trong phạm vi này.</div>
<% } %>

<% if (error != null) { %>
  <div class="alert error"><%=h(error)%></div>
<% } else if (outProductInfo == null) { %>
  <div class="card empty-state">
    <p>Mặt hàng không tồn tại hoặc đã ngừng kinh doanh.</p>
  </div>
<% } else { %>
  <div class="card">
    <div class="table-wrap">
    <table class="data">
      <tr><th>Thuộc tính</th><th>Giá trị</th></tr>
      <tr><td class="key">Hình ảnh</td><td>
        <% if (outProductInfo.getImage() != null && !outProductInfo.getImage().trim().isEmpty()) { %>
          <img class="big" src="<%=request.getContextPath()%>/<%=h(outProductInfo.getImage())%>" alt="">
        <% } else { %><span class="muted">Chưa có ảnh</span><% } %>
      </td></tr>
      <tr><td class="key">Tên mặt hàng</td><td><strong><%=h(outProductInfo.getProductName())%></strong></td></tr>
      <tr><td class="key">Loại</td><td><%=h(outProductInfo.getCategory().getCategoryName())%></td></tr>
      <tr><td class="key">Giá bán</td><td><strong><%=money(outProductInfo.getSellingPrice())%></strong></td></tr>
      <tr><td class="key">Tồn kho</td><td><%=outProductInfo.getInventory()%></td></tr>
      <tr><td class="key">Mô tả</td><td><%=h(outProductInfo.getDescription())%></td></tr>
    </table>
    </div>
  </div>
<% } %>

<div class="actions">
  <!-- subBack : link -->
  <div class="left"><a class="back" href="<%=backUrl%>">Quay lại</a></div>
  <% if (outProductInfo != null) { %>
  <div class="right">
    <!-- subAddToCart : submit -->
    <form method="get" action="ProductDetailUI4.jsp">
      <input type="hidden" name="selectedProductId" value="<%=outProductInfo.getId()%>">
      <input type="hidden" name="keyWord" value="<%=h(keyWord)%>">
      <button class="btn" type="submit" name="subAddToCart" value="1">Thêm vào giỏ</button>
    </form>
  </div>
  <% } %>
</div>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
