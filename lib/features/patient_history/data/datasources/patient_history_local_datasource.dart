import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/database/mock_data.dart';
import '../models/patient_record_model.dart';

class PatientHistoryLocalDatasource {
  final DatabaseService _db;
  PatientHistoryLocalDatasource(this._db);

  Future<List<PatientRecordModel>> getByUserId(String userId) async {
    final db = await _db.database;

    // Seed demo records for demo user on first access
    await _seedDemoRecords(db, userId);

    final result = await db.query(
      'patient_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'record_date DESC',
    );
    return result.map(PatientRecordModel.fromMap).toList();
  }

  Future<PatientRecordModel?> getById(String id) async {
    final db = await _db.database;
    final result = await db.query(
      'patient_records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return PatientRecordModel.fromMap(result.first);
  }

  Future<void> _seedDemoRecords(Database db, String userId) async {
    final existing = await db.query('patient_records', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    if (existing.isNotEmpty) return;

    final now = DateTime.now().toIso8601String();
    for (final record in MockData.patientRecords) {
      await db.insert(
        'patient_records',
        {...record, 'user_id': userId, 'created_at': now},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }
}
