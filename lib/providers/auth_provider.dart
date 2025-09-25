import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/role_permissions.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _listenToAuth();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;

  AppUser? currentUser;
  bool isLoading = true;
  StreamSubscription<User?>? _authSubscription;

  Future<void> _listenToAuth() async {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser = null;
        isLoading = false;
        notifyListeners();
        return;
      }
      await _loadUser(firebaseUser);
    });
  }

  Future<void> _loadUser(User firebaseUser) async {
    isLoading = true;
    notifyListeners();
    try {
      final savedUser = await _firestoreService.fetchUser(firebaseUser.uid);
      if (savedUser != null) {
        currentUser = savedUser.copyWith(lastLogin: DateTime.now());
      } else {
        final defaultPermissions = firebaseUser.email?.contains('manager') ?? false
            ? RolePermissions.fullAccess()
            : RolePermissions.workerAccess();
        final newUser = _authService.mapFirebaseUser(firebaseUser, defaultPermissions);
        await _firestoreService.saveUser(newUser);
        currentUser = newUser;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    isLoading = true;
    notifyListeners();
    try {
      final credential = await _authService.signIn(email: email, password: password);
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'no-user', message: 'فشل تسجيل الدخول');
      }
      await _loadUser(user);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<void> changePassword(String newPassword) async {
    await _authService.updatePassword(newPassword);
  }

  Future<void> updateProfile({String? name, String? photoUrl, String? phone, int? age}) async {
    await _authService.updateProfile(displayName: name, photoUrl: photoUrl);
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(
        displayName: name ?? currentUser!.displayName,
        photoUrl: photoUrl ?? currentUser!.photoUrl,
        phone: phone ?? currentUser!.phone,
        age: age ?? currentUser!.age,
      );
      await _firestoreService.saveUser(currentUser!);
      notifyListeners();
    }
  }

  Future<void> createWorker({
    required String email,
    required String password,
    required String displayName,
    String? department,
    String? workerCode,
  }) async {
    await _authService.createWorkerAccount(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  Future<void> updatePermissions(String uid, RolePermissions permissions) async {
    await _firestoreService.updateUserPermissions(uid, permissions);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
