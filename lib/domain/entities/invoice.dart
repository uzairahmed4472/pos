import 'sale.dart';
import 'customer.dart';

class Invoice {
  final String id;
  final String saleId;
  final String invoiceNumber;
  final String sellerId;
  final String sellerName;
  final Customer? customer;
  final List<InvoiceItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final String? paymentMethod;
  final String? notes;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Invoice({
    required this.id,
    required this.saleId,
    required this.invoiceNumber,
    required this.sellerId,
    required this.sellerName,
    this.customer,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.paymentMethod,
    this.notes,
    required this.invoiceDate,
    required this.dueDate,
    this.status = InvoiceStatus.draft,
    required this.createdAt,
    required this.updatedAt,
  });

  Invoice copyWith({
    String? id,
    String? saleId,
    String? invoiceNumber,
    String? sellerId,
    String? sellerName,
    Customer? customer,
    List<InvoiceItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    String? paymentMethod,
    String? notes,
    DateTime? invoiceDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'invoiceNumber': invoiceNumber,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'customer': customer?.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      saleId: map['saleId'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      customer: map['customer'] != null
          ? Customer.fromMap(map['customer'])
          : null,
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromMap(item))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      paymentMethod: map['paymentMethod'],
      notes: map['notes'],
      invoiceDate: DateTime.parse(
        map['invoiceDate'] ?? DateTime.now().toIso8601String(),
      ),
      dueDate: DateTime.parse(
        map['dueDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: InvoiceStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory Invoice.fromSale(Sale sale, String invoiceNumber) {
    return Invoice(
      id: sale.id,
      saleId: sale.id,
      invoiceNumber: invoiceNumber,
      sellerId: sale.sellerId,
      sellerName: sale.sellerName,
      customer: sale.customer,
      items: sale.items.map((item) => InvoiceItem.fromSaleItem(item)).toList(),
      subtotal: sale.totalAmount,
      discount: sale.discount,
      tax: sale.tax,
      totalAmount: sale.finalAmount,
      paymentMethod: sale.paymentMethod,
      notes: sale.notes,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 30)),
      status: InvoiceStatus.sent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class InvoiceItem {
  final String productId;
  final String productName;
  final String? description;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const InvoiceItem({
    required this.productId,
    required this.productName,
    this.description,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  InvoiceItem copyWith({
    String? productId,
    String? productName,
    String? description,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
  }) {
    return InvoiceItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  factory InvoiceItem.fromSaleItem(SaleItem saleItem) {
    return InvoiceItem(
      productId: saleItem.productId,
      productName: saleItem.productName,
      unitPrice: saleItem.unitPrice,
      quantity: saleItem.quantity,
      totalPrice: saleItem.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'description': description,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      description: map['description'],
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
    );
  }
}

enum InvoiceStatus { draft, sent, paid, overdue, cancelled }
