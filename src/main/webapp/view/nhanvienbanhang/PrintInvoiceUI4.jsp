<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "SALES"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // invoices : Invoice4[] - hóa đơn do AssignDeliveryUI4 tạo, chuyển qua InvoiceDetailUI4
    @SuppressWarnings("unchecked")
    ArrayList<Invoice4> invoices = (ArrayList<Invoice4>) session.getAttribute("invoices");
    if (invoices == null || invoices.isEmpty()) {
        response.sendRedirect("OrderListUI4.jsp");
        return;
    }

    // outPrintResult : label - mỗi hóa đơn một dòng kết quả, dòng cuối là tổng kết
    ArrayList<String> outPrintResult = new ArrayList<String>();
    ArrayList<Boolean> printOk = new ArrayList<Boolean>();
    int success = 0;
    String error = null;
    try (InvoiceDAO4 dao = new InvoiceDAO4()) {
        for (Invoice4 inv : invoices) {
            boolean ok = dao.printInvoice(inv);
            if (ok) success++;
            printOk.add(ok);
            outPrintResult.add("Hóa đơn " + invoiceCode(inv.getId()) + " (đơn " + orderCode(inv.getOrder().getId()) + "): "
                    + (ok ? "In thành công" : "In thất bại"));
        }
    } catch (Exception e) {
        error = e.getMessage();
    }
    boolean allOk = error == null && success == invoices.size();
%>
<% String pageTitle = "In hóa đơn", roleLabel = "Nhân viên bán hàng", pageClass = "PrintInvoiceUI4"; int currentStep = 4; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<div class="screen-only">
  <h1 class="page-title">In hóa đơn</h1>

  <% if (error != null) { %><div class="alert error"><%=h(error)%></div><% } %>

  <!-- outPrintResult : label (nhiều dòng) -->
  <div class="card">
    <div class="result-list">
      <% for (int k = 0; k < outPrintResult.size(); k++) { %>
        <div class="result <%= printOk.get(k) ? "ok" : "fail" %>"><%=h(outPrintResult.get(k))%></div>
      <% } %>
      <div class="result sum">Đã in thành công <%=success%>/<%=invoices.size()%> hóa đơn</div>
    </div>
  </div>

  <!-- subBack : link -->
  <p><a class="back" href="HomeUI4.jsp">Quay lại</a></p>
</div>

<!-- Nội dung hóa đơn (chỉ hiện khi in bằng hộp thoại in của trình duyệt) -->
<div class="print-area">
  <% for (Invoice4 inv : invoices) {
         Order4 o = inv.getOrder(); %>
  <div class="invoice">
    <h2>HÓA ĐƠN BÁN HÀNG - SHOPMAN</h2>
    <div class="meta">
      <div>Mã hóa đơn: <strong><%=invoiceCode(inv.getId())%></strong> &nbsp;|&nbsp; Ngày lập: <%=dateStr(inv.getCreatedDate())%> &nbsp;|&nbsp; Mã đơn: <%=orderCode(o.getId())%></div>
      <div>Khách hàng: <%=h(o.getCustomer().getFullName())%> &nbsp;|&nbsp; Điện thoại: <%=h(o.getCustomer().getPhone())%></div>
      <div>Địa chỉ giao hàng: <%=h(o.getCustomer().getAddress())%></div>
      <% if (o.getDeliveryStaff() != null) { %>
      <div>Nhân viên giao hàng: <%=h(o.getDeliveryStaff().getFullName())%> (<%=h(o.getDeliveryStaff().getPhone())%>)</div>
      <% } %>
    </div>
    <table class="data">
      <tr><th class="c">TT</th><th>Tên mặt hàng</th><th class="c">Số lượng</th><th class="r">Đơn giá</th><th class="r">Thành tiền</th></tr>
      <%
          int stt = 0;
          for (OrderDetail4 d : o.getOrderDetail()) {
              stt++;
      %>
      <tr>
        <td class="c"><%=stt%></td>
        <td><%=h(d.getProduct().getProductName())%></td>
        <td class="c"><%=d.getQuantity()%></td>
        <td class="r"><%=money(d.getSellingPrice())%></td>
        <td class="r"><%=money(d.getTotalAmount())%></td>
      </tr>
      <% } %>
      <tr><td colspan="4" class="r"><strong>Tổng cộng</strong></td><td class="r"><strong><%=money(inv.getTotalAmount())%></strong></td></tr>
    </table>
  </div>
  <% } %>
</div>

<% if (allOk) { %>
<script>window.addEventListener('load', function () { window.print(); });</script>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
