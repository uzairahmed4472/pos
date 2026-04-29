import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../../core/utils/validators.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        actions: [
          TextButton(onPressed: _saveProduct, child: const Text('Save')),
        ],
      ),
      body: GetBuilder<ProductController>(
        builder: (productController) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (value) =>
                        Validators.validateRequired(value, 'Product Name'),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: Validators.validatePrice,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: Validators.validateStock,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  if (productController.errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        productController.errorMessage!,
                        style: TextStyle(
                          color: Get.theme.colorScheme.error,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                  Obx(
                    () => ElevatedButton(
                      onPressed: productController.isLoading
                          ? null
                          : _saveProduct,
                      child: productController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Product'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final productController = Get.find<ProductController>();

      final success = await productController.addProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );

      if (success) {
        Get.back();
      }
    }
  }
}
