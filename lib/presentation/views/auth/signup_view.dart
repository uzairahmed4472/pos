import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscureConfirmPassword = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add,
                    size: 80.r,
                    color: Get.theme.colorScheme.primary,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: Validators.validateName,
                  ),
                  SizedBox(height: 20.h),
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
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600]),
                        SizedBox(width: 12.w),
                        Text(
                          'Seller Account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
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
                  SizedBox(height: 20.h),
                  Obx(
                    () => TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            _obscureConfirmPassword.value =
                                !_obscureConfirmPassword.value;
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Obx(
                    () => ElevatedButton(
                      onPressed: authController.isLoading ? null : _signUp,
                      child: authController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Account'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Already have an account? Sign In',
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
          );
        },
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();
      final success = await authController.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        AppConstants.sellerRole, // Always seller role
      );

      if (success) {
        Get.snackbar(
          'Account Created',
          'Please wait for admin to grant permissions before logging in.',
          duration: const Duration(seconds: 4),
        );
        // Go back to login screen - sellers need admin approval
        Get.back();
      }
    }
  }
}
