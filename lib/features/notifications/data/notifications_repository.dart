import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_service.dart';
import '../domain/entities/notification_entity.dart';

class NotificationsRepository {
  NotificationsRepository._();
  static final NotificationsRepository instance = NotificationsRepository._();

  Future<Database> get _db => DatabaseService.instance.database;

  Future<List<AppNotification>> loadAll() async {
    final db = await _db;
    final rows = await db.query(
      'notifications',
      orderBy: 'created_at DESC',
    );
    return rows.map(AppNotification.fromMap).toList();
  }

  Future<void> insert(AppNotification n) async {
    final db = await _db;
    await db.insert(
      'notifications',
      n.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertAll(List<AppNotification> notifications) async {
    final db = await _db;
    final batch = db.batch();
    for (final n in notifications) {
      batch.insert('notifications', n.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<bool> existsByRoutePath(String routePath) async {
    final db = await _db;
    final rows = await db.query(
      'notifications',
      columns: ['id'],
      where: 'route_path = ?',
      whereArgs: [routePath],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> markRead(String id) async {
    final db = await _db;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAllRead() async {
    final db = await _db;
    await db.update('notifications', {'is_read': 1});
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }
}
