<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "SALES"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Thông báo kết quả của lượt xử lý trước (nếu có)
    String message = (String) session.getAttribute("processingMessage");
    session.removeAttribute("processingMessage");

    // outOrderList : table - các đơn "Chưa xuất"
    ArrayList<Order4> outOrderList = null;
    String error = null;
    try (OrderDAO4 dao = new OrderDAO4()) {
        outOrderList = dao.getOrderList();
    } catch (Exception e) {
        error = e.getMessage();
    }
%>
<% String pageTitle = "Duyệt đơn", roleLabel = "Nhân viên bán hàng", pageClass = "OrderListUI4"; int currentStep = 1; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<h1 class="page-title">Đơn hàng chưa xuất</h1>

<% if (message != null) { %><div class="alert info"><%=h(message)%></div><% } %>
<% if (error != null) { %>
  <div class="alert error"><%=h(error)%></div>
<% } else if (outOrderList == null || outOrderList.isEmpty()) { %>
  <div class="card empty-state">
    <p>Không có đơn hàng chưa xuất.</p>
  </div>
<% } else { %>
  <!-- selectedOrders : Order4[] (checkbox), subSelectOrder : submit -->
  <form method="post" action="AssignDeliveryUI4.jsp"
        onsubmit="if (!document.querySelector('input[name=selectedOrders]:checked')) { alert('Vui lòng chọn ít nhất một đơn hàng.'); return false; }">
    <div class="card">
      <div class="table-wrap">
      <table class="data selectable">
        <tr><th class="c">Chọn</th><th class="c">Mã đơn</th><th>Khách hàng</th><th class="c">Ngày đặt</th><th class="r">Tổng tiền</th></tr>
        <% for (Order4 o : outOrderList) { %>
        <tr onclick="var c=this.getElementsByTagName('input')[0]; if (event.target !== c) { c.checked = !c.checked; } this.className = c.checked ? 'selected' : '';">
          <td class="c"><input type="checkbox" name="selectedOrders" value="<%=o.getId()%>"></td>
          <td class="c"><strong><%=orderCode(o.getId())%></strong></td>
          <td><%=h(o.getCustomer().getFullName())%></td>
          <td class="c"><%=dateStr(o.getOrderDate())%></td>
          <td class="r"><%=money(o.getTotalAmount())%></td>
        </tr>
        <% } %>
      </table>
      </div>
    </div>
    <div class="actions">
      <div class="right"><button class="btn" type="submit" name="subSelectOrder" value="1">Tiếp tục</button></div>
    </div>
  </form>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
