import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  
  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuth();
  }
  
  void _checkAuth() {
    final token = StorageService.accessToken;
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }
  
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await apiService.login(email, password);
      
      if (response.statusCode == 200) {
        final data = response.data;
        StorageService.accessToken = data['access_token'];
        StorageService.refreshToken = data['refresh_token'];
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: data['user'],
        );
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please check your credentials.',
      );
    }
    return false;
  }
  
  Future<bool> register(String email, String password, String? firstName) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await apiService.register({
        'email': email,
        'password': password,
        if (firstName != null) 'first_name': firstName,
        'data_processing_agreed': true,
      });
      
      if (response.statusCode == 201) {
        // Auto-login after registration
        return await login(email, password);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Email may already be in use.',
      );
    }
    return false;
  }
  
  Future<void> logout() async {
    try {
      await apiService.logout();
    } catch (e) {
      // Continue with local logout even if API fails
    }
    
    await StorageService.clearAll();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
