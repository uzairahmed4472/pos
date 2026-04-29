class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? sku;
  final String? category;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.stock,
    this.sku,
    this.category,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });
  
  bool get isLowStock => stock <= 5;
  bool get isOutOfStock => stock == 0;
  
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? sku,
    String? category,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'sku': sku,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      sku: map['sku'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }
}
