import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final authController = Get.find<AuthController>();
    
    if (authController.isAuthenticated) {
      Get.offAllNamed(AppConstants.dashboardRoute);
    } else {
      Get.offAllNamed(AppConstants.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.point_of_sale,
              size: 100.r,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Point of Sale System',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40.h),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3.w,
            ),
          ],
        ),
      ),
    );
  }
}
