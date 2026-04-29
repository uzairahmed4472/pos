import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<List<Invoice>> getInvoices();
  Future<Invoice?> getInvoiceById(String id);
  Future<Invoice> createInvoice(Invoice invoice);
  Future<Invoice> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(String id);
  Future<List<Invoice>> getInvoicesByDateRange(DateTime startDate, DateTime endDate);
  Future<List<Invoice>> getInvoicesByCustomer(String customerId);
  Future<List<Invoice>> getInvoicesBySeller(String sellerId);
  Future<String> generateInvoiceNumber();
  Stream<List<Invoice>> streamInvoices();
  Stream<Invoice?> streamInvoice(String id);
}
