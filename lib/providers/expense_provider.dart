import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_entry.dart';
import 'auth_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthProvider? _authProvider;

  List<ExpenseEntry> _entries = [];
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  void attachAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    _listenToEntries();
  }

  double get totalAmount =>
      _entries.fold(0, (sum, entry) => sum + entry.amount);
  String get formattedTotal => NumberFormat.currency(symbol: '').format(totalAmount);
  List<ExpenseEntry> get entries => _applyFilters();

  void _listenToEntries() {
    final worker = _authProvider?.currentWorker;
    Query query = _firestore.collection('expenses');
    if (!(worker?.isAdmin ?? false)) {
      query = query.where('createdBy', isEqualTo: worker?.id);
    }
    query.snapshots().listen((snapshot) {
      _entries = snapshot.docs
          .map((doc) => ExpenseEntry.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  List<ExpenseEntry> _applyFilters() {
    return _entries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDate = _dateRange == null ||
          (entry.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              entry.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? value) {
    _dateRange = value;
    notifyListeners();
  }

  Future<void> addEntry(ExpenseEntry entry) async {
    await _firestore.collection('expenses').add({
      ...entry.toMap(),
      'createdBy': _authProvider?.currentWorker?.id,
    });
  }

  Future<void> updateEntry(ExpenseEntry entry) async {
    await _firestore.collection('expenses').doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }
}
