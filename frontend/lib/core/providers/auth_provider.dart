import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Authentication Provider for WonderWorld Learning Adventure
/// 
/// NOTE: Authentication is DISABLED for this app.
/// Kids play directly without login - uses device-based identification instead.
/// This provider is kept for compatibility but always returns authenticated state.

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  
  const AuthState({
    this.isAuthenticated = true, // Always authenticated in no-auth mode
    this.isLoading = false,
    this.error,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());
  
  // Authentication is disabled - these methods are no-ops kept for compatibility
  
  Future<bool> login(String email, String password) async {
    // Auth disabled - always succeed
    return true;
  }
  
  Future<bool> register(String email, String password, String? firstName) async {
    // Auth disabled - always succeed
    return true;
  }
  
  Future<void> logout() async {
    // Auth disabled - no-op (but could clear local data if needed)
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
