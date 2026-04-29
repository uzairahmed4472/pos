import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  final bool allowGuest;
  
  AuthMiddleware({this.allowGuest = false});
  
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (!allowGuest && !authController.isAuthenticated) {
      return const RouteSettings(name: AppConstants.loginRoute);
    }
    
    if (allowGuest && authController.isAuthenticated) {
      return const RouteSettings(name: AppConstants.dashboardRoute);
    }
    
    return null;
  }
}

class PermissionMiddleware extends GetMiddleware {
  final String module;
  final String action;
  
  PermissionMiddleware(this.module, this.action);
  
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (!authController.hasPermission(module, action)) {
      Get.snackbar(
        'Access Denied',
        'You don\'t have permission to access this module',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return const RouteSettings(name: AppConstants.dashboardRoute);
    }
    
    return null;
  }
}
