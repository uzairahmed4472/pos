import 'package:get/get.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/usecases/invoice_usecases.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../data/services/firebase_service.dart';

class InvoiceController extends GetxController {
  final InvoiceRepository _repository;
  final GetInvoicesUseCase _getInvoicesUseCase;
  final CreateInvoiceUseCase _createInvoiceUseCase;
  final CreateInvoiceFromSaleUseCase _createInvoiceFromSaleUseCase;
  final UpdateInvoiceUseCase _updateInvoiceUseCase;
  final DeleteInvoiceUseCase _deleteInvoiceUseCase;
  final GetInvoicesByDateRangeUseCase _getInvoicesByDateRangeUseCase;
  final GetInvoicesByCustomerUseCase _getInvoicesByCustomerUseCase;
  final GetInvoicesBySellerUseCase _getInvoicesBySellerUseCase;
  final GenerateInvoiceNumberUseCase _generateInvoiceNumberUseCase;

  InvoiceController()
    : _repository = InvoiceRepositoryImpl(FirebaseService.instance),
      _getInvoicesUseCase = GetInvoicesUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _createInvoiceUseCase = CreateInvoiceUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _createInvoiceFromSaleUseCase = CreateInvoiceFromSaleUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _updateInvoiceUseCase = UpdateInvoiceUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _deleteInvoiceUseCase = DeleteInvoiceUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _getInvoicesByDateRangeUseCase = GetInvoicesByDateRangeUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _getInvoicesByCustomerUseCase = GetInvoicesByCustomerUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _getInvoicesBySellerUseCase = GetInvoicesBySellerUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      ),
      _generateInvoiceNumberUseCase = GenerateInvoiceNumberUseCase(
        InvoiceRepositoryImpl(FirebaseService.instance),
      );

  final _invoices = <Invoice>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = Rxn<String>();

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final invoices = await _getInvoicesUseCase();
      _invoices.value = invoices;
    } catch (e) {
      _errorMessage.value = 'Failed to load invoices: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Invoice?> createInvoiceFromSale(Sale sale) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final invoice = await _createInvoiceFromSaleUseCase(sale);
      _invoices.insert(0, invoice);

      Get.snackbar('Success', 'Invoice created successfully');
      return invoice;
    } catch (e) {
      _errorMessage.value = 'Failed to create invoice: $e';
      Get.snackbar('Error', 'Failed to create invoice');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateInvoice(Invoice invoice) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final updatedInvoice = invoice.copyWith(updatedAt: DateTime.now());
      await _updateInvoiceUseCase(updatedInvoice);

      final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
      }

      Get.snackbar('Success', 'Invoice updated successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to update invoice: $e';
      Get.snackbar('Error', 'Failed to update invoice');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteInvoice(String invoiceId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _deleteInvoiceUseCase(invoiceId);
      _invoices.removeWhere((invoice) => invoice.id == invoiceId);

      Get.snackbar('Success', 'Invoice deleted successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to delete invoice: $e';
      Get.snackbar('Error', 'Failed to delete invoice');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final invoices = await _getInvoicesByDateRangeUseCase(startDate, endDate);
      _invoices.value = invoices;
    } catch (e) {
      _errorMessage.value = 'Failed to load invoices: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadInvoicesByCustomer(String customerId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final invoices = await _getInvoicesByCustomerUseCase(customerId);
      _invoices.value = invoices;
    } catch (e) {
      _errorMessage.value = 'Failed to load invoices: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadInvoicesBySeller(String sellerId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final invoices = await _getInvoicesBySellerUseCase(sellerId);
      _invoices.value = invoices;
    } catch (e) {
      _errorMessage.value = 'Failed to load invoices: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String> generateInvoiceNumber() async {
    try {
      return await _generateInvoiceNumberUseCase();
    } catch (e) {
      _errorMessage.value = 'Failed to generate invoice number: $e';
      return 'INV-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  void clearError() {
    _errorMessage.value = null;
  }

  void refresh() {
    _loadInvoices();
  }

  Invoice? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalInvoicesAmount() {
    return _invoices.fold(0.0, (sum, invoice) => sum + invoice.totalAmount);
  }

  int getTotalInvoicesCount() {
    return _invoices.length;
  }

  List<Invoice> getTodayInvoices() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _invoices.where((invoice) {
      return invoice.createdAt.isAfter(todayStart) &&
          invoice.createdAt.isBefore(todayEnd);
    }).toList();
  }

  double getTodayInvoicesTotal() {
    return getTodayInvoices().fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }

  List<Invoice> getOverdueInvoices() {
    final now = DateTime.now();
    return _invoices.where((invoice) {
      return invoice.status != InvoiceStatus.paid &&
          invoice.dueDate.isBefore(now);
    }).toList();
  }

  double getOverdueInvoicesTotal() {
    return getOverdueInvoices().fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }

  List<Invoice> getUnpaidInvoices() {
    return _invoices.where((invoice) {
      return invoice.status != InvoiceStatus.paid &&
          invoice.status != InvoiceStatus.cancelled;
    }).toList();
  }

  double getUnpaidInvoicesTotal() {
    return getUnpaidInvoices().fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }
}
