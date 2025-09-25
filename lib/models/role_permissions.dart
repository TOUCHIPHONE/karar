import 'package:equatable/equatable.dart';

enum AppRole { manager, worker }

class RolePermissions extends Equatable {
  const RolePermissions({
    required this.canViewDashboard,
    required this.canManageWork,
    required this.canManageExpenses,
    required this.canManageUsers,
    required this.canPrint,
  });

  factory RolePermissions.fullAccess() => const RolePermissions(
        canViewDashboard: true,
        canManageWork: true,
        canManageExpenses: true,
        canManageUsers: true,
        canPrint: true,
      );

  factory RolePermissions.workerAccess() => const RolePermissions(
        canViewDashboard: true,
        canManageWork: false,
        canManageExpenses: false,
        canManageUsers: false,
        canPrint: false,
      );

  factory RolePermissions.partial({
    bool viewDashboard = true,
    bool manageWork = false,
    bool manageExpenses = false,
    bool manageUsers = false,
    bool print = false,
  }) {
    return RolePermissions(
      canViewDashboard: viewDashboard,
      canManageWork: manageWork,
      canManageExpenses: manageExpenses,
      canManageUsers: manageUsers,
      canPrint: print,
    );
  }

  final bool canViewDashboard;
  final bool canManageWork;
  final bool canManageExpenses;
  final bool canManageUsers;
  final bool canPrint;

  RolePermissions copyWith({
    bool? canViewDashboard,
    bool? canManageWork,
    bool? canManageExpenses,
    bool? canManageUsers,
    bool? canPrint,
  }) {
    return RolePermissions(
      canViewDashboard: canViewDashboard ?? this.canViewDashboard,
      canManageWork: canManageWork ?? this.canManageWork,
      canManageExpenses: canManageExpenses ?? this.canManageExpenses,
      canManageUsers: canManageUsers ?? this.canManageUsers,
      canPrint: canPrint ?? this.canPrint,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canViewDashboard': canViewDashboard,
      'canManageWork': canManageWork,
      'canManageExpenses': canManageExpenses,
      'canManageUsers': canManageUsers,
      'canPrint': canPrint,
    };
  }

  factory RolePermissions.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return RolePermissions.workerAccess();
    }
    return RolePermissions(
      canViewDashboard: data['canViewDashboard'] as bool? ?? false,
      canManageWork: data['canManageWork'] as bool? ?? false,
      canManageExpenses: data['canManageExpenses'] as bool? ?? false,
      canManageUsers: data['canManageUsers'] as bool? ?? false,
      canPrint: data['canPrint'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        canViewDashboard,
        canManageWork,
        canManageExpenses,
        canManageUsers,
        canPrint,
      ];
}
