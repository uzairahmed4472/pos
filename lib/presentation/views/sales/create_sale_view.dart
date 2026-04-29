import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/sales_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product.dart';

class CreateSaleView extends StatelessWidget {
  const CreateSaleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sale'),
        actions: [
          Obx(
            () => TextButton(
              onPressed: Get.find<SalesController>().cartItems.isEmpty
                  ? null
                  : _showCheckoutDialog,
              child: const Text('Checkout'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [_buildCartHeader(), _buildProductList(), _buildCartItems()],
      ),
    );
  }

  Widget _buildCartHeader() {
    return GetBuilder<SalesController>(
      builder: (salesController) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.circular(16.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cart',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${salesController.totalItems} items',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:'),
                  Text(
                    Formatters.formatCurrency(salesController.subtotal),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    return GetBuilder<ProductController>(
      builder: (productController) {
        return Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          onChanged: productController.searchProducts,
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (productController.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productController.filteredProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: productController.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product =
                            productController.filteredProducts[index];
                        return _ProductTile(product: product);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItems() {
    return GetBuilder<SalesController>(
      builder: (salesController) {
        if (salesController.cartItems.isEmpty) {
          return Container(
            height: 150.h,
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48.r,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Cart is empty',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: 150.h,
          padding: EdgeInsets.all(16.w),
          child: ListView.builder(
            itemCount: salesController.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = salesController.cartItems[index];
              return _CartItemTile(cartItem: cartItem);
            },
          ),
        );
      },
    );
  }

  void _showCheckoutDialog() {
    Get.dialog(const CheckoutDialog(), barrierDismissible: false);
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final salesController = Get.find<SalesController>();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Get.theme.colorScheme.primary,
        child: Icon(Icons.inventory_2, color: Colors.white, size: 20.r),
      ),
      title: Text(product.name),
      subtitle: Text(
        'Stock: ${product.stock} | ${Formatters.formatCurrency(product.price)}',
        style: TextStyle(
          fontSize: 12.sp,
          color: product.isLowStock ? Colors.orange : Colors.grey[600],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add_shopping_cart),
        onPressed: product.stock > 0
            ? () => salesController.addToCart(product)
            : () =>
                  Get.snackbar('Out of Stock', 'This product is out of stock'),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const _CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final salesController = Get.find<SalesController>();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              cartItem.product.name,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => salesController.updateQuantity(
                  cartItem.product.id,
                  cartItem.quantity - 1,
                ),
              ),
              Container(
                width: 40.w,
                alignment: Alignment.center,
                child: Text(
                  cartItem.quantity.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => salesController.updateQuantity(
                  cartItem.product.id,
                  cartItem.quantity + 1,
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          Text(
            Formatters.formatCurrency(cartItem.totalPrice),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () =>
                salesController.removeFromCart(cartItem.product.id),
          ),
        ],
      ),
    );
  }
}

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _customerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentMethod = 'Cash'.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesController>(
      builder: (salesController) {
        return Dialog(
          child: Container(
            width: 400.w,
            height: 600.h,
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Customer Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _customerController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name (Optional)',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone (Optional)',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Payment Details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _paymentMethod.value,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'Card', child: Text('Card')),
                        DropdownMenuItem(
                          value: 'Mobile',
                          child: Text('Mobile'),
                        ),
                      ],
                      onChanged: (value) => _paymentMethod.value = value!,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount',
                      prefixIcon: Icon(Icons.discount),
                    ),
                    onChanged: (value) {
                      final discount = double.tryParse(value) ?? 0.0;
                      salesController.setDiscount(discount);
                    },
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _taxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tax',
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                    onChanged: (value) {
                      final tax = double.tryParse(value) ?? 0.0;
                      salesController.setTax(tax);
                    },
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                    onChanged: salesController.setNotes,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[500],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text(
                              Formatters.formatCurrency(
                                salesController.subtotal,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Discount:'),
                            Text(
                              '-${Formatters.formatCurrency(salesController.discount)}',
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax:'),
                            Text(
                              Formatters.formatCurrency(salesController.tax),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(
                                salesController.totalAmount,
                              ),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: 8.w),
                      Obx(
                        () => ElevatedButton(
                          onPressed: salesController.isLoading
                              ? null
                              : () => _completeSale(salesController),
                          child: salesController.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Complete Sale'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _completeSale(SalesController salesController) async {
    // Set customer if provided
    if (_customerController.text.isNotEmpty) {
      // TODO: Create customer object and set it
    }

    salesController.setPaymentMethod(_paymentMethod.value);

    final success = await salesController.createSale();
    if (success) {
      Get.back(); // Close dialog
      Get.back(); // Go back to sales list
    }
  }
}
