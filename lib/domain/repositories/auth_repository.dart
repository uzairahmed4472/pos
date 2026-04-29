import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password, String name, String role);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<User?> getCurrentUser();
  Future<List<User>> getSellers();
  Future<void> updateSellerApproval({
    required String sellerId,
    required bool isActive,
    UserPermissions? permissions,
  });
  Stream<User?> authStateChanges();
}
