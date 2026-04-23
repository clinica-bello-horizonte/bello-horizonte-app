import '../entities/appointment_entity.dart';

abstract class AppointmentsRepository {
  Future<List<AppointmentEntity>> getAppointments(String userId);
  Future<List<AppointmentEntity>> getUpcomingAppointments(String userId);
  Future<AppointmentEntity?> getAppointmentById(String id);
  Future<AppointmentEntity> createAppointment(AppointmentEntity appointment);
  Future<void> cancelAppointment(String id);
  Future<void> rescheduleAppointment(String id, DateTime newDate, String newTime);
  Future<List<String>> getBookedSlots(String doctorId, DateTime date);
}
