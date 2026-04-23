import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/token_service.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _api;
  final TokenService _tokenService;

  AuthRemoteDatasource(this._api, this._tokenService);

  Future<UserModel> login(String identifier, String password) async {
    final data = await _api.post(ApiEndpoints.login, body: {
      'identifier': identifier,
      'password': password,
    }) as Map<String, dynamic>;
    await _tokenService.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String dni,
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    String? birthDate,
  }) async {
    final data = await _api.post(ApiEndpoints.register, body: {
      'dni': dni,
      'email': email,
      'phone': phone,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      if (birthDate != null) 'birthDate': birthDate,
    }) as Map<String, dynamic>;
    await _tokenService.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      await _api.post(ApiEndpoints.logout, body: {
        if (refreshToken != null) 'refreshToken': refreshToken,
      });
    } catch (_) {
      // Best-effort: clear local tokens regardless
    } finally {
      await _tokenService.clearTokens();
    }
  }

  Future<UserModel?> getMe() async {
    final hasTokens = await _tokenService.hasTokens();
    if (!hasTokens) return null;
    try {
      final data = await _api.get(ApiEndpoints.me) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> forgotPassword(String identifier) async {
    await _api.post(ApiEndpoints.forgotPassword, body: {
      'identifier': identifier,
    });
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? birthDate,
  }) async {
    final data = await _api.patch(ApiEndpoints.userProfile, body: {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      if (birthDate != null) 'birthDate': birthDate,
    }) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
