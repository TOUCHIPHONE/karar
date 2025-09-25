import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user.dart';
import '../models/work_entry.dart';
import '../models/work_filter.dart';
import '../services/firestore_service.dart';

class WorkEntriesProvider extends ChangeNotifier {
  WorkEntriesProvider({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService();

  final FirestoreService _firestore;
  final NumberFormat _currency = NumberFormat.currency(symbol: 'IQD');

  AppUser? _user;
  WorkFilter _filter = const WorkFilter();
  List<WorkEntry> _entries = [];
  StreamSubscription<List<WorkEntry>>? _subscription;

  List<WorkEntry> get entries => _entries;
  WorkFilter get filter => _filter;
  String get formattedTotal => _currency.format(totalAmount);

  double get totalAmount => _entries.fold<double>(0, (total, entry) => total + entry.totalAmount);

  List<String> get workers => {
        for (final entry in _entries) entry.workerName,
      }.toList()
        ..sort();

  void updateUser(AppUser? user) {
    _user = user;
    _subscription?.cancel();
    if (_user != null) {
      _subscription = _firestore
          .listenWorkEntries(
            workerName: _filter.workerName,
            start: _filter.dateRange.start,
            end: _filter.dateRange.end,
            searchTerm: _filter.searchTerm,
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

  Future<void> addEntry(WorkEntry entry) async {
    await _firestore.addWorkEntry(entry);
  }

  Future<void> updateEntry(WorkEntry entry) async {
    await _firestore.updateWorkEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    await _firestore.deleteWorkEntry(id);
  }

  void applyFilter(WorkFilter filter) {
    _filter = filter;
    updateUser(_user);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
