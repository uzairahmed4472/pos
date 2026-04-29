import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product.dart';
import 'add_product_view.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          GetBuilder<AuthController>(
            builder: (authController) {
              if (authController.hasPermission('products', 'create')) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Get.to(() => const AddProductView()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: GetBuilder<ProductController>(
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  onChanged: controller.searchProducts,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredProducts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80.r,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            controller.searchQuery.isNotEmpty
                                ? 'No products found'
                                : 'No products available',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (controller.searchQuery.isEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'Add your first product to get started',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => controller.refresh(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: controller.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.filteredProducts[index];
                        return _ProductCard(product: product);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to product detail view
          Get.snackbar('Product Details', 'Viewing ${product.name}');
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product.category != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            product.category!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        if (product.sku != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'SKU: ${product.sku}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
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
                        Formatters.formatCurrency(product.price),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _StockIndicator(stock: product.stock),
                    ],
                  ),
                ],
              ),
              if (product.description.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock: ${Formatters.formatQuantity(product.stock)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: product.isLowStock
                          ? Colors.orange
                          : Colors.grey[600],
                      fontWeight: product.isLowStock
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Row(
                    children: [
                      if (authController.hasPermission('products', 'edit'))
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            // TODO: Navigate to edit product view
                            Get.snackbar(
                              'Edit Product',
                              'Editing ${product.name}',
                            );
                          },
                        ),
                      if (authController.hasPermission('products', 'delete'))
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteProduct(product),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteProduct(Product product) {
    Get.defaultDialog(
      title: 'Delete Product',
      titleStyle: TextStyle(fontSize: 18.sp),
      middleText: 'Are you sure you want to delete ${product.name}?',
      middleTextStyle: TextStyle(fontSize: 16.sp),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () {
        Get.back();
        final controller = Get.find<ProductController>();
        controller.deleteProduct(product.id);
      },
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;

  const _StockIndicator({required this.stock});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (stock == 0) {
      color = Colors.red;
      text = 'Out of Stock';
    } else if (stock <= 5) {
      color = Colors.orange;
      text = 'Low Stock';
    } else {
      color = Colors.green;
      text = 'In Stock';
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
}
