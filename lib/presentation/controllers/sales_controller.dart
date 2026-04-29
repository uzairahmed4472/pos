import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../domain/usecases/sales_usecases.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../data/services/firebase_service.dart';
import 'auth_controller.dart';
import 'invoice_controller.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class SalesController extends GetxController {
  final SalesRepository _repository;
  final GetSalesUseCase _getSalesUseCase;
  final CreateSaleUseCase _createSaleUseCase;
  final UpdateSaleUseCase _updateSaleUseCase;
  final DeleteSaleUseCase _deleteSaleUseCase;
  final GetSalesByDateRangeUseCase _getSalesByDateRangeUseCase;
  final GetSalesBySellerUseCase _getSalesBySellerUseCase;

  SalesController()
    : _repository = SalesRepositoryImpl(FirebaseService.instance),
      _getSalesUseCase = GetSalesUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      ),
      _createSaleUseCase = CreateSaleUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      ),
      _updateSaleUseCase = UpdateSaleUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      ),
      _deleteSaleUseCase = DeleteSaleUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      ),
      _getSalesByDateRangeUseCase = GetSalesByDateRangeUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      ),
      _getSalesBySellerUseCase = GetSalesBySellerUseCase(
        SalesRepositoryImpl(FirebaseService.instance),
      );

  final _sales = <Sale>[].obs;
  final _cartItems = <CartItem>[].obs;
  final _selectedCustomer = Rxn<Customer>();
  final _isLoading = false.obs;
  final _errorMessage = Rxn<String>();
  final _discount = 0.0.obs;
  final _tax = 0.0.obs;
  final _paymentMethod = 'Cash'.obs;
  final _notes = ''.obs;

  List<Sale> get sales => _sales;
  List<CartItem> get cartItems => _cartItems;
  Customer? get selectedCustomer => _selectedCustomer.value;
  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  double get discount => _discount.value;
  double get tax => _tax.value;
  String get paymentMethod => _paymentMethod.value;
  String get notes => _notes.value;

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalAmount => subtotal - discount + tax;
  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  void onInit() {
    super.onInit();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final sales = await _getSalesUseCase();
      _sales.value = sales;
    } catch (e) {
      _errorMessage.value = 'Failed to load sales: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final updatedItem = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + 1,
      );
      _cartItems[existingIndex] = updatedItem;
    } else {
      _cartItems.add(CartItem(product: product));
    }

    Get.snackbar('Added to Cart', '${product.name} added to cart');
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else if (quantity <= _cartItems[index].product.stock) {
        final updatedItem = _cartItems[index].copyWith(quantity: quantity);
        _cartItems[index] = updatedItem;
      } else {
        Get.snackbar(
          'Insufficient Stock',
          'Only ${_cartItems[index].product.stock} items available',
        );
      }
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    _cartItems.clear();
    _selectedCustomer.value = null;
    _discount.value = 0.0;
    _tax.value = 0.0;
    _paymentMethod.value = 'Cash';
    _notes.value = '';
  }

  void setCustomer(Customer? customer) {
    _selectedCustomer.value = customer;
  }

  void setDiscount(double value) {
    _discount.value = value;
  }

  void setTax(double value) {
    _tax.value = value;
  }

  void setPaymentMethod(String method) {
    _paymentMethod.value = method;
  }

  void setNotes(String notes) {
    _notes.value = notes;
  }

  Future<bool> createSale() async {
    if (_cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return false;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final saleItems = _cartItems
          .map(
            (cartItem) => SaleItem(
              productId: cartItem.product.id,
              productName: cartItem.product.name,
              unitPrice: cartItem.product.price,
              quantity: cartItem.quantity,
              totalPrice: cartItem.totalPrice,
            ),
          )
          .toList();

      final sale = Sale(
        id: const Uuid().v4(),
        sellerId: currentUser.id,
        sellerName: currentUser.name,
        customer: _selectedCustomer.value,
        items: saleItems,
        totalAmount: subtotal,
        discount: discount,
        tax: tax,
        finalAmount: totalAmount,
        paymentMethod: paymentMethod,
        notes: notes.isNotEmpty ? notes : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdSale = await _createSaleUseCase(sale);
      _sales.insert(0, createdSale);
      clearCart();

      Get.snackbar('Success', 'Sale completed successfully');

      // Create invoice from sale
      final invoiceController = Get.find<InvoiceController>();
      await invoiceController.createInvoiceFromSale(createdSale);

      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to create sale: $e';
      Get.snackbar('Error', 'Failed to create sale');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateSale(Sale sale) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final updatedSale = sale.copyWith(updatedAt: DateTime.now());
      await _updateSaleUseCase(updatedSale);

      final index = _sales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _sales[index] = updatedSale;
      }

      Get.snackbar('Success', 'Sale updated successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to update sale: $e';
      Get.snackbar('Error', 'Failed to update sale');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteSale(String saleId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      await _deleteSaleUseCase(saleId);
      _sales.removeWhere((sale) => sale.id == saleId);

      Get.snackbar('Success', 'Sale deleted successfully');
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to delete sale: $e';
      Get.snackbar('Error', 'Failed to delete sale');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final sales = await _getSalesByDateRangeUseCase(startDate, endDate);
      _sales.value = sales;
    } catch (e) {
      _errorMessage.value = 'Failed to load sales: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadSalesBySeller(String sellerId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = null;

      final sales = await _getSalesBySellerUseCase(sellerId);
      _sales.value = sales;
    } catch (e) {
      _errorMessage.value = 'Failed to load sales: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void clearError() {
    _errorMessage.value = null;
  }

  void refresh() {
    _loadSales();
  }

  double getTotalSales() {
    return _sales.fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }

  int getTotalSalesCount() {
    return _sales.length;
  }

  List<Sale> getTodaySales() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _sales.where((sale) {
      return sale.createdAt.isAfter(todayStart) &&
          sale.createdAt.isBefore(todayEnd);
    }).toList();
  }

  double getTodaySalesTotal() {
    return getTodaySales().fold(0.0, (sum, sale) => sum + sale.finalAmount);
  }
}
