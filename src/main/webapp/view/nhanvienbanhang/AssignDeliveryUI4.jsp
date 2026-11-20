<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/common.jspf" %>
<% String requiredRole = "SALES"; %>
<%@ include file="/WEB-INF/jspf/auth.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");

    // Danh sách mã đơn được chọn ở OrderListUI4 (selectedOrders)
    String[] selectedOrders = request.getParameterValues("selectedOrders");
    if (selectedOrders == null || selectedOrders.length == 0) {
        session.setAttribute("processingMessage", "Vui lòng chọn ít nhất một đơn hàng.");
        response.sendRedirect("OrderListUI4.jsp");
        return;
    }

    // outDeliveryStaffList : table
    ArrayList<DeliveryStaff4> outDeliveryStaffList = null;
    String error = null;
    try (DeliveryStaffDAO4 staffDAO = new DeliveryStaffDAO4()) {
        outDeliveryStaffList = staffDAO.getDeliveryStaffList();
    } catch (Exception e) {
        error = e.getMessage();
    }

    // subConfirm : submit - nhân viên bán hàng đã chọn nhân viên giao hàng và xác nhận
    if (error == null && request.getParameter("subConfirm") != null) {
        // inDeliveryStaff : radio
        String inDeliveryStaff = request.getParameter("inDeliveryStaff");
        DeliveryStaff4 deliveryStaff = null;
        if (inDeliveryStaff != null) {
            for (DeliveryStaff4 s : outDeliveryStaffList) {
                if (String.valueOf(s.getId()).equals(inDeliveryStaff)) deliveryStaff = s;
            }
        }

        if (deliveryStaff == null) {
            error = "Vui lòng chọn một nhân viên giao hàng.";
        } else {
            ArrayList<Invoice4> invoices = new ArrayList<Invoice4>();
            ArrayList<String> failures = new ArrayList<String>();
            Connection con = null;
            try {
                // Các DAO dùng chung một kết nối để mỗi đơn là một transaction:
                // trừ kho + phân công + tạo hóa đơn cùng thành công, hoặc hoàn tác toàn bộ đơn đó.
                con = DAO4.openConnection();
                con.setAutoCommit(false);
                OrderDAO4 orderDAO = new OrderDAO4(con);
                ProductDAO4 productDAO = new ProductDAO4(con);
                InvoiceDAO4 invoiceDAO = new InvoiceDAO4(con);

                ArrayList<Order4> pending = orderDAO.getOrderList();   // các đơn còn "Chưa xuất", kèm chi tiết

                for (String idText : selectedOrders) {
                    int orderId;
                    try {
                        orderId = Integer.parseInt(idText.trim());
                    } catch (NumberFormatException ex) {
                        continue;
                    }
                    Order4 order = null;
                    for (Order4 o : pending) {
                        if (o.getId() == orderId) order = o;
                    }
                    if (order == null) {
                        failures.add(orderCode(orderId) + ": đơn đã được xử lý hoặc không còn ở trạng thái \"Chưa xuất\"");
                        continue;
                    }

                    try {
                        String reason = null;
                        // 1. Trừ tồn kho từng mặt hàng trong đơn
                        for (OrderDetail4 d : order.getOrderDetail()) {
                            if (!productDAO.updateStock(d.getProduct(), d.getQuantity())) {
                                reason = "không đủ tồn kho \"" + d.getProduct().getProductName() + "\" (cần " + d.getQuantity() + ")";
                                break;
                            }
                        }
                        // 2. Đóng gói vào đơn: trạng thái "Đã xuất", nhân viên giao hàng, nhân viên bán hàng (người đang đăng nhập), rồi lưu
                        if (reason == null) {
                            order.setStatus(OrderDAO4.DA_XUAT);
                            order.setDeliveryStaff(deliveryStaff);
                            order.setSalesStaff((SalesStaff4) loginUser);
                        }
                        if (reason == null && !orderDAO.assignDelivery(order)) {
                            reason = "đơn đã được nhân viên khác xử lý";
                        }
                        // 3. Tạo hóa đơn
                        Invoice4 invoice = null;
                        if (reason == null) {
                            invoice = invoiceDAO.createInvoice(order);
                            if (invoice == null) reason = "không tạo được hóa đơn";
                        }

                        if (reason == null) {
                            con.commit();
                            invoices.add(invoice);
                        } else {
                            con.rollback();
                            failures.add(orderCode(orderId) + ": " + reason);
                        }
                    } catch (SQLException ex) {
                        con.rollback();
                        failures.add(orderCode(orderId) + ": lỗi hệ thống (" + ex.getMessage() + ")");
                    }
                }
            } catch (SQLException ex) {
                error = "Lỗi cơ sở dữ liệu: " + ex.getMessage();
            } finally {
                if (con != null) {
                    try { con.close(); } catch (SQLException ignore) { }
                }
            }

            if (error == null) {
                StringBuilder msg = new StringBuilder("Đã xuất kho thành công " + invoices.size() + " đơn hàng");
                if (!failures.isEmpty()) {
                    msg.append("; ").append(failures.size()).append(" đơn không xử lý được: ");
                    for (int i = 0; i < failures.size(); i++) {
                        if (i > 0) msg.append("; ");
                        msg.append(failures.get(i));
                    }
                }
                msg.append(".");
                session.setAttribute("processingMessage", msg.toString());
                if (invoices.isEmpty()) {
                    response.sendRedirect("OrderListUI4.jsp");
                } else {
                    session.setAttribute("invoices", invoices);
                    response.sendRedirect("InvoiceDetailUI4.jsp");
                }
                return;
            }
        }
    }
