import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.point_of_sale,
                      size: 80.r,
                      color: Get.theme.colorScheme.primary,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: Validators.validateEmail,
                    ),
                    SizedBox(height: 20.h),
                    Obx(
                      () => TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              _obscurePassword.value = !_obscurePassword.value;
                            },
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Obx(
                      () => ElevatedButton(
                        onPressed: authController.isLoading ? null : _signIn,
                        child: authController.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppConstants.signupRoute);
                      },
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: TextStyle(color: Get.theme.colorScheme.primary),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Get.theme.colorScheme.primary),
                      ),
                    ),
                    if (authController.errorMessage != null) ...[
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          authController.errorMessage!,
                          style: TextStyle(
                            color: Get.theme.colorScheme.error,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();
      final success = await authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        Get.offAllNamed(AppConstants.dashboardRoute);
      }
    }
  }

  void _resetPassword() async {
    if (_emailController.text.isNotEmpty) {
      final authController = Get.find<AuthController>();
      final success = await authController.resetPassword(
        _emailController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          'Success',
          'Password reset email sent',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
