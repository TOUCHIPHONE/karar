import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wage_entry.dart';
import '../models/worker.dart';
import 'auth_provider.dart';

class WageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthProvider? _authProvider;

  List<WageEntry> _entries = [];
  String _searchQuery = '';
  String? _selectedWorkerId;
  DateTimeRange? _dateRange;

  double get totalAmount => _entries.fold(0, (sum, entry) => sum + entry.totalAmount);
  List<WageEntry> get entries => _applyFilters();
  String get formattedTotal => NumberFormat.currency(symbol: '')
      .format(totalAmount);

  void attachAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    _listenToEntries();
  }

  void _listenToEntries() {
    final workerId = _authProvider?.currentWorker?.id;
    final isManager = _authProvider?.currentWorker?.isAdmin ?? false;

    Query query = _firestore.collection('wages');
    if (!isManager && workerId != null) {
      query = query.where('workerId', isEqualTo: workerId);
    }

    query.snapshots().listen((snapshot) {
      _entries = snapshot.docs
          .map((doc) => WageEntry.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  List<WageEntry> _applyFilters() {
    return _entries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.workerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.partType.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesWorker =
          _selectedWorkerId == null || entry.workerId == _selectedWorkerId;
      final matchesDate = _dateRange == null ||
          (entry.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
              entry.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
      return matchesSearch && matchesWorker && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setWorkerFilter(String? workerId) {
    _selectedWorkerId = workerId;
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }

  Future<void> addEntry(WageEntry entry) async {
    await _firestore.collection('wages').add(entry.toMap());
  }

  Future<void> updateEntry(WageEntry entry) async {
    await _firestore.collection('wages').doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _firestore.collection('wages').doc(id).delete();
  }
}
