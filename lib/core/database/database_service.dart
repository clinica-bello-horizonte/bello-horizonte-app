import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import 'mock_data.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          "ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'user'",
        );
      } catch (_) {}
      await _seedAdminUser(db);
    }
    if (oldVersion < 3) {
      await _createNotificationsTable(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        dni TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        birth_date TEXT,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS specialties (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS doctors (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        specialty_id TEXT NOT NULL,
        description TEXT,
        photo_url TEXT,
        rating REAL DEFAULT 0,
        years_experience INTEGER DEFAULT 0,
        consultation_fee REAL DEFAULT 0,
        available_days TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (specialty_id) REFERENCES specialties (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        specialty_id TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        reason TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (doctor_id) REFERENCES doctors (id),
        FOREIGN KEY (specialty_id) REFERENCES specialties (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS patient_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        appointment_id TEXT,
        diagnosis TEXT,
        treatment TEXT,
        notes TEXT,
        record_date TEXT NOT NULL,
        doctor_name TEXT,
        specialty_name TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await _createNotificationsTable(db);
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0,
        route_path TEXT
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final spec in MockData.specialties) {
      batch.insert('specialties', spec, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    for (final doc in MockData.doctors) {
      batch.insert(
        'doctors',
        {...doc, 'created_at': now},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    batch.insert(
      'users',
      {
        'id': 'demo_user_001',
        'dni': '00000000',
        'email': 'demo@bellohorizonte.pe',
        'phone': '999000001',
        'first_name': 'Carlos',
        'last_name': 'Mendoza Ríos',
        'birth_date': '1990-05-15',
        'password_hash': _hashPassword('demo123'),
        'role': 'user',
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await batch.commit(noResult: true);
    await _seedAdminUser(db);
  }

  Future<void> _seedAdminUser(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'users',
      {
        'id': 'admin_user_001',
        'dni': '11111111',
        'email': 'admin@bellohorizonte.pe',
        'phone': '999000002',
        'first_name': 'Admin',
        'last_name': 'Sistema',
        'birth_date': '1980-01-01',
        'password_hash': _hashPassword('admin123'),
        'role': 'admin',
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  String _hashPassword(String password) {
    const salt = 'bello_horizonte_2024_salt';
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
