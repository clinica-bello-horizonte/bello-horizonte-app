import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/appointment_model.dart';

class AppointmentsRemoteDatasource {
  final ApiClient _api;
  AppointmentsRemoteDatasource(this._api);

  Future<List<AppointmentModel>> getAll() async {
    final data = await _api.get(ApiEndpoints.appointments) as List;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppointmentModel>> getUpcoming() async {
    final data = await _api.get(ApiEndpoints.upcomingAppointments) as List;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel?> getById(String id) async {
    try {
      final data = await _api.get(ApiEndpoints.appointmentById(id))
          as Map<String, dynamic>;
      return AppointmentModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<AppointmentModel> create({
    required String doctorId,
    required String specialtyId,
    required String appointmentDate,
    required String appointmentTime,
    String? reason,
    String? notes,
  }) async {
    final data = await _api.post(ApiEndpoints.appointments, body: {
      'doctorId': doctorId,
      'specialtyId': specialtyId,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
    }) as Map<String, dynamic>;
    return AppointmentModel.fromJson(data);
  }

  Future<void> cancel(String id) async {
    await _api.patch(ApiEndpoints.cancelAppointment(id));
  }

  Future<void> reschedule(
    String id,
    String newDate,
    String newTime,
  ) async {
    await _api.patch(ApiEndpoints.rescheduleAppointment(id), body: {
      'appointmentDate': newDate,
      'appointmentTime': newTime,
    });
  }

  Future<List<String>> getBookedSlots(String doctorId, String date) async {
    final data = await _api.get(
      ApiEndpoints.bookedSlots,
      queryParameters: {'doctorId': doctorId, 'date': date},
    ) as List;
    return data.cast<String>();
  }
}
