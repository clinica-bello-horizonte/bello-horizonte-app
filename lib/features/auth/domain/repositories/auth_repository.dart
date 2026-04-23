import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String identifier, required String password});
  Future<UserEntity> register({
    required String dni,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? birthDate,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> resetPassword({required String identifier});
  Future<void> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    String? birthDate,
  });
}