%>
<% String pageTitle = "Phân công giao hàng", roleLabel = "Nhân viên bán hàng", pageClass = "AssignDeliveryUI4"; int currentStep = 2; %>
<%@ include file="/WEB-INF/jspf/header.jspf" %>

<h1 class="page-title">Phân công giao hàng</h1>

<% if (error != null) { %><div class="alert error"><%=h(error)%></div><% } %>

<div class="chips">
  <span class="lbl">Đơn đã chọn:</span>
  <% for (String idText : selectedOrders) { %><span class="chip"><%=orderCodeOf(idText)%></span><% } %>
</div>

<% if (outDeliveryStaffList == null) { %>
  <p><a class="back" href="OrderListUI4.jsp">Quay lại</a></p>
<% } else if (outDeliveryStaffList.isEmpty()) { %>
  <div class="card empty-state">
    <p>Chưa có nhân viên giao hàng nào.</p>
  </div>
  <p><a class="back" href="OrderListUI4.jsp">Quay lại</a></p>
<% } else { %>
  <form method="post" action="AssignDeliveryUI4.jsp">
    <% for (String idText : selectedOrders) { %>
      <input type="hidden" name="selectedOrders" value="<%=h(idText)%>">
    <% } %>
    <div class="card">
      <div class="table-wrap">
      <table class="data selectable">
        <tr><th class="c">Chọn</th><th class="c">Mã NV</th><th>Họ tên</th><th>Số điện thoại</th></tr>
        <% for (DeliveryStaff4 s : outDeliveryStaffList) { %>
        <tr onclick="this.getElementsByTagName('input')[0].checked = true;">
          <td class="c"><input type="radio" name="inDeliveryStaff" value="<%=s.getId()%>"
              <%= String.valueOf(s.getId()).equals(request.getParameter("inDeliveryStaff")) ? "checked" : "" %>></td>
          <td class="c"><strong>NV<%=String.format("%02d", s.getId())%></strong></td>
          <td><%=h(s.getFullName())%></td>
          <td><%=h(s.getPhone())%></td>
        </tr>
        <% } %>
      </table>
      </div>
    </div>
    <div class="actions">
      <!-- subBack : link -->
      <div class="left"><a class="back" href="OrderListUI4.jsp">Quay lại</a></div>
      <div class="right"><button class="btn" type="submit" name="subConfirm" value="1">Xác nhận</button></div>
    </div>
  </form>
<% } %>
<%@ include file="/WEB-INF/jspf/footer.jspf" %>
