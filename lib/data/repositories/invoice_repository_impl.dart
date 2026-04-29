import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../services/firebase_service.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  final FirebaseService _firebaseService;
  
  InvoiceRepositoryImpl(this._firebaseService);
  
  @override
  Future<List<Invoice>> getInvoices() async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'invoices',
        orderBy: 'createdAt',
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }
  
  @override
  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('invoices', id);
      if (docSnapshot.exists) {
        return Invoice.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }
  
  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    try {
      final docRef = await _firebaseService.addDocument('invoices', invoice.toMap());
      final createdInvoice = invoice.copyWith(id: docRef.id);
      
      await _firebaseService.updateDocument('invoices', docRef.id, createdInvoice.toMap());
      return createdInvoice;
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }
  
  @override
  Future<Invoice> updateInvoice(Invoice invoice) async {
    try {
      await _firebaseService.updateDocument('invoices', invoice.id, invoice.toMap());
      return invoice;
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }
  
  @override
  Future<void> deleteInvoice(String id) async {
    try {
      await _firebaseService.deleteDocument('invoices', id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }
  
  @override
  Future<List<Invoice>> getInvoicesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'invoices',
        query: _firebaseService.invoicesCollection
            .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
            .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String()),
        orderBy: 'createdAt',
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invoices by date range: $e');
    }
  }
  
  @override
  Future<List<Invoice>> getInvoicesByCustomer(String customerId) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'invoices',
        query: _firebaseService.invoicesCollection
            .where('customer.id', isEqualTo: customerId),
        orderBy: 'createdAt',
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invoices by customer: $e');
    }
  }
  
  @override
  Future<List<Invoice>> getInvoicesBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'invoices',
        query: _firebaseService.invoicesCollection.where('sellerId', isEqualTo: sellerId),
        orderBy: 'createdAt',
        descending: true,
      );
      
      return querySnapshot.docs
          .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get invoices by seller: $e');
    }
  }
  
  @override
  Future<String> generateInvoiceNumber() async {
    try {
      final now = DateTime.now();
      final year = now.year.toString().substring(2);
      final month = now.month.toString().padLeft(2, '0');
      
      // Get the count of invoices this month
      final querySnapshot = await _firebaseService.getDocuments(
        'invoices',
        query: _firebaseService.invoicesCollection
            .where('invoiceNumber', isGreaterThanOrEqualTo: 'INV-$year$month-0001')
            .where('invoiceNumber', isLessThanOrEqualTo: 'INV-$year$month-9999'),
      );
      
      final count = querySnapshot.docs.length + 1;
      final sequence = count.toString().padLeft(4, '0');
      
      return 'INV-$year$month-$sequence';
    } catch (e) {
      // Fallback to timestamp-based number
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(-6);
      return 'INV-$timestamp';
    }
  }
  
  @override
  Stream<List<Invoice>> streamInvoices() {
    return _firebaseService
        .streamDocuments('invoices', orderBy: 'createdAt', descending: true)
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Invoice.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
  
  @override
  Stream<Invoice?> streamInvoice(String id) {
    return _firebaseService
        .streamDocument('invoices', id)
        .map((docSnapshot) => docSnapshot.exists
            ? Invoice.fromMap(docSnapshot.data() as Map<String, dynamic>)
            : null);
  }
}
