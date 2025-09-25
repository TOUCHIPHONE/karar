import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/work_entries_provider.dart';
import '../../providers/theme_notifier.dart';
import '../../widgets/layout/manager_drawer.dart';
import '../settings/manager_settings_screen.dart';
import 'expenses_screen.dart';
import 'work_entries_screen.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  int _currentIndex = 0;

  final _pages = const [
    WorkEntriesScreen(),
    ExpensesScreen(),
    ManagerSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workProvider = context.watch<WorkEntriesProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final date = DateFormat.yMMMMd('ar').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(['أجور الأعمال', 'المصروفات', 'الإعدادات'][_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () => context.read<ThemeNotifier>().toggle(),
          ),
        ],
      ),
      drawer: ManagerDrawer(
        user: auth.currentUser,
        today: date,
        totalExpenses: expenseProvider.formattedTotal,
        workCount: workProvider.entries.length,
        onLogout: () => context.read<AuthProvider>().logout(),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.engineering_outlined),
            selectedIcon: Icon(Icons.engineering),
            label: 'الأعمال',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'المصروفات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
