import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._authService) {
    _subscription = _authService.authStateChanges().listen(_onUserChanged);
    _onUserChanged(_authService.currentUser);
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _subscription;

  AuthStatus status = AuthStatus.unknown;
  bool isLoading = false;
  String? errorMessage;

  User? get user => _authService.currentUser;

  Future<void> signIn(String email, String password) async {
    await _guardedRequest(
      () => _authService.signIn(email: email, password: password),
    );
  }

  Future<void> signUp(String email, String password) async {
    await _guardedRequest(
      () => _authService.signUp(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> _guardedRequest(Future<void> Function() request) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      await request();
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _onUserChanged(User? user) {
    status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
