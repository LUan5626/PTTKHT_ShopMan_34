<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "CUSTOMER"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // inProductName : textField, subSearch : submit
    String inProductName = request.getParameter("inProductName");
    if (inProductName == null) inProductName = "";
    boolean searched = request.getParameter("subSearch") != null;

    // keyWord : string - từ khóa của lần tìm kiếm, được chuyển sang ProductDetailUI4 để quay lại đúng kết quả
    String keyWord = inProductName;

    // outProductList : table
    ArrayList<Product4> outProductList = null;
    String error = null;
    if (searched) {
        try (ProductDAO4 dao = new ProductDAO4()) {
            outProductList = dao.searchProduct(keyWord);
        } catch (Exception e) {
            error = e.getMessage();
        }
    }
%>
<% String pageTitle = "Tìm kiếm mặt hàng", roleLabel = "Khách hàng", pageClass = "SearchProductUI4"; int currentStep = 0; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<h1 class="page-title">Tìm kiếm mặt hàng</h1>

<div class="card">
  <form class="searchbar" method="get" action="SearchProductUI4.jsp">
    <div class="field">
      <label for="inProductName">Tên mặt hàng</label>
      <input type="text" id="inProductName" name="inProductName" value="<%=h(inProductName)%>" placeholder="Ví dụ: sữa, gạo, dầu ăn">
    </div>
    <div class="go"><button class="btn" type="submit" name="subSearch" value="1">Tìm kiếm</button></div>
  </form>
</div>

<% if (error != null) { %>
  <div class="alert error"><%=h(error)%></div>
<% } else if (searched) { %>
  <% if (outProductList == null || outProductList.isEmpty()) { %>
    <div class="card empty-state">
      <p>Không có mặt hàng phù hợp với từ khóa "<strong><%=h(keyWord)%></strong>".</p>
    </div>
  <% } else { %>
    <div class="card">
      <p class="count">Tìm thấy <strong><%=outProductList.size()%></strong> mặt hàng cho từ khóa "<%=h(keyWord)%>"</p>
      <div class="table-wrap">
      <table class="data">
        <tr><th class="c">TT</th><th class="c">Hình ảnh</th><th>Tên mặt hàng</th><th class="r">Giá bán</th><th class="c">Tồn kho</th><th class="c">Chi tiết</th></tr>
        <%
            int stt = 0;
            for (Product4 p : outProductList) {
                stt++;
        %>
        <tr>
          <td class="c"><%=stt%></td>
          <td class="c">
            <% if (p.getImage() != null && !p.getImage().trim().isEmpty()) { %>
              <img src="<%=request.getContextPath()%>/<%=h(p.getImage())%>" alt="<%=h(p.getProductName())%>">
            <% } else { %><span class="muted">Chưa có ảnh</span><% } %>
          </td>
          <td><strong><%=h(p.getProductName())%></strong></td>
          <td class="r"><%=money(p.getSellingPrice())%></td>
          <td class="c"><%=p.getInventory()%></td>
          <td class="c">
            <!-- subSelectProduct : submit (kèm selectedProductId và keyWord) -->
            <form method="get" action="ProductDetailUI4.jsp">
              <input type="hidden" name="selectedProductId" value="<%=p.getId()%>">
              <input type="hidden" name="keyWord" value="<%=h(keyWord)%>">
              <button class="btn btn-outline" type="submit" name="subSelectProduct" value="1">Chọn</button>
            </form>
          </td>
        </tr>
        <% } %>
      </table>
      </div>
    </div>
  <% } %>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
