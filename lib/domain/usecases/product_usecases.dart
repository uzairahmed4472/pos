import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repository;
  
  GetProductsUseCase(this._repository);
  
  Future<List<Product>> call() async {
    return await _repository.getProducts();
  }
}

class GetProductByIdUseCase {
  final ProductRepository _repository;
  
  GetProductByIdUseCase(this._repository);
  
  Future<Product?> call(String id) async {
    return await _repository.getProductById(id);
  }
}

class SearchProductsUseCase {
  final ProductRepository _repository;
  
  SearchProductsUseCase(this._repository);
  
  Future<List<Product>> call(String query) async {
    return await _repository.searchProducts(query);
  }
}

class AddProductUseCase {
  final ProductRepository _repository;
  
  AddProductUseCase(this._repository);
  
  Future<Product> call(Product product) async {
    return await _repository.addProduct(product);
  }
}

class UpdateProductUseCase {
  final ProductRepository _repository;
  
  UpdateProductUseCase(this._repository);
  
  Future<Product> call(Product product) async {
    return await _repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductRepository _repository;
  
  DeleteProductUseCase(this._repository);
  
  Future<void> call(String id) async {
    return await _repository.deleteProduct(id);
  }
}

class UpdateStockUseCase {
  final ProductRepository _repository;
  
  UpdateStockUseCase(this._repository);
  
  Future<void> call(String productId, int quantity) async {
    return await _repository.updateStock(productId, quantity);
  }
}
