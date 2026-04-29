import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

class GetSalesUseCase {
  final SalesRepository _repository;
  
  GetSalesUseCase(this._repository);
  
  Future<List<Sale>> call() async {
    return await _repository.getSales();
  }
}

class GetSaleByIdUseCase {
  final SalesRepository _repository;
  
  GetSaleByIdUseCase(this._repository);
  
  Future<Sale?> call(String id) async {
    return await _repository.getSaleById(id);
  }
}

class CreateSaleUseCase {
  final SalesRepository _repository;
  
  CreateSaleUseCase(this._repository);
  
  Future<Sale> call(Sale sale) async {
    return await _repository.createSale(sale);
  }
}

class UpdateSaleUseCase {
  final SalesRepository _repository;
  
  UpdateSaleUseCase(this._repository);
  
  Future<Sale> call(Sale sale) async {
    return await _repository.updateSale(sale);
  }
}

class DeleteSaleUseCase {
  final SalesRepository _repository;
  
  DeleteSaleUseCase(this._repository);
  
  Future<void> call(String id) async {
    return await _repository.deleteSale(id);
  }
}

class GetSalesByDateRangeUseCase {
  final SalesRepository _repository;
  
  GetSalesByDateRangeUseCase(this._repository);
  
  Future<List<Sale>> call(DateTime startDate, DateTime endDate) async {
    return await _repository.getSalesByDateRange(startDate, endDate);
  }
}

class GetSalesBySellerUseCase {
  final SalesRepository _repository;
  
  GetSalesBySellerUseCase(this._repository);
  
  Future<List<Sale>> call(String sellerId) async {
    return await _repository.getSalesBySeller(sellerId);
  }
}
