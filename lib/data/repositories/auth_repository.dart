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
        final user = User.fromMap(userDoc.data() as Map<String, dynamic>);
        if (user.role != 'admin' && !user.isActive) {
          await _firebaseService.signOut();
          throw Exception('Account is pending admin approval');
        }
        return user;
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
            'users': const PermissionSet(
              view: false,
              create: false,
              edit: false,
              delete: false,
            ),
          },
        ),
        createdAt: DateTime.now(),
        isActive: false,
      );

      try {
        await _firebaseService.setDocument('users', user.id, user.toMap());
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
  Future<List<User>> getSellers() async {
    try {
      final query = _firebaseService.usersCollection.where(
        'role',
        isEqualTo: 'seller',
      );
      final snapshots = await _firebaseService.getDocuments(
        'users',
        query: query,
      );
      return snapshots.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sellers: $e');
    }
  }

  @override
  Future<void> updateSellerApproval({
    required String sellerId,
    required bool isActive,
    UserPermissions? permissions,
  }) async {
    try {
      final payload = <String, dynamic>{'isActive': isActive};
      if (permissions != null) {
        payload['permissions'] = permissions.toMap();
      }
      await _firebaseService.updateDocument('users', sellerId, payload);
    } catch (e) {
      throw Exception('Failed to update seller approval: $e');
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
