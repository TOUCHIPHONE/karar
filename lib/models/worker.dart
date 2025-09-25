import 'package:equatable/equatable.dart';

class Worker extends Equatable {
  const Worker({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.hourlyRate,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;
  final double hourlyRate;
  final WorkerRole role;

  factory Worker.fromMap(String id, Map<String, dynamic> data) {
    return Worker(
      id: id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      role: WorkerRole.values.firstWhere(
        (role) => role.name == (data['role'] ?? WorkerRole.worker.name),
        orElse: () => WorkerRole.worker,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'hourlyRate': hourlyRate,
      'role': role.name,
    };
  }

  Worker copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarUrl,
    double? hourlyRate,
    WorkerRole? role,
  }) {
    return Worker(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      role: role ?? this.role,
    );
  }

  bool get isAdmin => role == WorkerRole.admin || role == WorkerRole.superAdmin;

  @override
  List<Object?> get props => [id, fullName, email, phone, avatarUrl, hourlyRate, role];
}

enum WorkerRole { worker, manager, admin, superAdmin }
