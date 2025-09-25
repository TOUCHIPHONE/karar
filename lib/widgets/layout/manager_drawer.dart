import 'package:flutter/material.dart';

import '../../models/app_user.dart';

class ManagerDrawer extends StatelessWidget {
  const ManagerDrawer({
    super.key,
    required this.user,
    required this.today,
    required this.totalExpenses,
    required this.workCount,
    required this.onLogout,
  });

  final AppUser? user;
  final String today;
  final String totalExpenses;
  final int workCount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: colorScheme.primaryContainer),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text((user?.displayName.isNotEmpty ?? false)
                        ? user!.displayName.characters.first
                        : '?')
                    : null,
              ),
              accountName: Text(user?.displayName ?? 'المدير'),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ اليوم'),
              subtitle: Text(today),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('إجمالي المصروفات'),
              subtitle: Text(totalExpenses),
            ),
            ListTile(
              leading: const Icon(Icons.work_history),
              title: const Text('عدد الأعمال المسجلة'),
              subtitle: Text('$workCount عملية'),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
