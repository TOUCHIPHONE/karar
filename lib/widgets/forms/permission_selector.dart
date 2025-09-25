import 'package:flutter/material.dart';

import '../../models/role_permissions.dart';

class PermissionSelector extends StatefulWidget {
  const PermissionSelector({super.key, required this.onChanged, this.initial});

  final ValueChanged<RolePermissions> onChanged;
  final RolePermissions? initial;

  @override
  State<PermissionSelector> createState() => _PermissionSelectorState();
}

class _PermissionSelectorState extends State<PermissionSelector> {
  late bool _manageWork;
  late bool _manageExpenses;
  late bool _manageUsers;
  late bool _canPrint;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial ?? RolePermissions.workerAccess();
    _manageWork = initial.canManageWork;
    _manageExpenses = initial.canManageExpenses;
    _manageUsers = initial.canManageUsers;
    _canPrint = initial.canPrint;
  }

  void _notify() {
    widget.onChanged(
      RolePermissions.partial(
        viewDashboard: true,
        manageWork: _manageWork,
        manageExpenses: _manageExpenses,
        manageUsers: _manageUsers,
        print: _canPrint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: _manageWork,
          onChanged: (value) {
            setState(() => _manageWork = value);
            _notify();
          },
          title: const Text('إدارة أجور الأعمال'),
        ),
        SwitchListTile.adaptive(
          value: _manageExpenses,
          onChanged: (value) {
            setState(() => _manageExpenses = value);
            _notify();
          },
          title: const Text('إدارة المصروفات'),
        ),
        SwitchListTile.adaptive(
          value: _manageUsers,
          onChanged: (value) {
            setState(() => _manageUsers = value);
            _notify();
          },
          title: const Text('إدارة المستخدمين'),
        ),
        SwitchListTile.adaptive(
          value: _canPrint,
          onChanged: (value) {
            setState(() => _canPrint = value);
            _notify();
          },
          title: const Text('السماح بالطباعة'),
        ),
      ],
    );
  }
}
