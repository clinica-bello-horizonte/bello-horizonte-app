import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../data/notifications_repository.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(const []) {
    _init();
  }

  static final _uuid = Uuid();
  final _repo = NotificationsRepository.instance;

  Future<void> _init() async {
    var saved = await _repo.loadAll();

    if (saved.isEmpty) {
      final defaults = _buildStaticNotifications();
      await _repo.insertAll(defaults);
      saved = defaults;
    }

    if (mounted) state = saved;
  }

  static List<AppNotification> _buildStaticNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: _uuid.v4(),
        title: 'Chequeo preventivo recomendado',
        body: 'Es un buen momento para programar tu chequeo general anual con un médico de cabecera.',
        type: NotificationType.checkup,
        createdAt: now.subtract(const Duration(hours: 3)),
        routePath: '/appointments/create',
      ),
      AppNotification(
        id: _uuid.v4(),
        title: 'Consejo de salud',
        body: 'Recuerda mantenerte bien hidratado. Se recomiendan al menos 8 vasos de agua al día.',
        type: NotificationType.healthTip,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: _uuid.v4(),
        title: 'Bienvenido a Clínica Bello Horizonte',
        body: 'Puedes reservar citas, consultar tu historial médico y más desde la app.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  Future<void> addAppointmentReminders(List<AppointmentEntity> appointments) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final in3days = today.add(const Duration(days: 3));

    final newNotifications = <AppNotification>[];

    for (final apt in appointments) {
      if (apt.status == AppointmentStatus.cancelled ||
          apt.status == AppointmentStatus.completed) {
        continue;
      }

      final aptDate = DateTime(
        apt.appointmentDate.year,
        apt.appointmentDate.month,
        apt.appointmentDate.day,
      );

      final routePath = '/appointments/${apt.id}';
      final alreadyExists = await _repo.existsByRoutePath(routePath);
      if (alreadyExists) continue;

      AppNotification? n;
      if (aptDate == today) {
        n = AppNotification(
          id: _uuid.v4(),
          title: '¡Tienes una cita hoy!',
          body: 'Cita a las ${apt.appointmentTime}'
              '${apt.doctorName != null ? ' con Dr. ${apt.doctorName}' : ''}. ¡No olvides asistir!',
          type: NotificationType.appointmentToday,
          createdAt: now,
          routePath: routePath,
        );
      } else if (aptDate == tomorrow) {
        n = AppNotification(
          id: _uuid.v4(),
          title: 'Cita mañana',
          body: 'Recuerda que tienes cita mañana a las ${apt.appointmentTime}'
              '${apt.doctorName != null ? ' con Dr. ${apt.doctorName}' : ''}.',
          type: NotificationType.appointmentReminder,
          createdAt: now,
          routePath: routePath,
        );
      } else if (aptDate.isAfter(tomorrow) && !aptDate.isAfter(in3days)) {
        n = AppNotification(
          id: _uuid.v4(),
          title: 'Próxima cita en ${aptDate.difference(today).inDays} días',
          body: 'Tienes una cita el ${aptDate.day}/${aptDate.month} a las ${apt.appointmentTime}'
              '${apt.doctorName != null ? ' con Dr. ${apt.doctorName}' : ''}.',
          type: NotificationType.appointmentReminder,
          createdAt: now,
          routePath: routePath,
        );
      }

      if (n != null) newNotifications.add(n);
    }

    if (newNotifications.isNotEmpty) {
      await _repo.insertAll(newNotifications);
      if (mounted) state = [...newNotifications, ...state];
    }
  }

  Future<void> markRead(String id) async {
    await _repo.markRead(id);
    if (mounted) {
      state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    }
  }

  Future<void> markAllRead() async {
    await _repo.markAllRead();
    if (mounted) {
      state = state.map((n) => n.copyWith(isRead: true)).toList();
    }
  }

  Future<void> dismiss(String id) async {
    await _repo.delete(id);
    if (mounted) {
      state = state.where((n) => n.id != id).toList();
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  final notifier = NotificationsNotifier();

  ref.listen<AsyncValue<List<AppointmentEntity>>>(
    activeUpcomingAppointmentsProvider,
    (_, next) => next.whenData((apts) => notifier.addAppointmentReminders(apts)),
  );

  return notifier;
});

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
