import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/views/splash/splash_view.dart';
import '../presentation/views/auth/login_view.dart';
import '../presentation/views/auth/signup_view.dart';
import '../presentation/views/dashboard/dashboard_view.dart';
import '../presentation/views/products/products_view.dart';
import '../presentation/views/sales/sales_view.dart';
import '../presentation/views/purchases/purchases_view.dart';
import '../presentation/views/invoices/invoices_view.dart';
import '../presentation/views/users/users_view.dart';
import '../presentation/views/profile/profile_view.dart';
import '../presentation/middlewares/auth_middleware.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppConstants.splashRoute,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppConstants.loginRoute,
      page: () => const LoginView(),
      middlewares: [AuthMiddleware(allowGuest: true)],
    ),
    GetPage(
      name: AppConstants.signupRoute,
      page: () => const SignupView(),
      middlewares: [AuthMiddleware(allowGuest: true)],
    ),
    GetPage(
      name: AppConstants.dashboardRoute,
      page: () => const DashboardView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppConstants.productsRoute,
      page: () => const ProductsView(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware(AppConstants.productsPermission, AppConstants.viewAction),
      ],
    ),
    GetPage(
      name: AppConstants.salesRoute,
      page: () => const SalesView(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware(AppConstants.salesPermission, AppConstants.viewAction),
      ],
    ),
    GetPage(
      name: AppConstants.purchasesRoute,
      page: () => const PurchasesView(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware(AppConstants.purchasesPermission, AppConstants.viewAction),
      ],
    ),
    GetPage(
      name: AppConstants.invoicesRoute,
      page: () => const InvoicesView(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware(AppConstants.invoicesPermission, AppConstants.viewAction),
      ],
    ),
    GetPage(
      name: AppConstants.usersRoute,
      page: () => const UsersView(),
      middlewares: [
        AuthMiddleware(),
        PermissionMiddleware(AppConstants.usersPermission, AppConstants.viewAction),
      ],
    ),
    GetPage(
      name: AppConstants.profileRoute,
      page: () => const ProfileView(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
