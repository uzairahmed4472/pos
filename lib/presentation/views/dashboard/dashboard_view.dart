import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.toNamed(AppConstants.profileRoute);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authController.currentUser?.name ?? 'User'}!',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Role: ${authController.currentUser?.role?.toUpperCase() ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30.h),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    children: [
                      if (authController.hasPermission(AppConstants.salesPermission, AppConstants.viewAction))
                        _buildMenuCard(
                          'Sales',
                          Icons.shopping_cart,
                          Colors.blue,
                          () => Get.toNamed(AppConstants.salesRoute),
                        ),
                      if (authController.hasPermission(AppConstants.productsPermission, AppConstants.viewAction))
                        _buildMenuCard(
                          'Products',
                          Icons.inventory,
                          Colors.green,
                          () => Get.toNamed(AppConstants.productsRoute),
                        ),
                      if (authController.hasPermission(AppConstants.purchasesPermission, AppConstants.viewAction))
                        _buildMenuCard(
                          'Purchases',
                          Icons.receipt_long,
                          Colors.orange,
                          () => Get.toNamed(AppConstants.purchasesRoute),
                        ),
                      if (authController.hasPermission(AppConstants.invoicesPermission, AppConstants.viewAction))
                        _buildMenuCard(
                          'Invoices',
                          Icons.description,
                          Colors.purple,
                          () => Get.toNamed(AppConstants.invoicesRoute),
                        ),
                      if (authController.hasPermission(AppConstants.usersPermission, AppConstants.viewAction))
                        _buildMenuCard(
                          'Users',
                          Icons.people,
                          Colors.red,
                          () => Get.toNamed(AppConstants.usersRoute),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.r,
                color: color,
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    Get.defaultDialog(
      title: 'Logout',
      titleStyle: TextStyle(fontSize: 18.sp),
      middleText: 'Are you sure you want to logout?',
      middleTextStyle: TextStyle(fontSize: 16.sp),
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        final authController = Get.find<AuthController>();
        authController.signOut();
      },
    );
  }
}
