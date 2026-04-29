import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          final user = authController.currentUser;
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Get.theme.colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 50.r,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Text(
                    user?.name ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Chip(
                    label: Text(
                      user?.role.toUpperCase() ?? 'UNKNOWN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    backgroundColor: Get.theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 40.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInfoRow('Name', user?.name ?? 'N/A'),
                        _buildInfoRow('Email', user?.email ?? 'N/A'),
                        _buildInfoRow('Role', user?.role ?? 'N/A'),
                        _buildInfoRow('Status', user?.isActive == true ? 'Active' : 'Inactive'),
                        _buildInfoRow(
                          'Member Since',
                          user?.createdAt != null 
                              ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                              : 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permissions',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        if (user?.isAdmin == true) ...[
                          _buildPermissionRow('Full System Access', true),
                        ] else ...[
                          _buildPermissionRow('Sales', user?.hasPermission('sales', 'view') ?? false),
                          _buildPermissionRow('Products', user?.hasPermission('products', 'view') ?? false),
                          _buildPermissionRow('Purchases', user?.hasPermission('purchases', 'view') ?? false),
                          _buildPermissionRow('Invoices', user?.hasPermission('invoices', 'view') ?? false),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Back'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String module, bool hasAccess) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            module,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          Icon(
            hasAccess ? Icons.check_circle : Icons.cancel,
            color: hasAccess ? Colors.green : Colors.red,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}
