import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/role_permissions.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/forms/permission_selector.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

  @override
  State<ManagerSettingsScreen> createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  final _firestore = FirestoreService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _workerNameController = TextEditingController();
  final _workerEmailController = TextEditingController();
  final _workerPasswordController = TextEditingController();
  RolePermissions _newAdminPermissions = RolePermissions.fullAccess();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _workerNameController.dispose();
    _workerEmailController.dispose();
    _workerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(AuthProvider auth) async {
    await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث البيانات')), 
    );
  }

  Future<void> _changePassword(AuthProvider auth) async {
    await auth.changePassword(_passwordController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تغيير كلمة المرور')), 
    );
    _passwordController.clear();
  }

  Future<void> _createWorker(AuthProvider auth) async {
    await auth.createWorker(
      email: _workerEmailController.text.trim(),
      password: _workerPasswordController.text,
      displayName: _workerNameController.text.trim(),
    );
    _workerEmailController.clear();
    _workerPasswordController.clear();
    _workerNameController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء حساب العامل وإرسال التحقق عبر البريد')), 
    );
  }

  Future<void> _updatePermissions(String uid) async {
    await context.read<AuthProvider>().updatePermissions(uid, _newAdminPermissions);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الصلاحيات')), 
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.displayName;
    }
    if (user != null && user.phone != null && _phoneController.text.isEmpty) {
      _phoneController.text = user.phone!;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (user != null) _ManagerInfoCard(user: user),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تحديث بيانات المدير', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _updateProfile(auth),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('حفظ البيانات'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تغيير كلمة المرور', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة مرور جديدة',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _changePassword(auth),
                    icon: const Icon(Icons.password),
                    label: const Text('تغيير'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إضافة عامل جديد', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _workerNameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم العامل',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _workerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _workerPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور المؤقتة',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _createWorker(auth),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('إضافة العامل'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('إدارة المشرفين والصلاحيات', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  PermissionSelector(
                    initial: _newAdminPermissions,
                    onChanged: (value) => _newAdminPermissions = value,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final controller = TextEditingController();
                      final uid = await showDialog<String?>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('تحديد المستخدم'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'معرف المستخدم (UID)',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('إلغاء'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, controller.text),
                              child: const Text('تعيين'),
                            ),
                          ],
                        ),
                      );
                      if (uid != null && uid.isNotEmpty) {
                        await _updatePermissions(uid);
                      }
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('تحديث صلاحيات المستخدم'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('قائمة العمال', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          StreamBuilder<List<AppUser>>(
            stream: _firestore.listenWorkers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final workers = snapshot.data!;
              if (workers.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا يوجد عمال مسجلين بعد'),
                  ),
                );
              }
              return Column(
                children: workers
                    .map(
                      (worker) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.engineering),
                          title: Text(worker.displayName),
                          subtitle: Text(worker.email),
                          trailing: Text(DateFormat.yMd().format(worker.createdAt)),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ManagerInfoCard extends StatelessWidget {
  const _ManagerInfoCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMMMMd('ar');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null ? Text(user.displayName.characters.first) : null,
        ),
        title: Text(user.displayName),
        subtitle: Text('البريد: ${user.email}\nتاريخ الإنشاء: ${formatter.format(user.createdAt)}'),
      ),
    );
  }
}
