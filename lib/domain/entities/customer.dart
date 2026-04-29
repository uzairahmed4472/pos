class Customer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });
  
  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      address: map['address'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
    );
  }
  
  String get displayName => name.isNotEmpty ? name : phone;
}
