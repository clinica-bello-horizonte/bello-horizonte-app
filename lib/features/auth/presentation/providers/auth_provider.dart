import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  return AuthRepositoryImpl(
    datasource: AuthRemoteDatasource(api, tokenService),
  );
});

// Auth state
class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isAuthenticated => user != null;
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login({required String identifier, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(identifier: identifier, password: password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
      return false;
    }
  }

  Future<bool> register({
    required String dni,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? birthDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        dni: dni,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        password: password,
        birthDate: birthDate,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<bool> resetPassword({required String identifier}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resetPassword(identifier: identifier);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? birthDate,
  }) async {
    final userId = state.user?.id;
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthDate: birthDate,
      );
      final updatedUser = state.user!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        birthDate: birthDate,
      );
      state = AuthState(user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('Credenciales')) return 'DNI/correo o contraseña incorrectos';
    if (msg.contains('ya existe')) return 'Ya existe una cuenta con ese DNI o correo';
    if (msg.contains('no encontrado')) return 'Usuario no encontrado';
    return 'Ocurrió un error. Intenta nuevamente';
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
