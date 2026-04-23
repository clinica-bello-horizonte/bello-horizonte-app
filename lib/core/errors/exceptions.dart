class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException() : super('Credenciales inválidas');
}

class UserAlreadyExistsException extends AppException {
  const UserAlreadyExistsException() : super('El usuario ya existe');
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class DatabaseException extends AppException {
  const DatabaseException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class ConflictException extends AppException {
  const ConflictException(super.message);
}
