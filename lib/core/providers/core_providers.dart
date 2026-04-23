import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../database/database_service.dart';
import '../network/api_client.dart';
import '../network/token_service.dart';
import '../security/security_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final securityServiceProvider = Provider<SecurityService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecurityService(storage: storage);
});

final tokenServiceProvider = Provider<TokenService>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenService(storage);
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return ApiClient(tokenService);
});
