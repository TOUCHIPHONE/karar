import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/wage_provider.dart';
import '../../../providers/theme_provider.dart';
import '../settings_screen.dart';
import 'expenses_screen.dart';
import 'wages_screen.dart';

class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});

  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wageProvider = context.watch<WageProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final pages = [
      WagesScreen(totalAmount: wageProvider.formattedTotal),
      ExpensesScreen(totalAmount: expenseProvider.formattedTotal),
      SettingsScreen(worker: auth.currentWorker),
    ];

    return Scaffold(
      drawer: _ManagerDrawer(
        workerName: auth.currentWorker?.fullName ?? 'بدون اسم',
        role: auth.currentWorker?.role.name ?? '',
        totalExpenses: expenseProvider.formattedTotal,
        totalWages: wageProvider.formattedTotal,
        onSignOut: () => context.read<AuthProvider>().signOut(),
      ),
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.wb_sunny_outlined
                : Icons.nights_stay_outlined),
            onPressed: () =>
                themeProvider.toggleTheme(themeProvider.themeMode != ThemeMode.dark),
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            label: 'أجور العمال',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            label: 'المصروفات',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

class _ManagerDrawer extends StatelessWidget {
  const _ManagerDrawer({
    required this.workerName,
    required this.role,
    required this.totalExpenses,
    required this.totalWages,
    required this.onSignOut,
  });

  final String workerName;
  final String role;
  final String totalExpenses;
  final String totalWages;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(workerName),
              accountEmail: Text('الدور: $role'),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/manager.png'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('تاريخ اليوم'),
              subtitle: Text('${now.year}-${now.month}-${now.day}'),
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('مجموع المصروفات'),
              subtitle: Text(totalExpenses),
            ),
            ListTile(
              leading: const Icon(Icons.handyman),
              title: const Text('عدد الأعمال / الإجمالي'),
              subtitle: Text(totalWages),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: onSignOut,
            ),
          ],
        ),
      ),
    );
  }
}
