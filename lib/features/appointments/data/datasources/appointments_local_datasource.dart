import '../../../../core/database/database_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../models/appointment_model.dart';

class AppointmentsLocalDatasource {
  final DatabaseService _db;
  AppointmentsLocalDatasource(this._db);

  Future<List<AppointmentModel>> getByUserId(String userId) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT
        a.*,
        d.first_name || ' ' || d.last_name AS doctor_name,
        s.name AS specialty_name
      FROM appointments a
      LEFT JOIN doctors d ON a.doctor_id = d.id
      LEFT JOIN specialties s ON a.specialty_id = s.id
      WHERE a.user_id = ?
      ORDER BY a.appointment_date DESC, a.appointment_time DESC
    ''', [userId]);
    return result.map(AppointmentModel.fromMap).toList();
  }

  Future<List<AppointmentModel>> getUpcoming(String userId) async {
    final db = await _db.database;
    final today = DateFormatter.toDb(DateTime.now());
    final result = await db.rawQuery('''
      SELECT
        a.*,
        d.first_name || ' ' || d.last_name AS doctor_name,
        s.name AS specialty_name
      FROM appointments a
      LEFT JOIN doctors d ON a.doctor_id = d.id
      LEFT JOIN specialties s ON a.specialty_id = s.id
      WHERE a.user_id = ?
        AND a.appointment_date >= ?
        AND a.status NOT IN ('cancelled')
      ORDER BY a.appointment_date ASC, a.appointment_time ASC
    ''', [userId, today]);
    return result.map(AppointmentModel.fromMap).toList();
  }

  Future<AppointmentModel?> getById(String id) async {
    final db = await _db.database;
    final result = await db.rawQuery('''
      SELECT
        a.*,
        d.first_name || ' ' || d.last_name AS doctor_name,
        s.name AS specialty_name
      FROM appointments a
      LEFT JOIN doctors d ON a.doctor_id = d.id
      LEFT JOIN specialties s ON a.specialty_id = s.id
      WHERE a.id = ?
    ''', [id]);
    if (result.isEmpty) return null;
    return AppointmentModel.fromMap(result.first);
  }

  Future<AppointmentModel> insert(AppointmentModel appointment) async {
    final db = await _db.database;
    await db.insert('appointments', appointment.toMap());
    return appointment;
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await _db.database;
    await db.update(
      'appointments',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reschedule(String id, String newDate, String newTime) async {
    final db = await _db.database;
    await db.update(
      'appointments',
      {
        'appointment_date': newDate,
        'appointment_time': newTime,
        'status': 'rescheduled',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getBookedSlots(String doctorId, String date) async {
    final db = await _db.database;
    final result = await db.query(
      'appointments',
      columns: ['appointment_time'],
      where: "doctor_id = ? AND appointment_date = ? AND status != 'cancelled'",
      whereArgs: [doctorId, date],
    );
    return result.map((r) => r['appointment_time'] as String).toList();
  }
}
