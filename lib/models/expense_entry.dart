import 'package:equatable/equatable.dart';

class ExpenseEntry extends Equatable {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.spentAt,
    this.note,
    this.createdBy,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime spentAt;
  final String? note;
  final String? createdBy;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'spentAt': spentAt.toIso8601String(),
      'note': note,
      'createdBy': createdBy,
    };
  }

  ExpenseEntry copyWith({
    String? title,
    double? amount,
    DateTime? spentAt,
    String? note,
    String? createdBy,
  }) {
    return ExpenseEntry(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory ExpenseEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return ExpenseEntry(
      id: id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      spentAt: DateTime.tryParse(data['spentAt'] as String? ?? '') ?? DateTime.now(),
      note: data['note'] as String?,
      createdBy: data['createdBy'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, amount, spentAt, note, createdBy];
}
