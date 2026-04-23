import '../../../../core/database/database_service.dart';
import '../models/specialty_model.dart';

class SpecialtiesLocalDatasource {
  final DatabaseService _db;
  SpecialtiesLocalDatasource(this._db);

  Future<List<SpecialtyModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('specialties', orderBy: 'name ASC');
    return result.map(SpecialtyModel.fromMap).toList();
  }

  Future<SpecialtyModel?> getById(String id) async {
    final db = await _db.database;
    final result = await db.query('specialties', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return SpecialtyModel.fromMap(result.first);
  }
}
