import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product_usecases.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/services/firebase_service.dart';
import '../../core/constants/app_constants.dart';

class ProductController extends GetxController {
  final ProductRepository _repository;
  final GetProductsUseCase _getProductsUseCase;
  final AddProductUseCase _addProductUseCase;
  final UpdateProductUseCase _updateProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final SearchProductsUseCase _searchProductsUseCase;
  final UpdateStockUseCase _updateStockUseCase;

  ProductController()
    : _repository = ProductRepositoryImpl(FirebaseService.instance),
      _getProductsUseCase = GetProductsUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      ),
      _addProductUseCase = AddProductUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      ),
      _updateProductUseCase = UpdateProductUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      ),
      _deleteProductUseCase = DeleteProductUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      ),
      _searchProductsUseCase = SearchProductsUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      ),
      _updateStockUseCase = UpdateStockUseCase(
        ProductRepositoryImpl(FirebaseService.instance),
      );

  final _products = <Product>[].obs;
  final _filteredProducts = <Product>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = Rxn<String>();
  final _searchQuery = ''.obs;

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    _searchQuery.listen((_) => _filterProducts());
  }

  Future<void> _loadProducts() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final products = await _getProductsUseCase();
      _products.value = products;
      _filteredProducts.value = products;
    } catch (e) {
      _errorMessage.value = 'Failed to load products: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterProducts() {
    if (_searchQuery.value.isEmpty) {
      _filteredProducts.value = _products;
    } else {
      _filteredProducts.value = _products.where((product) {
        return product.name.toLowerCase().contains(
              _searchQuery.value.toLowerCase(),
            ) ||
            (product.description?.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ??
                false) ||
            (product.category?.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ??
                false);
      }).toList();
    }
  }

  Future<bool> addProduct({
    required String name,
    String description = '',
    required double price,
    required int stock,
    String? sku,
    String? category,
    String? imageUrl,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final product = Product(
        id: const Uuid().v4(),
        name: name,
        description: description,
        price: price,
        stock: stock,
        sku: sku ?? _generateSKU(name),
        category: category,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final addedProduct = await _addProductUseCase(product);
      _products.add(addedProduct);
      _filterProducts();

      Get.snackbar('Success', 'Product added successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to add product: $e';
      Get.snackbar('Error', 'Failed to add product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      await _updateProductUseCase(updatedProduct);

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _filterProducts();
      }

      Get.snackbar('Success', 'Product updated successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to update product: $e';
      Get.snackbar('Error', 'Failed to update product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _deleteProductUseCase(productId);
      _products.removeWhere((p) => p.id == productId);
      _filterProducts();

      Get.snackbar('Success', 'Product deleted successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to delete product: $e';
      Get.snackbar('Error', 'Failed to delete product');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateStock(String productId, int quantity) async {
    try {
      await _updateStockUseCase(productId, quantity);
      await _loadProducts(); // Refresh the list
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to update stock: $e';
      return false;
    }
  }

  void searchProducts(String query) {
    _searchQuery.value = query;
  }

  void clearError() {
    _errorMessage.value = null;
  }

  void refresh() {
    _loadProducts();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> getLowStockProducts() {
    return _products.where((product) => product.isLowStock).toList();
  }

  List<Product> getOutOfStockProducts() {
    return _products.where((product) => product.isOutOfStock).toList();
  }

  double getTotalInventoryValue() {
    return _products.fold(
      0.0,
      (sum, product) => sum + (product.price * product.stock),
    );
  }

  int getTotalStockCount() {
    return _products.fold(0, (sum, product) => sum + product.stock);
  }

  String _generateSKU(String name) {
    final words = name.toUpperCase().split(' ');
    final sku = words.take(3).map((word) => word.substring(0, 2)).join('');
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(
      -4,
    );
    return '$sku$random';
  }
}
