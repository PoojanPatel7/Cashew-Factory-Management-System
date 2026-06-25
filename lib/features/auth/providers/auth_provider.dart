import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? role;
  final String? name;
  final bool? faceRegistered;
  final bool? isEmployee;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.role,
    this.name,
    this.faceRegistered,
    this.isEmployee,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? role,
    String? name,
    bool? faceRegistered,
    bool? isEmployee,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      role: role ?? this.role,
      name: name ?? this.name,
      faceRegistered: faceRegistered ?? this.faceRegistered,
      isEmployee: isEmployee ?? this.isEmployee,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient = ApiClient();

  AuthNotifier() : super(AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final isLoggedIn = await _apiClient.isLoggedIn();
    if (isLoggedIn) {
      final role = await _apiClient.getUserRole();
      state = state.copyWith(isAuthenticated: true, role: role);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      await _apiClient.saveToken(data['token'], data['user']['role']);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: data['user']['role'],
        name: data['user']['name'],
        isEmployee: data['user']['isEmployee'] ?? false,
        faceRegistered: data['user']['faceRegistered'] ?? true,
      );
      return true;
    } on DioException catch (e) {
      final errorMsg = e.response?.data['error'] ?? 'Network error. Please try again.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String factory) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'OWNER',
      });
      // automatically log in after registration
      return await login(email, password);
    } on DioException catch (e) {
      final errorMsg = e.response?.data['error'] ?? 'Registration failed.';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearAuth();
    state = AuthState(); // Reset to default
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
