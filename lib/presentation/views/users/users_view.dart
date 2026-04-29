import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/auth_controller.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    authController.loadSellers();

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Obx(() {
        if (authController.isLoading && authController.sellers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (authController.sellers.isEmpty) {
          return Center(
            child: Text(
              'No sellers found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: authController.sellers.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final seller = authController.sellers[index];
            return _SellerTile(seller: seller);
          },
        );
      }),
    );
  }
}

class _SellerTile extends StatelessWidget {
  final User seller;

  const _SellerTile({required this.seller});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              seller.name,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              seller.email,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: seller.isActive
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    seller.isActive ? 'Approved' : 'Pending',
                    style: TextStyle(
                      color: seller.isActive
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _openPermissionsDialog(context, seller),
                  child: const Text('Permissions'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final approved = await authController.updateSellerApproval(
                      sellerId: seller.id,
                      isActive: !seller.isActive,
                      permissions: !seller.isActive
                          ? UserPermissions.defaultSeller()
                          : null,
                    );
                    if (approved) {
                      Get.snackbar(
                        'Updated',
                        !seller.isActive
                            ? 'Seller approved successfully'
                            : 'Seller moved back to pending',
                      );
                    }
                  },
                  child: Text(seller.isActive ? 'Set Pending' : 'Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPermissionsDialog(BuildContext context, User user) async {
    final authController = Get.find<AuthController>();
    final modules = [
      AppConstants.salesPermission,
      AppConstants.productsPermission,
      AppConstants.purchasesPermission,
      AppConstants.invoicesPermission,
      AppConstants.usersPermission,
    ];
    final actions = [
      AppConstants.viewAction,
      AppConstants.createAction,
      AppConstants.editAction,
      AppConstants.deleteAction,
    ];

    final working = <String, Map<String, bool>>{};
    for (final module in modules) {
      working[module] = {
        for (final action in actions)
          action: user.hasPermission(module, action),
      };
    }

    await Get.dialog(
      AlertDialog(
        title: Text('Permissions - ${user.name}'),
        content: SizedBox(
          width: 380.w,
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: modules.map((module) {
                    return SizedBox(
                      width: double.infinity,
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 6.h),
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 4.h,
                                children: actions.map((action) {
                                  return FilterChip(
                                    label: Text(action),
                                    selected: working[module]![action] ?? false,
                                    onSelected: (selected) {
                                      setState(() {
                                        working[module]![action] = selected;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final permissionMap = <String, PermissionSet>{};
              for (final module in modules) {
                permissionMap[module] = PermissionSet(
                  view: working[module]![AppConstants.viewAction] ?? false,
                  create: working[module]![AppConstants.createAction] ?? false,
                  edit: working[module]![AppConstants.editAction] ?? false,
                  delete: working[module]![AppConstants.deleteAction] ?? false,
                );
              }

              final updated = await authController.updateSellerApproval(
                sellerId: user.id,
                isActive: true,
                permissions: UserPermissions(permissions: permissionMap),
              );

              if (updated) {
                Get.back();
                Get.snackbar('Success', 'Permissions updated');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
