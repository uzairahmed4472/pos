import '../entities/sale.dart';

abstract class SalesRepository {
  Future<List<Sale>> getSales();
  Future<Sale?> getSaleById(String id);
  Future<Sale> createSale(Sale sale);
  Future<Sale> updateSale(Sale sale);
  Future<void> deleteSale(String id);
  Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Sale>> getSalesBySeller(String sellerId);
  Stream<List<Sale>> streamSales();
  Stream<Sale?> streamSale(String id);
}
