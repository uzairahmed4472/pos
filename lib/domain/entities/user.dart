import '../../core/constants/app_constants.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final UserPermissions permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });
  
  bool get isAdmin => role == AppConstants.adminRole;
  bool get isSeller => role == AppConstants.sellerRole;
  
  bool hasPermission(String module, String action) {
    if (isAdmin) return true;
    return permissions.hasPermission(module, action);
  }
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    UserPermissions? permissions,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'permissions': permissions.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      permissions: UserPermissions.fromMap(map['permissions'] ?? {}),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
      isActive: map['isActive'] ?? true,
    );
  }
}

class UserPermissions {
  final Map<String, PermissionSet> permissions;
  
  const UserPermissions({required this.permissions});
  
  factory UserPermissions.defaultSeller() {
    return UserPermissions(
      permissions: {
        AppConstants.salesPermission: const PermissionSet(
          view: true,
          create: true,
          edit: false,
          delete: false,
        ),
        AppConstants.invoicesPermission: const PermissionSet(
          view: true,
          create: true,
          edit: false,
          delete: false,
        ),
        AppConstants.productsPermission: const PermissionSet(
          view: true,
          create: false,
          edit: false,
          delete: false,
        ),
        AppConstants.purchasesPermission: const PermissionSet(
          view: false,
          create: false,
          edit: false,
          delete: false,
        ),
        AppConstants.usersPermission: const PermissionSet(
          view: false,
          create: false,
          edit: false,
          delete: false,
        ),
      },
    );
  }
  
  factory UserPermissions.admin() {
    return UserPermissions(
      permissions: {
        AppConstants.salesPermission: const PermissionSet(
          view: true,
          create: true,
          edit: true,
          delete: true,
        ),
        AppConstants.invoicesPermission: const PermissionSet(
          view: true,
          create: true,
          edit: true,
          delete: true,
        ),
        AppConstants.productsPermission: const PermissionSet(
          view: true,
          create: true,
          edit: true,
          delete: true,
        ),
        AppConstants.purchasesPermission: const PermissionSet(
          view: true,
          create: true,
          edit: true,
          delete: true,
        ),
        AppConstants.usersPermission: const PermissionSet(
          view: true,
          create: true,
          edit: true,
          delete: true,
        ),
      },
    );
  }
  
  bool hasPermission(String module, String action) {
    final permissionSet = permissions[module];
    if (permissionSet == null) return false;
    
    switch (action) {
      case AppConstants.viewAction:
        return permissionSet.view;
      case AppConstants.createAction:
        return permissionSet.create;
      case AppConstants.editAction:
        return permissionSet.edit;
      case AppConstants.deleteAction:
        return permissionSet.delete;
      default:
        return false;
    }
  }
  
  UserPermissions copyWith({Map<String, PermissionSet>? permissions}) {
    return UserPermissions(
      permissions: permissions ?? this.permissions,
    );
  }
  
  Map<String, dynamic> toMap() {
    return permissions.map((key, value) => MapEntry(key, value.toMap()));
  }
  
  factory UserPermissions.fromMap(Map<String, dynamic> map) {
    final permissions = <String, PermissionSet>{};
    map.forEach((key, value) {
      permissions[key] = PermissionSet.fromMap(value);
    });
    return UserPermissions(permissions: permissions);
  }
}

class PermissionSet {
  final bool view;
  final bool create;
  final bool edit;
  final bool delete;
  
  const PermissionSet({
    required this.view,
    required this.create,
    required this.edit,
    required this.delete,
  });
  
  PermissionSet copyWith({
    bool? view,
    bool? create,
    bool? edit,
    bool? delete,
  }) {
    return PermissionSet(
      view: view ?? this.view,
      create: create ?? this.create,
      edit: edit ?? this.edit,
      delete: delete ?? this.delete,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'view': view,
      'create': create,
      'edit': edit,
      'delete': delete,
    };
  }
  
  factory PermissionSet.fromMap(Map<String, dynamic> map) {
    return PermissionSet(
      view: map['view'] ?? false,
      create: map['create'] ?? false,
      edit: map['edit'] ?? false,
      delete: map['delete'] ?? false,
    );
  }
}
