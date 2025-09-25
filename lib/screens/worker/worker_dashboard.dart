import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/support_message.dart';
import '../../models/work_entry.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/layout/worker_drawer.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key, required this.user});

  final AppUser user;

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final _firestore = FirestoreService();
  final _messageController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.displayName;
    _ageController.text = widget.user.age?.toString() ?? '';
    _phoneController.text = widget.user.phone ?? '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final currentUser = context.read<AuthProvider>().currentUser ?? widget.user;
    final message = SupportMessage(
      id: '',
      senderId: currentUser.id,
      senderName: currentUser.displayName,
      body: text,
      createdAt: DateTime.now(),
    );
    await _firestore.sendSupportMessage(message);
    _messageController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال الرسالة إلى الإدارة')), 
    );
  }

  Future<void> _updateProfile() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      age: int.tryParse(_ageController.text),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث بياناتك')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    final updatedUser = context.watch<AuthProvider>().currentUser ?? widget.user;
    final currency = NumberFormat.currency(symbol: 'IQD');
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة العامل'),
      ),
      drawer: WorkerDrawer(user: updatedUser, onLogout: () => context.read<AuthProvider>().logout()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('أعمالي اليومية', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<WorkEntry>>(
                stream: _firestore.listenWorkEntries(workerName: updatedUser.displayName),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final entries = snapshot.data!;
                  if (entries.isEmpty) {
                    return const Center(child: Text('لا توجد بيانات أعمال مسجلة بعد'));
                  }
                  final total = entries.fold<double>(0, (value, element) => value + element.totalAmount);
                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Chip(
                          avatar: const Icon(Icons.payments, size: 18),
                          label: Text('الإجمالي المستحق: ${currency.format(total)}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Card(
                              child: ListTile(
                                title: Text(entry.pieceType),
                                subtitle: Text(
                                  'عدد القطع: ${entry.piecesCount}\nالسعر: ${currency.format(entry.unitPrice)}\nالتاريخ: ${DateFormat.yMd().format(entry.workDate)}',
                                ),
                                trailing: Text(
                                  currency.format(entry.totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('تحديث بياناتي', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'العمر (اختياري)',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _updateProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('تحديث'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('إبلاغ عن مشكلة', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'رسالتك إلى الإدارة',
                        prefixIcon: Icon(Icons.message_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('إرسال'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
