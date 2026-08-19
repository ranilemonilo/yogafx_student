import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../dashboard/presentation/providers/running_login_time_provider.dart';
import '../../../module/presentation/providers/module_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/models/auth_user.dart';
import '../../data/repositories/auth_repository.dart';

// State
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  blocked,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthNotifier(
    this._ref,
    this._repository,
  ) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    final isBlocked = await SecureStorageService.isAccountBlocked();
    if (isBlocked) {
      state = const AuthState(status: AuthStatus.blocked);
      return;
    }

    final hasToken = await SecureStorageService.hasToken();

    if (!hasToken) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
      return;
    }

    try {
      final user = await _repository.getCurrentUser();

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
      }
    } on AppException catch (e) {
      if (e is UnauthorizedException) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
        return;
      }

      if (hasToken) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          error: e.message,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    } catch (_) {
      if (hasToken) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<bool> verifyLoginOtp({
    required String challengeToken,
    required String otpCode,
    String deviceName = 'flutter_app',
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      error: null,
    );

    try {
      final response = await _repository.verifyLoginOtp(
        challengeToken: challengeToken,
        otpCode: otpCode,
        deviceName: deviceName,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        error: null,
      );

      await SecureStorageService.setAccountBlocked(false);

      _resetUserScopedProviders();

      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.message,
      );

      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();

    _resetUserScopedProviders();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  Future<void> blockSession() async {
    await SecureStorageService.setAccountBlocked(true);
    await SecureStorageService.deleteToken();

    _resetUserScopedProviders();

    state = const AuthState(
      status: AuthStatus.blocked,
      error: 'Your student account has been temporarily blocked.',
    );
  }

  Future<void> leaveBlockedSession() async {
    await SecureStorageService.setAccountBlocked(false);
    await SecureStorageService.deleteToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshCurrentUser() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await _repository.getCurrentUser();

      if (user == null) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      );

      _resetUserScopedProviders();
    } catch (_) {
      // Pertahankan state authenticated jika refresh background gagal.
    }
  }

  void _resetUserScopedProviders() {
    _ref.invalidate(dashboardProvider);
    _ref.invalidate(runningLoginTimeProvider);
    _ref.invalidate(profileProvider);
    _ref.invalidate(moduleListProvider);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref,
    ref.read(authRepositoryProvider),
  );
});
