import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('DNI/Email o contraseña incorrectos');
}

class UserAlreadyExistsFailure extends Failure {
  const UserAlreadyExistsFailure() : super('Ya existe un usuario con ese DNI o correo');
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure() : super('La sesión ha expirado. Inicia sesión nuevamente');
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure() : super('Ocurrió un error inesperado. Intenta nuevamente');
}
