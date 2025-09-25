import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/worker.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Worker? _currentWorker;
  bool _isManagerLogin = true;

  Worker? get currentWorker => _currentWorker;
  bool get isAuthenticated => _auth.currentUser != null;
  bool get isManagerLogin => _isManagerLogin;

  Future<void> toggleLoginRole(bool isManager) async {
    _isManagerLogin = isManager;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _loadWorkerProfile(credential.user!.uid);
  }

  Future<void> signUpManager({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final worker = Worker(
      id: credential.user!.uid,
      fullName: fullName,
      email: email,
      phone: '',
      avatarUrl: '',
      hourlyRate: 0,
      role: WorkerRole.manager,
    );
    await _firestore.collection('workers').doc(worker.id).set(worker.toMap());
    _currentWorker = worker;
    notifyListeners();
  }

  Future<void> _loadWorkerProfile(String userId) async {
    final doc = await _firestore.collection('workers').doc(userId).get();
    if (doc.exists) {
      _currentWorker = Worker.fromMap(doc.id, doc.data()!);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentWorker = null;
    notifyListeners();
  }

  Future<void> updateProfile(Worker worker) async {
    await _firestore.collection('workers').doc(worker.id).update(worker.toMap());
    _currentWorker = worker;
    notifyListeners();
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Stream<List<Worker>> listenWorkers() {
    return _firestore.collection('workers').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Worker.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }
}
