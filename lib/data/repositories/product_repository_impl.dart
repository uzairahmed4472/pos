import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../services/firebase_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseService _firebaseService;
  
  ProductRepositoryImpl(this._firebaseService);
  
  @override
  Future<List<Product>> getProducts() async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        orderBy: 'createdAt',
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }
  
  @override
  Future<Product?> getProductById(String id) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('products', id);
      if (docSnapshot.exists) {
        return Product.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }
  
  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        query: _firebaseService.productsCollection
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff'),
      );
      
      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
  
  @override
  Future<Product> addProduct(Product product) async {
    try {
      final docRef = await _firebaseService.addDocument('products', product.toMap());
      final updatedProduct = product.copyWith(id: docRef.id);
      
      await _firebaseService.updateDocument('products', docRef.id, updatedProduct.toMap());
      return updatedProduct;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }
  
  @override
  Future<Product> updateProduct(Product product) async {
    try {
      await _firebaseService.updateDocument('products', product.id, product.toMap());
      return product;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
  
  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _firebaseService.deleteDocument('products', id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
  
  @override
  Future<void> updateStock(String productId, int quantity) async {
    try {
      final product = await getProductById(productId);
      if (product != null) {
        final updatedProduct = product.copyWith(
          stock: product.stock + quantity,
          updatedAt: DateTime.now(),
        );
        await updateProduct(updatedProduct);
      }
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }
  
  @override
  Stream<List<Product>> streamProducts() {
    return _firebaseService
        .streamDocuments('products', orderBy: 'createdAt', descending: true)
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  @override
  Stream<Product?> streamProduct(String id) {
    return _firebaseService
        .streamDocument('products', id)
        .map((docSnapshot) => docSnapshot.exists
            ? Product.fromMap(docSnapshot.data() as Map<String, dynamic>)
            : null);
  }
}
