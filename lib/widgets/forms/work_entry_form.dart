import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/work_entry.dart';

class WorkEntryForm extends StatefulWidget {
  const WorkEntryForm({
    super.key,
    this.initialEntry,
    required this.onSubmit,
    required this.availableWorkers,
  });

  final WorkEntry? initialEntry;
  final void Function(WorkEntry entry) onSubmit;
  final List<String> availableWorkers;

  @override
  State<WorkEntryForm> createState() => _WorkEntryFormState();
}

class _WorkEntryFormState extends State<WorkEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pieceTypeController;
  late final TextEditingController _pieceCountController;
  late final TextEditingController _unitPriceController;
  late DateTime _selectedDate;
  String? _notes;

  double get _total =>
      (int.tryParse(_pieceCountController.text) ?? 0) *
      (double.tryParse(_unitPriceController.text) ?? 0);

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    _nameController = TextEditingController(text: entry?.workerName ?? '');
    _pieceTypeController = TextEditingController(text: entry?.pieceType ?? '');
    _pieceCountController = TextEditingController(
      text: entry != null ? entry.piecesCount.toString() : '',
    );
    _unitPriceController = TextEditingController(
      text: entry != null ? entry.unitPrice.toStringAsFixed(2) : '',
    );
    _selectedDate = entry?.workDate ?? DateTime.now();
    _notes = entry?.notes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pieceTypeController.dispose();
    _pieceCountController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final entry = WorkEntry(
      id: widget.initialEntry?.id ?? '',
      workerId: widget.initialEntry?.workerId ?? '',
      workerName: _nameController.text.trim(),
      pieceType: _pieceTypeController.text.trim(),
      piecesCount: int.tryParse(_pieceCountController.text) ?? 0,
      unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
      totalAmount: _total,
      workDate: _selectedDate,
      notes: _notes,
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
                widget.initialEntry == null
                    ? 'إضافة أجر عمل جديد'
                    : 'تعديل بيانات الأجر',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.availableWorkers;
                  }
                  return widget.availableWorkers.where(
                    (option) => option.contains(textEditingValue.text),
                  );
                },
                initialValue: TextEditingValue(text: _nameController.text),
                onSelected: (value) => _nameController.text = value,
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.text = _nameController.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'اسم العامل',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'أدخل اسم العامل' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pieceTypeController,
                decoration: const InputDecoration(
                  labelText: 'نوع القطعة',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'أدخل نوع القطعة' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _pieceCountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد القطع',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'السعر للوحدة',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range),
                title: const Text('تاريخ اليوم'),
                subtitle: Text(DateFormat.yMd().format(_selectedDate)),
                trailing: TextButton(
                  onPressed: _selectDate,
                  child: const Text('اختيار'),
                ),
              ),
              TextFormField(
                initialValue: _notes,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  prefixIcon: Icon(Icons.sticky_note_2_outlined),
                ),
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الإجمالي المتوقع'),
                      const SizedBox(height: 8),
                      Text(
                        currency.format(_total),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_outlined),
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
