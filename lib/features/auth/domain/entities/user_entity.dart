import 'package:equatable/equatable.dart';

enum UserRole { admin, doctor, user }

class UserEntity extends Equatable {
  final String id;
  final String dni;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String? birthDate;
  final DateTime createdAt;
  final UserRole role;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    required this.dni,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.birthDate,
    required this.createdAt,
    this.role = UserRole.user,
    this.photoUrl,
  });

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == UserRole.admin;
  bool get isDoctor => role == UserRole.doctor;

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  UserEntity copyWith({
    String? id,
    String? dni,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? birthDate,
    DateTime? createdAt,
    UserRole? role,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      dni: dni ?? this.dni,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, dni, email, phone, firstName, lastName, birthDate, createdAt, role, photoUrl];
}
