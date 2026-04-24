import 'package:flutter/material.dart';

enum NotificationType { appointmentReminder, appointmentToday, checkup, healthTip, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? routePath;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.routePath,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        routePath: routePath,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'created_at': createdAt.toIso8601String(),
        'is_read': isRead ? 1 : 0,
        'route_path': routePath,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => NotificationType.system,
        ),
        createdAt: DateTime.parse(map['created_at'] as String),
        isRead: (map['is_read'] as int) == 1,
        routePath: map['route_path'] as String?,
      );

  IconData get icon => switch (type) {
        NotificationType.appointmentReminder => Icons.calendar_today_rounded,
        NotificationType.appointmentToday => Icons.alarm_rounded,
        NotificationType.checkup => Icons.health_and_safety_rounded,
        NotificationType.healthTip => Icons.lightbulb_rounded,
        NotificationType.system => Icons.info_rounded,
      };

  Color get color => switch (type) {
        NotificationType.appointmentReminder => const Color(0xFF1565C0),
        NotificationType.appointmentToday => const Color(0xFFF59E0B),
        NotificationType.checkup => const Color(0xFF00897B),
        NotificationType.healthTip => const Color(0xFF6A1B9A),
        NotificationType.system => const Color(0xFF6B7280),
      };
}
