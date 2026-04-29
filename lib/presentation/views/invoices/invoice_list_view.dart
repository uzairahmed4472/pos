import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/invoice_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/invoice.dart';

class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(
      builder: (invoiceController) {
        return Column(
          children: [
            _buildStatsHeader(invoiceController),
            Expanded(
              child: Obx(
                () {
                  if (invoiceController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (invoiceController.invoices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 80.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No invoices yet',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Invoices will be created automatically when sales are completed',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async => invoiceController.refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: invoiceController.invoices.length,
                      itemBuilder: (context, index) {
                        final invoice = invoiceController.invoices[index];
                        return _InvoiceCard(invoice: invoice);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsHeader(InvoiceController invoiceController) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Today Invoices',
                Formatters.formatCurrency(invoiceController.getTodayInvoicesTotal()),
                Get.theme.colorScheme.onPrimaryContainer,
              ),
              _buildStatItem(
                'Total Invoices',
                Formatters.formatCurrency(invoiceController.getTotalInvoicesAmount()),
                Get.theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Unpaid',
                Formatters.formatCurrency(invoiceController.getUnpaidInvoicesTotal()),
                Colors.orange,
              ),
              _buildStatItem(
                'Overdue',
                Formatters.formatCurrency(invoiceController.getOverdueInvoicesTotal()),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  
  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Seller: ${invoice.sellerName}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (invoice.customer != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'Customer: ${invoice.customer!.name}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(invoice.totalAmount),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildStatusChip(invoice.status),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16.r,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${invoice.items.length} items',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 16.r,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    Formatters.formatDate(invoice.invoiceDate),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16.r,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Due: ${Formatters.formatDate(invoice.dueDate)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: invoice.dueDate.isBefore(DateTime.now()) 
                          ? Colors.red 
                          : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (invoice.paymentMethod != null) ...[
                    Icon(
                      Icons.payment,
                      size: 16.r,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      invoice.paymentMethod!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal: ${Formatters.formatCurrency(invoice.subtotal)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (invoice.discount > 0)
                    Text(
                      'Discount: -${Formatters.formatCurrency(invoice.discount)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    ),
                  if (invoice.tax > 0)
                    Text(
                      'Tax: ${Formatters.formatCurrency(invoice.tax)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case InvoiceStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case InvoiceStatus.sent:
        color = Colors.blue;
        text = 'Sent';
        break;
      case InvoiceStatus.paid:
        color = Colors.green;
        text = 'Paid';
        break;
      case InvoiceStatus.overdue:
        color = Colors.red;
        text = 'Overdue';
        break;
      case InvoiceStatus.cancelled:
        color = Colors.black;
        text = 'Cancelled';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    Get.dialog(
      _InvoiceDetailsDialog(invoice: invoice),
      barrierDismissible: true,
    );
  }
}

class _InvoiceDetailsDialog extends StatelessWidget {
  final Invoice invoice;
  
  const _InvoiceDetailsDialog({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500.w,
        constraints: BoxConstraints(maxHeight: 600.h),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildInvoiceHeader(),
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 16.h),
            Text(
              'Items',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: ListView.builder(
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  return _buildItemRow(item);
                },
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(),
            _buildTotals(),
            SizedBox(height: 16.h),
            if (invoice.notes != null) ...[
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(invoice.notes!),
              SizedBox(height: 16.h),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Invoice Number', invoice.invoiceNumber),
        _buildInfoRow('Invoice Date', Formatters.formatDate(invoice.invoiceDate)),
        _buildInfoRow('Due Date', Formatters.formatDate(invoice.dueDate)),
        _buildInfoRow('Seller', invoice.sellerName),
        if (invoice.customer != null)
          _buildInfoRow('Customer', invoice.customer!.name),
        if (invoice.customer?.phone != null)
          _buildInfoRow('Phone', invoice.customer!.phone!),
        if (invoice.paymentMethod != null)
          _buildInfoRow('Payment Method', invoice.paymentMethod!),
        _buildInfoRow('Status', invoice.status.name.toUpperCase()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatCurrency(item.unitPrice),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'x ${item.quantity}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            Formatters.formatCurrency(item.totalPrice),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Column(
      children: [
        _buildTotalRow('Subtotal', Formatters.formatCurrency(invoice.subtotal)),
        if (invoice.discount > 0)
          _buildTotalRow('Discount', '-${Formatters.formatCurrency(invoice.discount)}', Colors.red),
        if (invoice.tax > 0)
          _buildTotalRow('Tax', Formatters.formatCurrency(invoice.tax), Colors.green),
        const Divider(),
        _buildTotalRow(
          'Total',
          Formatters.formatCurrency(invoice.totalAmount),
          Get.theme.colorScheme.primary,
          true,
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, [Color? color, bool isBold = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
