import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/role_permissions.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createManager({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    return credential;
  }

  Future<void> createWorkerAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await credential.user?.sendEmailVerification();
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'لا يوجد مستخدم مسجل حالياً',
      );
    }
    await user.updatePassword(newPassword);
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
  }

  AppUser mapFirebaseUser(User firebaseUser, RolePermissions permissions) {
    return AppUser(
      id: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? firebaseUser.email ?? 'مستخدم',
      email: firebaseUser.email ?? '',
      role: permissions.canManageUsers ? AppRole.manager : AppRole.worker,
      permissions: permissions,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      photoUrl: firebaseUser.photoURL,
      phone: firebaseUser.phoneNumber,
      lastLogin: firebaseUser.metadata.lastSignInTime,
    );
  }
}
