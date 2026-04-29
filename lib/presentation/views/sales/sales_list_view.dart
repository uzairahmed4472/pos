import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/sales_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/sale.dart';

class SalesListView extends StatelessWidget {
  const SalesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesController>(
      builder: (salesController) {
        return Column(
          children: [
            _buildStatsHeader(salesController),
            Expanded(
              child: Obx(
                () {
                  if (salesController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (salesController.sales.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No sales yet',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create your first sale to get started',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async => salesController.refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: salesController.sales.length,
                      itemBuilder: (context, index) {
                        final sale = salesController.sales[index];
                        return _SaleCard(sale: sale);
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

  Widget _buildStatsHeader(SalesController salesController) {
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
                'Today Sales',
                Formatters.formatCurrency(salesController.getTodaySalesTotal()),
                Get.theme.colorScheme.onPrimaryContainer,
              ),
              _buildStatItem(
                'Total Sales',
                Formatters.formatCurrency(salesController.getTotalSales()),
                Get.theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Today Count',
                '${salesController.getTodaySales().length}',
                Get.theme.colorScheme.onPrimaryContainer,
              ),
              _buildStatItem(
                'Total Count',
                '${salesController.getTotalSalesCount()}',
                Get.theme.colorScheme.onPrimaryContainer,
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

class _SaleCard extends StatelessWidget {
  final Sale sale;
  
  const _SaleCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => _showSaleDetails(sale),
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
                          'Sale #${sale.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Seller: ${sale.sellerName}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (sale.customer != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'Customer: ${sale.customer!.name}',
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
                        Formatters.formatCurrency(sale.finalAmount),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _buildStatusChip(sale.status),
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
                    '${sale.items.length} items',
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
                    Formatters.formatDateTime(sale.createdAt),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (sale.paymentMethod != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 16.r,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      sale.paymentMethod!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal: ${Formatters.formatCurrency(sale.totalAmount)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (sale.discount > 0)
                    Text(
                      'Discount: -${Formatters.formatCurrency(sale.discount)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red,
                      ),
                    ),
                  if (sale.tax > 0)
                    Text(
                      'Tax: ${Formatters.formatCurrency(sale.tax)}',
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

  Widget _buildStatusChip(SaleStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SaleStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case SaleStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case SaleStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case SaleStatus.refunded:
        color = Colors.purple;
        text = 'Refunded';
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

  void _showSaleDetails(Sale sale) {
    Get.dialog(
      _SaleDetailsDialog(sale: sale),
      barrierDismissible: true,
    );
  }
}

class _SaleDetailsDialog extends StatelessWidget {
  final Sale sale;
  
  const _SaleDetailsDialog({required this.sale});

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
                  'Sale Details',
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
            _buildSaleInfo(),
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
                itemCount: sale.items.length,
                itemBuilder: (context, index) {
                  final item = sale.items[index];
                  return _buildItemRow(item);
                },
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(),
            _buildTotals(),
            SizedBox(height: 16.h),
            if (sale.notes != null) ...[
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(sale.notes!),
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

  Widget _buildSaleInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Sale ID', sale.id.substring(0, 8).toUpperCase()),
        _buildInfoRow('Date', Formatters.formatDateTime(sale.createdAt)),
        _buildInfoRow('Seller', sale.sellerName),
        if (sale.customer != null)
          _buildInfoRow('Customer', sale.customer!.name),
        if (sale.customer?.phone != null)
          _buildInfoRow('Phone', sale.customer!.phone!),
        if (sale.paymentMethod != null)
          _buildInfoRow('Payment Method', sale.paymentMethod!),
        _buildInfoRow('Status', sale.status.name.toUpperCase()),
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

  Widget _buildItemRow(SaleItem item) {
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
        _buildTotalRow('Subtotal', Formatters.formatCurrency(sale.totalAmount)),
        if (sale.discount > 0)
          _buildTotalRow('Discount', '-${Formatters.formatCurrency(sale.discount)}', Colors.red),
        if (sale.tax > 0)
          _buildTotalRow('Tax', Formatters.formatCurrency(sale.tax), Colors.green),
        const Divider(),
        _buildTotalRow(
          'Total',
          Formatters.formatCurrency(sale.finalAmount),
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
