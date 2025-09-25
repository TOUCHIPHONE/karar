import 'package:equatable/equatable.dart';

import 'role_permissions.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.photoUrl,
    this.phone,
    this.department,
    this.workerCode,
    this.age,
    this.lastLogin,
  });

  final String id;
  final String displayName;
  final String email;
  final AppRole role;
  final RolePermissions permissions;
  final DateTime createdAt;
  final String? photoUrl;
  final String? phone;
  final String? department;
  final String? workerCode;
  final int? age;
  final DateTime? lastLogin;

  bool get isManager => role == AppRole.manager;

  AppUser copyWith({
    String? displayName,
    String? email,
    AppRole? role,
    RolePermissions? permissions,
    DateTime? createdAt,
    String? photoUrl,
    String? phone,
    String? department,
    String? workerCode,
    int? age,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      workerCode: workerCode ?? this.workerCode,
      age: age ?? this.age,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'role': role.name,
      'permissions': permissions.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'photoUrl': photoUrl,
      'phone': phone,
      'department': department,
      'workerCode': workerCode,
      'age': age,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      displayName: data['displayName'] as String? ?? 'مستخدم',
      email: data['email'] as String? ?? '',
      role: AppRole.values.firstWhere(
        (role) => role.name == data['role'],
        orElse: () => AppRole.worker,
      ),
      permissions: RolePermissions.fromMap(
        (data['permissions'] as Map<String, dynamic>?),
      ),
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      department: data['department'] as String?,
      workerCode: data['workerCode'] as String?,
      age: (data['age'] as num?)?.toInt(),
      lastLogin: DateTime.tryParse(data['lastLogin'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        role,
        permissions,
        createdAt,
        photoUrl,
        phone,
        department,
        workerCode,
        age,
        lastLogin,
      ];
}
