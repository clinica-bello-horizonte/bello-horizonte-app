import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();
  static final instance = LocalNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'bello_horizonte_reminders';
  static const _channelName = 'Recordatorios de citas';

  Future<void> initialize() async {
    if (_initialized || (!Platform.isAndroid && !Platform.isIOS)) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
          playSound: true,
        ));

    _initialized = true;
  }

  /// Programa un recordatorio para el día anterior a la cita a las 08:00.
  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required DateTime appointmentDate,
    required String doctorName,
    required String time,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await initialize();

    final reminderDay = appointmentDate.subtract(const Duration(days: 1));
    final local = tz.local;
    final scheduledTime = tz.TZDateTime(local,
      reminderDay.year, reminderDay.month, reminderDay.day, 8, 0);

    if (scheduledTime.isBefore(tz.TZDateTime.now(local))) return;

    final notifId = appointmentId.hashCode.abs() % 100000;

    await _plugin.zonedSchedule(
      notifId,
      '📅 Cita mañana a las $time',
      'Recuerda tu cita con $doctorName. ¡No olvides asistir!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String appointmentId) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await _plugin.cancel(appointmentId.hashCode.abs() % 100000);
  }
}
