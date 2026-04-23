import 'package:sqflite/sqflite.dart' hide DatabaseException;

import '../../../../core/database/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  final DatabaseService _databaseService;

  AuthLocalDatasource(this._databaseService);

  Future<UserModel?> getUserByDni(String dni) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'users',
      where: 'dni = ?',
      whereArgs: [dni],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<UserModel> createUser(UserModel user) async {
    final db = await _databaseService.database;
    try {
      await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
      return user;
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE')) {
        throw const UserAlreadyExistsException();
      }
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    final db = await _databaseService.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> existsByDni(String dni) async {
    final user = await getUserByDni(dni);
    return user != null;
  }

  Future<bool> existsByEmail(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }
}
