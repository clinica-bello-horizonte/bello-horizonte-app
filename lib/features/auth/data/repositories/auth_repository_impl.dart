import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({required AuthRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    final user = await _datasource.login(identifier.trim(), password);
    return user.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String dni,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? birthDate,
  }) async {
    final user = await _datasource.register(
      dni: dni,
      email: email.toLowerCase(),
      phone: phone,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      password: password,
      birthDate: birthDate,
    );
    return user.toEntity();
  }

  @override
  Future<void> logout() async {
    await _datasource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await _datasource.getMe();
    return user?.toEntity();
  }

  @override
  Future<void> resetPassword({required String identifier}) async {
    await _datasource.forgotPassword(identifier.trim());
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    String? birthDate,
  }) async {
    await _datasource.updateProfile(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone,
      birthDate: birthDate,
    );
  }
}
