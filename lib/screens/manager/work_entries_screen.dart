import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/work_entry.dart';
import '../../models/work_filter.dart';
import '../../providers/work_entries_provider.dart';
import '../../services/report_service.dart';
import '../../widgets/forms/work_entry_form.dart';

class WorkEntriesScreen extends StatelessWidget {
  const WorkEntriesScreen({super.key});

  void _openEntryForm(BuildContext context, {WorkEntry? entry}) {
    final provider = context.read<WorkEntriesProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WorkEntryForm(
        initialEntry: entry,
        availableWorkers: provider.workers,
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
    final provider = context.watch<WorkEntriesProvider>();
    final entries = provider.entries;
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
                child: DropdownButtonFormField<String?>(
                  value: provider.filter.workerName,
                  decoration: const InputDecoration(
                    labelText: 'تصفية حسب العامل',
                    prefixIcon: Icon(Icons.person_search),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...provider.workers.map(
                      (name) => DropdownMenuItem(value: name, child: Text(name)),
                    ),
                  ],
                  onChanged: (value) {
                    provider.applyFilter(provider.filter.copyWith(workerName: value));
                  },
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'بحث',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => provider.applyFilter(
                    provider.filter.copyWith(searchTerm: value),
                  ),
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
                    provider.applyFilter(
                      provider.filter.copyWith(
                        dateRange: DateRangeFilter(start: range.start, end: range.end),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('تحديد المدة'),
              ),
              OutlinedButton.icon(
                onPressed: () => provider.applyFilter(
                  const WorkFilter(),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة التعيين'),
              ),
              FilledButton.icon(
                onPressed: entries.isEmpty
                    ? null
                    : () => ReportService().printWorkReport(entries),
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
              avatar: const Icon(Icons.attach_money, size: 18),
              label: Text('الإجمالي: ${provider.formattedTotal}'),
            ),
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Center(
                  child: Text('لم يتم تسجيل أعمال بعد'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.engineering)),
                        title: Text(entry.workerName),
                        subtitle: Text(
                          'نوع القطعة: ${entry.pieceType}\nعدد القطع: ${entry.piecesCount} - السعر: ${currency.format(entry.unitPrice)}\nالتاريخ: ${DateFormat.yMd().format(entry.workDate)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currency.format(entry.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openEntryForm(context, entry: entry),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('حذف العملية'),
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
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: entries.length,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton.extended(
              onPressed: () => _openEntryForm(context),
              icon: const Icon(Icons.add),
              label: const Text('إضافة أجر عمل'),
            ),
          ),
        ),
      ],
    );
  }
}
