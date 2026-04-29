import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<List<Product>> searchProducts(String query);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> updateStock(String productId, int quantity);
  Stream<List<Product>> streamProducts();
  Stream<Product?> streamProduct(String id);
}
