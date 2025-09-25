import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense_entry.dart';
import '../../providers/expense_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/forms/expense_entry_form.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  void _openForm(BuildContext context, {ExpenseEntry? entry}) {
    final provider = context.read<ExpenseProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpenseEntryForm(
        initialEntry: entry,
        onSubmit: (newEntry) async {
          Navigator.of(context).pop();
          if (entry == null) {
            await provider.addEntry(newEntry);
          } else {
            await provider.updateEntry(newEntry);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expenses = provider.entries;
    final currency = NumberFormat.currency(symbol: 'IQD');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'بحث عن مصروف',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => provider.applyFilter(searchTerm: value),
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (range != null) {
                    provider.applyFilter(start: range.start, end: range.end);
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('تحديد المدة'),
              ),
              OutlinedButton.icon(
                onPressed: () => provider.applyFilter(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة التعيين'),
              ),
              FilledButton.icon(
                onPressed: expenses.isEmpty
                    ? null
                    : () => ReportService().printExpenseReport(expenses),
                icon: const Icon(Icons.print_outlined),
                label: const Text('طباعة'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Chip(
              avatar: const Icon(Icons.payments, size: 18),
              label: Text('إجمالي المصروفات: ${provider.formattedTotal}'),
            ),
          ),
        ),
        Expanded(
          child: expenses.isEmpty
              ? const Center(child: Text('لا توجد مصروفات مسجلة'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final entry = expenses[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                        title: Text(entry.title),
                        subtitle: Text(
                          'التاريخ: ${DateFormat.yMd().format(entry.spentAt)}\nالمبلغ: ${currency.format(entry.amount)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(context, entry: entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('حذف المصروف'),
                                    content: const Text('هل أنت متأكد من حذف هذا السجل؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await provider.deleteEntry(entry.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: expenses.length,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة مصروف'),
            ),
          ),
        ),
      ],
    );
  }
}
