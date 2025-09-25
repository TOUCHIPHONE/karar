import 'package:flutter/material.dart';

import '../../models/app_user.dart';

class WorkerDrawer extends StatelessWidget {
  const WorkerDrawer({super.key, required this.user, required this.onLogout});

  final AppUser user;
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
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(user.displayName.isNotEmpty
                        ? user.displayName.characters.first
                        : '?')
                    : null,
              ),
              accountName: Text(user.displayName),
              accountEmail: Text(user.email),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('رمز العامل'),
              subtitle: Text(user.workerCode ?? 'غير محدد'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('رقم الهاتف'),
              subtitle: Text(user.phone ?? 'لم يتم التعيين'),
            ),
            ListTile(
              leading: const Icon(Icons.cake_outlined),
              title: const Text('العمر'),
              subtitle: Text(user.age?.toString() ?? 'غير محدد'),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
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
