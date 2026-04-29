import 'package:get/get.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/firebase_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController()
    : _authRepository = AuthRepositoryImpl(FirebaseService.instance);

  final _currentUser = Rxn<User>();
  final _isLoading = false.obs;
  final _errorMessage = Rxn<String>();

  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  bool get isAuthenticated => _currentUser.value != null;
  bool get isAdmin => _currentUser.value?.isAdmin ?? false;
  bool get isSeller => _currentUser.value?.isSeller ?? false;

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
    _listenToAuthChanges();
  }

  Future<void> _checkCurrentUser() async {
    try {
      _isLoading.value = true;
      final user = await _authRepository.getCurrentUser();
      _currentUser.value = user;
    } catch (e) {
      _errorMessage.value = 'Failed to get current user: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges().listen((user) {
      _currentUser.value = user;
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final user = await _authRepository.signIn(email, password);
      _currentUser.value = user;
      return true;
    } catch (e) {
      _errorMessage.value = 'Sign in failed: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      if (role == AppConstants.adminRole) {
        _errorMessage.value = 'Admin registration is not allowed';
        return false;
      }

      try {
        await _authRepository.signUp(email, password, name, role);
        print('✅ AuthRepository.signUp completed successfully');
      } catch (e) {
        print('❌ AuthRepository.signUp failed: $e');
        _errorMessage.value = 'Failed to create account: $e';
        _isLoading.value = false;
        return false;
      }

      // Sign out immediately after signup - sellers need admin approval
      await _authRepository.signOut();
      print('✅ SignOut completed');

      // Delay to ensure auth state updates
      await Future.delayed(const Duration(milliseconds: 1000));

      Get.snackbar(
        'Success',
        'Account created successfully. Please wait for admin to grant permissions.',
        duration: const Duration(seconds: 3),
      );
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to create account: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authRepository.signOut();
      _currentUser.value = null;
    } catch (e) {
      _errorMessage.value = 'Sign out failed: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _authRepository.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage.value = 'Password reset failed: $e';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _errorMessage.value = null;
  }

  bool hasPermission(String module, String action) {
    return _currentUser.value?.hasPermission(module, action) ?? false;
  }
}
