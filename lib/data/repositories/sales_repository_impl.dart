import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../services/firebase_service.dart';

class SalesRepositoryImpl implements SalesRepository {
  final FirebaseService _firebaseService;

  SalesRepositoryImpl(this._firebaseService);

  @override
  Future<List<Sale>> getSales() async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'sales',
        orderBy: 'createdAt',
        descending: true,
      );

      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales: $e');
    }
  }

  @override
  Future<Sale?> getSaleById(String id) async {
    try {
      final docSnapshot = await _firebaseService.getDocument('sales', id);
      if (docSnapshot.exists) {
        return Sale.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get sale: $e');
    }
  }

  @override
  Future<Sale> createSale(Sale sale) async {
    try {
      final docRef = await _firebaseService.addDocument('sales', sale.toMap());
      final createdSale = sale.copyWith(id: docRef.id);

      await _firebaseService.updateDocument(
        'sales',
        docRef.id,
        createdSale.toMap(),
      );

      // Update product stock
      await _updateProductStock(sale.items);

      return createdSale;
    } catch (e) {
      throw Exception('Failed to create sale: $e');
    }
  }

  @override
  Future<Sale> updateSale(Sale sale) async {
    try {
      await _firebaseService.updateDocument('sales', sale.id, sale.toMap());
      return sale;
    } catch (e) {
      throw Exception('Failed to update sale: $e');
    }
  }

  @override
  Future<void> deleteSale(String id) async {
    try {
      final sale = await getSaleById(id);
      if (sale != null) {
        // Restore product stock
        await _restoreProductStock(sale.items);
      }

      await _firebaseService.deleteDocument('sales', id);
    } catch (e) {
      throw Exception('Failed to delete sale: $e');
    }
  }

  @override
  Future<List<Sale>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'sales',
        query: _firebaseService.salesCollection
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: startDate.toIso8601String(),
            )
            .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String()),
        orderBy: 'createdAt',
        descending: true,
      );

      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales by date range: $e');
    }
  }

  @override
  Future<List<Sale>> getSalesBySeller(String sellerId) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'sales',
        query: _firebaseService.salesCollection.where(
          'sellerId',
          isEqualTo: sellerId,
        ),
        orderBy: 'createdAt',
        descending: true,
      );

      return querySnapshot.docs
          .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get sales by seller: $e');
    }
  }

  @override
  Stream<List<Sale>> streamSales() {
    return _firebaseService
        .streamDocuments('sales', orderBy: 'createdAt', descending: true)
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => Sale.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  @override
  Stream<Sale?> streamSale(String id) {
    return _firebaseService
        .streamDocument('sales', id)
        .map(
          (docSnapshot) => docSnapshot.exists
              ? Sale.fromMap(docSnapshot.data() as Map<String, dynamic>)
              : null,
        );
  }

  Future<void> _updateProductStock(List<SaleItem> items) async {
    final batch = _firebaseService.batch;

    for (final item in items) {
      final productRef = _firebaseService.productsCollection.doc(
        item.productId,
      );
      batch.update(productRef, {
        'stock': FieldValue.increment(-item.quantity),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }

  Future<void> _restoreProductStock(List<SaleItem> items) async {
    final batch = _firebaseService.batch;

    for (final item in items) {
      final productRef = _firebaseService.productsCollection.doc(
        item.productId,
      );
      batch.update(productRef, {
        'stock': FieldValue.increment(item.quantity),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }
}
