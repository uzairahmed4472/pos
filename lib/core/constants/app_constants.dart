class AppConstants {
  // App Info
  static const String appName = 'POS System';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String salesCollection = 'sales';
  static const String purchasesCollection = 'purchases';
  static const String invoicesCollection = 'invoices';
  
  // User Roles
  static const String adminRole = 'admin';
  static const String sellerRole = 'seller';
  
  // Permission Keys
  static const String salesPermission = 'sales';
  static const String purchasesPermission = 'purchases';
  static const String invoicesPermission = 'invoices';
  static const String productsPermission = 'products';
  static const String usersPermission = 'users';
  
  // Permission Actions
  static const String viewAction = 'view';
  static const String createAction = 'create';
  static const String editAction = 'edit';
  static const String deleteAction = 'delete';
  
  // Storage Keys
  static const String userKey = 'user';
  static const String tokenKey = 'token';
  static const String themeKey = 'theme';
  
  // Route Names
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String dashboardRoute = '/dashboard';
  static const String productsRoute = '/products';
  static const String salesRoute = '/sales';
  static const String purchasesRoute = '/purchases';
  static const String invoicesRoute = '/invoices';
  static const String usersRoute = '/users';
  static const String profileRoute = '/profile';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Decimal places for currency
  static const int currencyDecimals = 2;
}
