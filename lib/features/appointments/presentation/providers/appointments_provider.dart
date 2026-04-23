import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/appointments_remote_datasource.dart';
import '../../data/repositories/appointments_repository_impl.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return AppointmentsRepositoryImpl(AppointmentsRemoteDatasource(api));
});

// All appointments for current user
final appointmentsProvider = FutureProvider<List<AppointmentEntity>>((ref) async {
  final userId = ref.watch(authStateProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(appointmentsRepositoryProvider).getAppointments(userId);
});

// Upcoming appointments for current user (backend: pending/confirmed only)
final upcomingAppointmentsProvider = FutureProvider<List<AppointmentEntity>>((ref) async {
  final userId = ref.watch(authStateProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(appointmentsRepositoryProvider).getUpcomingAppointments(userId);
});

// Active upcoming appointments — includes rescheduled, for home page display
final activeUpcomingAppointmentsProvider = FutureProvider<List<AppointmentEntity>>((ref) async {
  final all = await ref.watch(appointmentsProvider.future);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return all
      .where((a) =>
          a.status != AppointmentStatus.cancelled &&
          a.status != AppointmentStatus.completed &&
          !DateTime(a.appointmentDate.year, a.appointmentDate.month, a.appointmentDate.day)
              .isBefore(today))
      .toList()
    ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
});

// Single appointment
final appointmentByIdProvider = FutureProvider.family<AppointmentEntity?, String>((ref, id) async {
  return ref.watch(appointmentsRepositoryProvider).getAppointmentById(id);
});

// Booked slots for a doctor on a date
final bookedSlotsProvider = FutureProvider.family<List<String>, ({String doctorId, DateTime date})>((ref, args) async {
  return ref.watch(appointmentsRepositoryProvider).getBookedSlots(args.doctorId, args.date);
});

// Appointments notifier for mutations
class AppointmentsNotifier extends StateNotifier<AsyncValue<void>> {
  final AppointmentsRepository _repo;
  final Ref _ref;

  AppointmentsNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<bool> createAppointment({
    required String doctorId,
    required String specialtyId,
    required DateTime date,
    required String time,
    required String reason,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      final userId = _ref.read(authStateProvider).user?.id;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _repo.createAppointment(AppointmentEntity(
        id: '',
        userId: userId,
        doctorId: doctorId,
        specialtyId: specialtyId,
        appointmentDate: date,
        appointmentTime: time,
        status: AppointmentStatus.confirmed,
        reason: reason,
        notes: notes,
        createdAt: DateTime.now(),
      ));

      state = const AsyncData(null);
      _ref.invalidate(appointmentsProvider);
      _ref.invalidate(upcomingAppointmentsProvider);
      return true;
    } catch (e, s) {
      state = AsyncError(e, s);
      return false;
    }
  }

  Future<bool> cancelAppointment(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.cancelAppointment(id);
      state = const AsyncData(null);
      _ref.invalidate(appointmentsProvider);
      _ref.invalidate(upcomingAppointmentsProvider);
      _ref.invalidate(appointmentByIdProvider(id));
      return true;
    } catch (e, s) {
      state = AsyncError(e, s);
      return false;
    }
  }

  Future<bool> rescheduleAppointment(String id, DateTime newDate, String newTime) async {
    state = const AsyncLoading();
    try {
      await _repo.rescheduleAppointment(id, newDate, newTime);
      state = const AsyncData(null);
      _ref.invalidate(appointmentsProvider);
      _ref.invalidate(upcomingAppointmentsProvider);
      _ref.invalidate(appointmentByIdProvider(id));
      return true;
    } catch (e, s) {
      state = AsyncError(e, s);
      return false;
    }
  }
}

final appointmentsNotifierProvider = StateNotifierProvider<AppointmentsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(appointmentsRepositoryProvider);
  return AppointmentsNotifier(repo, ref);
});
