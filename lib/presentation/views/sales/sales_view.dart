import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'create_sale_view.dart';
import 'sales_list_view.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sales'),
            actions: [
              if (authController.hasPermission('sales', 'create'))
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => Get.to(() => const CreateSaleView()),
                ),
            ],
          ),
          body: const SalesListView(),
        );
      },
    );
  }
}
