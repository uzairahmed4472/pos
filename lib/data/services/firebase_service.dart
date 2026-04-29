import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Authentication
  FirebaseAuth get auth => FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('❌ Firebase Auth signIn error: $e');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase Auth user created: ${result.user?.uid}');
      return result;
    } catch (e) {
      print('❌ Firebase Auth signUp error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // Firestore
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  CollectionReference get usersCollection => firestore.collection('users');

  CollectionReference get productsCollection =>
      firestore.collection('products');

  CollectionReference get salesCollection => firestore.collection('sales');

  CollectionReference get purchasesCollection =>
      firestore.collection('purchases');

  CollectionReference get invoicesCollection =>
      firestore.collection('invoices');

  // Generic CRUD operations
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await firestore.collection(collection).add(data);
  }

  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    await firestore.collection(collection).doc(documentId).delete();
  }

  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    return await firestore.collection(collection).doc(documentId).get();
  }

  Future<QuerySnapshot> getDocuments(
    String collection, {
    Query? query,
    int? limit,
    DocumentSnapshot? startAfter,
    String? orderBy,
    bool descending = false,
  }) async {
    Query q = firestore.collection(collection);

    if (query != null) {
      q = query;
    }

    if (orderBy != null) {
      q = q.orderBy(orderBy, descending: descending);
    }

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    if (limit != null) {
      q = q.limit(limit);
    }

    return await q.get();
  }

  // Real-time listeners
  Stream<QuerySnapshot> streamDocuments(
    String collection, {
    Query? query,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query q = firestore.collection(collection);

    if (query != null) {
      q = query;
    }

    if (orderBy != null) {
      q = q.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      q = q.limit(limit);
    }

    return q.snapshots();
  }

  Stream<DocumentSnapshot> streamDocument(
    String collection,
    String documentId,
  ) {
    return firestore.collection(collection).doc(documentId).snapshots();
  }

  // Batch operations
  WriteBatch get batch => firestore.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }

  // Transactions
  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler) async {
    return await firestore.runTransaction(transactionHandler);
  }
}
