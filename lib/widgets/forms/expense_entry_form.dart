import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_entry.dart';

class ExpenseEntryForm extends StatefulWidget {
  const ExpenseEntryForm({super.key, this.initialEntry, required this.onSubmit});

  final ExpenseEntry? initialEntry;
  final void Function(ExpenseEntry entry) onSubmit;

  @override
  State<ExpenseEntryForm> createState() => _ExpenseEntryFormState();
}

class _ExpenseEntryFormState extends State<ExpenseEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _spentAt;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _amountController = TextEditingController(
      text: entry != null ? entry.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: entry?.note ?? '');
    _spentAt = entry?.spentAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _spentAt,
    );
    if (picked != null) {
      setState(() => _spentAt = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final entry = ExpenseEntry(
      id: widget.initialEntry?.id ?? '',
      title: _titleController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0,
      spentAt: _spentAt,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      createdBy: widget.initialEntry?.createdBy,
    );
    widget.onSubmit(entry);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'IQD');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initialEntry == null ? 'إضافة مصروف جديد' : 'تعديل المصروف',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'اسم الحاجة',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'أدخل اسم الحاجة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'أدخل مبلغ الصرف' : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text('تاريخ الصرف'),
                subtitle: Text(DateFormat.yMd().format(_spentAt)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('اختيار'),
                ),
              ),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('المبلغ'),
                      const SizedBox(height: 8),
                      Text(
                        currency.format(double.tryParse(_amountController.text) ?? 0),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('حفظ'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
