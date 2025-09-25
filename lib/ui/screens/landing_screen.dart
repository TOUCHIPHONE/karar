import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'manager/manager_shell.dart';
import 'worker/worker_shell.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isAuthenticated) {
      final worker = auth.currentWorker;
      if (worker == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      if (worker.isAdmin || worker.role == WorkerRole.manager) {
        return const ManagerShell();
      }
      return const WorkerShell();
    }

    return const LoginScreen();
  }
}
