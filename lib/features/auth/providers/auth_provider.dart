import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/network/api_client.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? role;
  final String? name;
  final String? id;
  final bool? faceRegistered;
  final bool? isEmployee;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.role,
    this.name,
    this.id,
    this.faceRegistered,
    this.isEmployee,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? role,
    String? name,
    String? id,
    bool? faceRegistered,
    bool? isEmployee,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      role: role ?? this.role,
      name: name ?? this.name,
      id: id ?? this.id,
      faceRegistered: faceRegistered ?? this.faceRegistered,
      isEmployee: isEmployee ?? this.isEmployee,
    );
  }
}

class AuthRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRouterRefresh routerRefresh = AuthRouterRefresh();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier() : super(AuthState()) {
    _checkInitialAuth();
  }

  void _notifyRouter() => routerRefresh.refresh();

  Future<void> _checkInitialAuth() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists) {
            final data = doc.data()!;
            state = state.copyWith(
              isAuthenticated: true,
              role: data['role'] ?? 'OWNER',
              name: data['name'] ?? 'Factory Owner',
              id: user.uid,
              isEmployee: data['isEmployee'] ?? false,
              faceRegistered: data['faceRegistered'] ?? true,
            );
          } else {
            // Document might not exist right after registration, before set() completes
            state = state.copyWith(isAuthenticated: true, id: user.uid, role: null, isEmployee: null);
          }
        } catch (e) {
          state = state.copyWith(error: 'Failed to load user profile.', isAuthenticated: true, id: user.uid, role: null, isEmployee: null);
        }
      } else {
        state = AuthState();
      }
      _notifyRouter();
    });
  }

  void markFaceRegistered() {
    state = state.copyWith(faceRegistered: true);
    if (state.id != null) {
      _firestore.collection('users').doc(state.id).update({'faceRegistered': true});
    }
    _notifyRouter();
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final googleProvider = GoogleAuthProvider();
      UserCredential userCredential;
      
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        userCredential = await _auth.signInWithProvider(googleProvider);
      }
      
      if (userCredential.user != null) {
        // The _checkInitialAuth listener will pick up the user change and load from Firestore
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Google sign-in was cancelled.');
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Google sign-in failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> verifyOwnerPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);
    if (pin != '5252') {
      state = state.copyWith(isLoading: false, error: 'Invalid PIN');
      return false;
    }

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': user.displayName ?? 'Factory Owner',
          'email': user.email ?? '',
          'role': 'OWNER',
          'isEmployee': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        state = state.copyWith(
          isLoading: false,
          role: 'OWNER',
          isEmployee: false,
          name: user.displayName ?? 'Factory Owner',
          isAuthenticated: true,
        );
        _notifyRouter();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to assign owner role.');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Login failed');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String factory) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'OWNER',
        'isEmployee': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Registration failed.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? 'Failed to send reset email.');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = AuthState();
    _notifyRouter();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
