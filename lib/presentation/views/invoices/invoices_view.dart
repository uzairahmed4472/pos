import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/invoice_controller.dart';
import 'invoice_list_view.dart';

class InvoicesView extends StatelessWidget {
  const InvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Invoices'),
            actions: [
              if (authController.hasPermission('invoices', 'view'))
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // TODO: Implement search functionality
                  },
                ),
            ],
          ),
          body: const InvoiceListView(),
        );
      },
    );
  }
}
