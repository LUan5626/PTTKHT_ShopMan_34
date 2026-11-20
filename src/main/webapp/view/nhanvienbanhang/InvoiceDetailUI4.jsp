<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "SALES"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Danh sách hóa đơn do AssignDeliveryUI4 vừa tạo (invoices)
    @SuppressWarnings("unchecked")
    ArrayList<Invoice4> outInvoice = (ArrayList<Invoice4>) session.getAttribute("invoices");
    if (outInvoice == null || outInvoice.isEmpty()) {
        response.sendRedirect("OrderListUI4.jsp");
        return;
    }
    String message = (String) session.getAttribute("processingMessage");
    session.removeAttribute("processingMessage");
%>
<% String pageTitle = "Danh sách hóa đơn", roleLabel = "Nhân viên bán hàng", pageClass = "InvoiceDetailUI4"; int currentStep = 3; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<h1 class="page-title">Danh sách hóa đơn</h1>

<% if (message != null) { %><div class="alert info"><%=h(message)%></div><% } %>

<!-- outInvoice : table -->
<div class="card">
  <div class="table-wrap">
  <table class="data">
    <tr><th class="c">TT</th><th class="c">Mã hóa đơn</th><th class="c">Mã đơn</th><th>Khách hàng</th><th class="c">Ngày lập</th><th class="r">Tổng tiền</th></tr>
    <%
        int stt = 0;
        for (Invoice4 inv : outInvoice) {
            stt++;
    %>
    <tr>
      <td class="c"><%=stt%></td>
      <td class="c"><strong><%=invoiceCode(inv.getId())%></strong></td>
      <td class="c"><%=orderCode(inv.getOrder().getId())%></td>
      <td><%=h(inv.getOrder().getCustomer().getFullName())%></td>
      <td class="c"><%=dateStr(inv.getCreatedDate())%></td>
      <td class="r"><%=money(inv.getTotalAmount())%></td>
    </tr>
    <% } %>
  </table>
  </div>
</div>

<!-- subPrint : submit -->
<form method="post" action="PrintInvoiceUI4.jsp">
  <div class="actions">
    <div class="right"><button class="btn" type="submit" name="subPrint" value="1">In hóa đơn</button></div>
  </div>
</form>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
