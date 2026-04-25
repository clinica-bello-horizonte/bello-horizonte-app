import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String passwordHash;

  const UserModel({
    required super.id,
    required super.dni,
    required super.email,
    required super.phone,
    required super.firstName,
    required super.lastName,
    super.birthDate,
    required super.createdAt,
    required this.passwordHash,
    super.role = UserRole.user,
    super.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? 'user').toLowerCase();
    return UserModel(
      id: json['id'] as String,
      dni: json['dni'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: json['birthDate'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      passwordHash: '',
      photoUrl: json['photoUrl'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.user,
      ),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final roleStr = map['role'] as String? ?? 'user';
    return UserModel(
      id: map['id'] as String,
      dni: map['dni'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      birthDate: map['birth_date'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      passwordHash: map['password_hash'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dni': dni,
      'email': email,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
      'role': role.name,
    };
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        dni: dni,
        email: email,
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        createdAt: createdAt,
        role: role,
      );
}
