import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'api_endpoints.dart';
import 'token_service.dart';

class ApiClient {
  late final Dio _dio;
  final TokenService _tokenService;

  ApiClient(this._tokenService) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh')) {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshDio = Dio();
          final response = await refreshDio.post(
            '${ApiEndpoints.baseUrl}${ApiEndpoints.refresh}',
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );
          final data = response.data['data'] as Map<String, dynamic>;
          await _tokenService.saveTokens(
            accessToken: data['accessToken'] as String,
            refreshToken: data['refreshToken'] as String,
          );
          err.requestOptions.headers['Authorization'] =
              'Bearer ${data['accessToken']}';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          await _tokenService.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  AppException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException('Sin conexión al servidor');
    }
    final status = e.response?.statusCode;
    if (status == null) return const NetworkException('Error de red');
    final message = _extractMessage(e.response?.data);
    return switch (status) {
      401 => const InvalidCredentialsException(),
      404 => NotFoundException(message ?? 'Recurso no encontrado'),
      409 => ConflictException(message ?? 'Conflicto en la operación'),
      422 => ValidationException(message ?? 'Datos inválidos'),
      _ when status >= 500 => ServerException(message ?? 'Error del servidor'),
      _ => AppException(message ?? 'Error inesperado'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) return data['message'] as String?;
    return null;
  }

  dynamic _extractData(Response response) {
    if (response.data is Map) return (response.data as Map)['data'];
    return null;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: queryParameters);
      return _extractData(res);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return _extractData(res);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    try {
      final res = await _dio.patch(path, data: body);
      return _extractData(res);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<dynamic> uploadFile(
    String path,
    List<int> bytes, {
    required String filename,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await _dio.post(path, data: formData);
      return _extractData(res);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }
}
