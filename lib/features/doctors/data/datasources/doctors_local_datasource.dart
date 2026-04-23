import '../../../../core/database/database_service.dart';
import '../models/doctor_model.dart';

class DoctorsLocalDatasource {
  final DatabaseService _db;
  DoctorsLocalDatasource(this._db);

  Future<List<DoctorModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('doctors', orderBy: 'last_name ASC');
    return result.map(DoctorModel.fromMap).toList();
  }

  Future<DoctorModel?> getById(String id) async {
    final db = await _db.database;
    final result = await db.query('doctors', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return DoctorModel.fromMap(result.first);
  }

  Future<List<DoctorModel>> getBySpecialty(String specialtyId) async {
    final db = await _db.database;
    final result = await db.query(
      'doctors',
      where: 'specialty_id = ?',
      whereArgs: [specialtyId],
      orderBy: 'rating DESC',
    );
    return result.map(DoctorModel.fromMap).toList();
  }

  Future<List<DoctorModel>> search(String query) async {
    final db = await _db.database;
    final q = '%${query.toLowerCase()}%';
    final result = await db.query(
      'doctors',
      where: 'LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ?',
      whereArgs: [q, q],
      orderBy: 'last_name ASC',
    );
    return result.map(DoctorModel.fromMap).toList();
  }

  Future<void> update(DoctorModel doctor) async {
    final db = await _db.database;
    await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }
}
