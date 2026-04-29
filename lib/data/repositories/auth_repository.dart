import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepositoryImpl(this._firebaseService);

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmail(
        email,
        password,
      );
      final userDoc = await _firebaseService.getDocument(
        'users',
        userCredential.user!.uid,
      );

      if (userDoc.exists) {
        return User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<User?> signUp(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final userCredential = await _firebaseService.signUpWithEmail(
        email,
        password,
      );
      // Create seller with NO permissions - admin must grant access
      final user = User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        permissions: UserPermissions(
          permissions: {
            'products': const PermissionSet(
              view: false,
              create: false,
              edit: false,
              delete: false,
            ),
            'sales': const PermissionSet(
              view: false,
              create: false,
              edit: false,
              delete: false,
            ),
            'purchases': const PermissionSet(
              view: false,
              create: false,
              edit: false,
              delete: false,
            ),
            'invoices': const PermissionSet(
              view: false,
              create: false,
              edit: false,
              delete: false,
            ),
          },
        ),
        createdAt: DateTime.now(),
      );

      try {
        await _firebaseService.addDocument('users', user.toMap());
        print('✅ User document created in Firestore');
      } catch (e) {
        print('❌ Error creating Firestore document: $e');
        throw Exception('Failed to create user document: $e');
      }
      return user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseService.currentUser;
      if (firebaseUser == null) return null;

      final userDoc = await _firebaseService.getDocument(
        'users',
        firebaseUser.uid,
      );
      if (userDoc.exists) {
        return User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseService.auth.authStateChanges().asyncMap((
      firebaseUser,
    ) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firebaseService.getDocument(
          'users',
          firebaseUser.uid,
        );
        if (userDoc.exists) {
          return User.fromMap(userDoc.data() as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }
}
