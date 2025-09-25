import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/expense_entry.dart';
import '../models/work_filter.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'IQD');

  AppUser? _user;
  DateRangeFilter _dateRange = const DateRangeFilter();
  String? _searchTerm;
  List<ExpenseEntry> _entries = [];
  StreamSubscription<List<ExpenseEntry>>? _subscription;

  List<ExpenseEntry> get entries => _entries;
  DateRangeFilter get dateRange => _dateRange;
  String? get searchTerm => _searchTerm;
  String get formattedTotal => _currency.format(totalAmount);
  double get totalAmount =>
      _entries.fold<double>(0, (total, entry) => total + entry.amount);

  void updateUser(AppUser? user) {
    _user = user;
    _subscription?.cancel();
    if (_user != null) {
      _subscription = _firestore
          .listenExpenseEntries(
            start: _dateRange.start,
            end: _dateRange.end,
            searchTerm: _searchTerm,
          )
          .listen((event) {
        _entries = event;
        notifyListeners();
      });
    } else {
      _entries = [];
      notifyListeners();
    }
  }

  Future<void> addEntry(ExpenseEntry entry) async {
    await _firestore.addExpenseEntry(entry);
  }

  Future<void> updateEntry(ExpenseEntry entry) async {
    await _firestore.updateExpenseEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    await _firestore.deleteExpenseEntry(id);
  }

  void applyFilter({DateTime? start, DateTime? end, String? searchTerm, bool reset = false}) {
    if (reset) {
      _dateRange = const DateRangeFilter();
      _searchTerm = null;
    } else {
      _dateRange = DateRangeFilter(start: start ?? _dateRange.start, end: end ?? _dateRange.end);
      _searchTerm = searchTerm ?? _searchTerm;
    }
    updateUser(_user);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
