import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/theme_notifier.dart';
import 'providers/work_entries_provider.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/manager/manager_dashboard.dart';
import 'screens/worker/worker_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const KararApp());
}

class KararApp extends StatelessWidget {
  const KararApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, WorkEntriesProvider>(
          create: (_) => WorkEntriesProvider(),
          update: (_, auth, provider) => provider!..updateUser(auth.currentUser),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, auth, provider) => provider!..updateUser(auth.currentUser),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            title: 'Karar Manager',
            debugShowCheckedModeBanner: false,
            theme: themeNotifier.lightTheme,
            darkTheme: themeNotifier.darkTheme,
            themeMode: themeNotifier.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (auth.currentUser == null) {
                  return const LandingScreen();
                }
                return auth.currentUser!.isManager
                    ? const ManagerDashboard()
                    : WorkerDashboard(user: auth.currentUser!);
              },
            ),
          );
        },
      ),
    );
  }
}
