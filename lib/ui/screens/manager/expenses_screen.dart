import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_entry.dart';
import '../../../providers/expense_provider.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/empty_state.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.totalAmount});

  final String totalAmount;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(ExpenseProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final entry = ExpenseEntry(
      id: '',
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      date: _selectedDate,
    );
    try {
      await provider.addEntry(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل المصروف')),
      );
      _formKey.currentState!.reset();
      _amountController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final entries = provider.entries;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'إجمالي المصروفات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.totalAmount,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'اسم الحاجة'),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'أدخل اسم الحاجة' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'المبلغ'),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'أدخل المبلغ' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text('التاريخ: ${DateFormat.yMd().format(_selectedDate)}'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final result = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (result != null) {
                                  setState(() => _selectedDate = result);
                                }
                              },
                              child: const Text('اختيار التاريخ'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : () => _submit(provider),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_alt),
                            label: const Text('حفظ المصروف'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: provider.setSearchQuery,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'بحث عن مصروف...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DateRangeFilter(onSelected: provider.setDateRange),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: entries.isEmpty
              ? const EmptyState(message: 'لا توجد مصروفات')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        title: Text(entry.title),
                        subtitle: Text(DateFormat.yMd().format(entry.date)),
                        trailing:
                            Text(NumberFormat.currency(symbol: '').format(entry.amount)),
                        onTap: () => _showActions(context, entry, provider),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: entries.length,
                ),
        ),
      ],
    );
  }

  Future<void> _showActions(
    BuildContext context,
    ExpenseEntry entry,
    ExpenseProvider provider,
  ) async {
    final titleController = TextEditingController(text: entry.title);
    final amountController = TextEditingController(text: entry.amount.toString());
    await showModalBottomSheet(
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
                controller: titleController,
                decoration: const InputDecoration(labelText: 'اسم الحاجة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'المبلغ'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final updated = ExpenseEntry(
                          id: entry.id,
                          title: titleController.text,
                          amount: double.tryParse(amountController.text) ?? entry.amount,
                          date: entry.date,
                        );
                        await provider.updateEntry(updated);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.deleteEntry(entry.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('حذف'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
