import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/expense_entry.dart';
import '../models/role_permissions.dart';
import '../models/support_message.dart';
import '../models/work_entry.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _workCollection =>
      _firestore.collection('workEntries');
  CollectionReference<Map<String, dynamic>> get _expenseCollection =>
      _firestore.collection('expenseEntries');
  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore.collection('supportMessages');

  Future<void> saveUser(AppUser user) {
    return _usersCollection.doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> fetchUser(String uid) async {
    final snapshot = await _usersCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return AppUser.fromMap(snapshot.id, snapshot.data()!);
  }

  Future<void> updateUserPermissions(String uid, RolePermissions permissions) {
    return _usersCollection.doc(uid).update({'permissions': permissions.toMap()});
  }

  Stream<List<AppUser>> listenWorkers() {
    return _usersCollection
        .where('role', isEqualTo: AppRole.worker.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppUser.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addWorkEntry(WorkEntry entry) {
    return _workCollection.add(entry.toMap());
  }

  Future<void> updateWorkEntry(WorkEntry entry) {
    return _workCollection.doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteWorkEntry(String id) {
    return _workCollection.doc(id).delete();
  }

  Stream<List<WorkEntry>> listenWorkEntries({
    String? workerName,
    DateTime? start,
    DateTime? end,
    String? searchTerm,
  }) {
    Query<Map<String, dynamic>> query = _workCollection.orderBy('workDate', descending: true);

    if (workerName != null && workerName.isNotEmpty) {
      query = query.where('workerName', isEqualTo: workerName);
    }
    if (start != null) {
      query = query.where('workDate', isGreaterThanOrEqualTo: start.toIso8601String());
    }
    if (end != null) {
      query = query.where('workDate', isLessThanOrEqualTo: end.toIso8601String());
    }

    return query.snapshots().map((snapshot) {
      final results = snapshot.docs
          .map((doc) => WorkEntry.fromFirestore(doc.id, doc.data()))
          .where((entry) {
        if (searchTerm == null || searchTerm.isEmpty) {
          return true;
        }
        final lower = searchTerm.toLowerCase();
        return entry.workerName.toLowerCase().contains(lower) ||
            entry.pieceType.toLowerCase().contains(lower);
      }).toList();
      return results;
    });
  }

  Future<void> addExpenseEntry(ExpenseEntry entry) {
    return _expenseCollection.add(entry.toMap());
  }

  Future<void> updateExpenseEntry(ExpenseEntry entry) {
    return _expenseCollection.doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteExpenseEntry(String id) {
    return _expenseCollection.doc(id).delete();
  }

  Stream<List<ExpenseEntry>> listenExpenseEntries({
    DateTime? start,
    DateTime? end,
    String? searchTerm,
  }) {
    Query<Map<String, dynamic>> query =
        _expenseCollection.orderBy('spentAt', descending: true);

    if (start != null) {
      query = query.where('spentAt', isGreaterThanOrEqualTo: start.toIso8601String());
    }
    if (end != null) {
      query = query.where('spentAt', isLessThanOrEqualTo: end.toIso8601String());
    }

    return query.snapshots().map((snapshot) {
      final expenses = snapshot.docs
          .map((doc) => ExpenseEntry.fromFirestore(doc.id, doc.data()))
          .where((entry) {
        if (searchTerm == null || searchTerm.isEmpty) {
          return true;
        }
        final lower = searchTerm.toLowerCase();
        return entry.title.toLowerCase().contains(lower) ||
            (entry.note ?? '').toLowerCase().contains(lower);
      }).toList();
      return expenses;
    });
  }

  Future<void> sendSupportMessage(SupportMessage message) {
    return _messagesCollection.add(message.toMap());
  }

  Stream<List<SupportMessage>> listenSupportMessages() {
    return _messagesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportMessage.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}
