import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

// ─── Agenda del médico ───────────────────────────────────────────────────────

final doctorAgendaProvider = FutureProvider.autoDispose
    .family<List<AppointmentEntity>, String?>((ref, date) async {
  final api = ref.watch(apiClientProvider);
  final params = <String, dynamic>{};
  if (date != null) params['date'] = date;

  final data = await api.get(ApiEndpoints.doctorAgenda, queryParameters: params);
  if (data == null) return [];
  return (data as List).map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
});

// ─── Acciones del médico ─────────────────────────────────────────────────────

class DoctorActionsNotifier extends StateNotifier<AsyncValue<void>> {
  DoctorActionsNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> confirmAppointment(String id, {String? notes}) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiClientProvider).patch(
        '${ApiEndpoints.doctorAppointments}/$id/confirm',
        body: notes != null ? {'notes': notes} : {},
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> cancelAppointment(String id, String reason) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiClientProvider).patch(
        '${ApiEndpoints.doctorAppointments}/$id/cancel',
        body: {'reason': reason},
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> postponeAppointment(
    String id,
    String reason,
    String newDate,
    String newTime,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiClientProvider).patch(
        '${ApiEndpoints.doctorAppointments}/$id/postpone',
        body: {'reason': reason, 'newDate': newDate, 'newTime': newTime},
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> completeAppointment(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(apiClientProvider).patch(
        '${ApiEndpoints.doctorAppointments}/$id/complete',
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final doctorActionsProvider =
    StateNotifierProvider<DoctorActionsNotifier, AsyncValue<void>>(
  (ref) => DoctorActionsNotifier(ref),
);
