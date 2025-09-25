import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/wage_entry.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wage_provider.dart';
import '../../widgets/empty_state.dart';

class WorkerShell extends StatelessWidget {
  const WorkerShell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wageProvider = context.watch<WageProvider>();
    final worker = auth.currentWorker;
    final entries = wageProvider.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('أجوري اليومية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
      drawer: _WorkerDrawer(workerName: worker?.fullName ?? 'عامل'),
      body: entries.isEmpty
          ? const EmptyState(message: 'لا توجد بيانات مسجلة بعد')
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ListTile(
                    title: Text(entry.partType),
                    subtitle: Text(
                      'التاريخ: ${DateFormat.yMd().format(entry.date)}\nعدد القطع: ${entry.piecesCount}\nالسعر: ${entry.pricePerPiece}',
                    ),
                    trailing: Text(NumberFormat.currency(symbol: '').format(entry.totalAmount)),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: entries.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIssueDialog(context, worker?.fullName ?? ''),
        icon: const Icon(Icons.report_problem_outlined),
        label: const Text('إبلاغ عن مشكلة'),
      ),
    );
  }

  Future<void> _showIssueDialog(BuildContext context, String workerName) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إرسال ملاحظة للمدير'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'اكتب ملاحظتك هنا...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () async {
                // TODO: Integrate with Cloud Messaging or Firestore to notify manager.
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إرسال رسالتك إلى المدير')),
                );
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }
}

class _WorkerDrawer extends StatelessWidget {
  const _WorkerDrawer({required this.workerName});

  final String workerName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(workerName),
              accountEmail: Text('اليوم: ${DateFormat.yMMMMd().format(now)}'),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/worker.png'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('تعديل بياناتي'),
              onTap: () => _showProfileEditor(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileEditor(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final worker = auth.currentWorker;
    final nameController = TextEditingController(text: worker?.fullName);
    final phoneController = TextEditingController(text: worker?.phone);
    final emailController = TextEditingController(text: worker?.email);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final updated = worker?.copyWith(
                    fullName: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                  );
                  if (updated != null) {
                    await auth.updateProfile(updated);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );
  }
}
