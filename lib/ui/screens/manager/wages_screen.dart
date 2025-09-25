import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/wage_entry.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/wage_provider.dart';
import '../../widgets/date_range_filter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/worker_dropdown.dart';

class WagesScreen extends StatefulWidget {
  const WagesScreen({super.key, required this.totalAmount});

  final String totalAmount;

  @override
  State<WagesScreen> createState() => _WagesScreenState();
}

class _WagesScreenState extends State<WagesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workerNameController = TextEditingController();
  final _piecesController = TextEditingController();
  final _priceController = TextEditingController();
  final _partTypeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _workerNameController.dispose();
    _piecesController.dispose();
    _priceController.dispose();
    _partTypeController.dispose();
    super.dispose();
  }

  Future<void> _submit(WageProvider provider, Worker? worker) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final pieces = int.tryParse(_piecesController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = pieces * price;
    final entry = WageEntry(
      id: '',
      workerId: worker?.id ?? '',
      workerName: _workerNameController.text.trim(),
      partType: _partTypeController.text.trim(),
      piecesCount: pieces,
      pricePerPiece: price,
      totalAmount: total,
      date: _selectedDate,
    );
    try {
      await provider.addEntry(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة الأجر بنجاح')),
      );
      _formKey.currentState!.reset();
      _piecesController.clear();
      _priceController.clear();
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
    final wageProvider = context.watch<WageProvider>();
    final authProvider = context.watch<AuthProvider>();
    final entries = wageProvider.entries;

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
                    'إجمالي أجور اليوم',
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
                        WorkerDropdown(
                          onSelected: (worker) {
                            _workerNameController.text = worker.fullName;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _workerNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم العامل',
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'أدخل اسم العامل' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _piecesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'عدد القطع',
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'أدخل العدد' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'سعر القطعة',
                                ),
                                validator: (value) => value == null || value.isEmpty
                                    ? 'أدخل السعر'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _partTypeController,
                          decoration: const InputDecoration(
                            labelText: 'نوع القطعة',
                          ),
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
                        Row(
                          children: [
                            Text('الإجمالي:'),
                            const SizedBox(width: 8),
                            Text(
                              NumberFormat.currency(symbol: '')
                                  .format((int.tryParse(_piecesController.text) ?? 0) *
                                      (double.tryParse(_priceController.text) ?? 0)),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed:
                                _isSubmitting ? null : () => _submit(wageProvider, authProvider.currentWorker),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_alt),
                            label: const Text('حفظ الأجر'),
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
                  onChanged: wageProvider.setSearchQuery,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'بحث عن عامل أو نوع القطعة...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DateRangeFilter(onSelected: wageProvider.setDateRange),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: entries.isEmpty
              ? const EmptyState(message: 'لا توجد بيانات أجور')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        title: Text(entry.workerName),
                        subtitle: Text(
                          'عدد القطع: ${entry.piecesCount}\nالسعر: ${entry.pricePerPiece}\nالتاريخ: ${DateFormat.yMd().format(entry.date)}',
                        ),
                        trailing: Text(NumberFormat.currency(symbol: '').format(entry.totalAmount)),
                        onTap: () async {
                          await _showEntryActions(context, entry, wageProvider);
                        },
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

  Future<void> _showEntryActions(
    BuildContext context,
    WageEntry entry,
    WageProvider provider,
  ) async {
    final priceController = TextEditingController(text: entry.pricePerPiece.toString());
    final piecesController =
        TextEditingController(text: entry.piecesCount.toString());
    final partController = TextEditingController(text: entry.partType);
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
              ListTile(
                title: Text(entry.workerName,
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(DateFormat.yMd().format(entry.date)),
              ),
              TextField(
                controller: partController,
                decoration: const InputDecoration(labelText: 'نوع القطعة'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: piecesController,
                      decoration: const InputDecoration(labelText: 'عدد القطع'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'السعر'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final updated = WageEntry(
                          id: entry.id,
                          workerId: entry.workerId,
                          workerName: entry.workerName,
                          partType: partController.text,
                          piecesCount: int.tryParse(piecesController.text) ?? entry.piecesCount,
                          pricePerPiece:
                              double.tryParse(priceController.text) ?? entry.pricePerPiece,
                          totalAmount:
                              (int.tryParse(piecesController.text) ?? entry.piecesCount) *
                                  (double.tryParse(priceController.text) ?? entry.pricePerPiece),
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
