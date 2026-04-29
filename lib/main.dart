import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/themes/app_theme.dart';
import 'data/services/firebase_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/product_controller.dart';
import 'presentation/controllers/sales_controller.dart';
import 'presentation/controllers/invoice_controller.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  await FirebaseService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'POS System',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: '/splash',
          getPages: AppPages.routes,
          initialBinding: InitialBindings(),
        );
      },
    );
  }
}

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService.instance, permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(ProductController(), permanent: true);
    Get.put(SalesController(), permanent: true);
    Get.put(InvoiceController(), permanent: true);
  }
}
