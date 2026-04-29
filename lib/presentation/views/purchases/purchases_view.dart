import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PurchasesView extends StatelessWidget {
  const PurchasesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchases'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create purchase screen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80.r,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20.h),
            Text(
              'Purchases Module',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Purchase management coming soon...',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
