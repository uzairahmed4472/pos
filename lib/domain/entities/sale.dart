import 'customer.dart';

class Sale {
  final String id;
  final String sellerId;
  final String sellerName;
  final Customer? customer;
  final List<SaleItem> items;
  final double totalAmount;
  final double discount;
  final double tax;
  final double finalAmount;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SaleStatus status;
  
  const Sale({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.customer,
    required this.items,
    required this.totalAmount,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.finalAmount,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.status = SaleStatus.completed,
  });
  
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  Sale copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    Customer? customer,
    List<SaleItem>? items,
    double? totalAmount,
    double? discount,
    double? tax,
    double? finalAmount,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    SaleStatus? status,
  }) {
    return Sale(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'customer': customer?.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'tax': tax,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
    };
  }
  
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      customer: map['customer'] != null ? Customer.fromMap(map['customer']) : null,
      items: (map['items'] as List<dynamic>?)
          ?.map((item) => SaleItem.fromMap(item))
          .toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      status: SaleStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => SaleStatus.completed,
      ),
    );
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  
  const SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });
  
  SaleItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
  
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

enum SaleStatus {
  pending,
  completed,
  cancelled,
  refunded,
}
