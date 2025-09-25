import 'package:equatable/equatable.dart';

class ExpenseEntry extends Equatable {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? notes;

  factory ExpenseEntry.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseEntry(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, title, amount, date, notes];
}
