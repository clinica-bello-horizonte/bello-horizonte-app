import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_datasource.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDatasource _datasource;

  AppointmentsRepositoryImpl(this._datasource);

  @override
  Future<List<AppointmentEntity>> getAppointments(String userId) =>
      _datasource.getAll();

  @override
  Future<List<AppointmentEntity>> getUpcomingAppointments(String userId) =>
      _datasource.getUpcoming();

  @override
  Future<AppointmentEntity?> getAppointmentById(String id) =>
      _datasource.getById(id);

  @override
  Future<AppointmentEntity> createAppointment(
      AppointmentEntity appointment) async {
    return _datasource.create(
      doctorId: appointment.doctorId,
      specialtyId: appointment.specialtyId,
      appointmentDate: DateFormatter.toDb(appointment.appointmentDate),
      appointmentTime: appointment.appointmentTime,
      reason: appointment.reason,
      notes: appointment.notes,
    );
  }

  @override
  Future<void> cancelAppointment(String id) => _datasource.cancel(id);

  @override
  Future<void> rescheduleAppointment(
      String id, DateTime newDate, String newTime) =>
      _datasource.reschedule(id, DateFormatter.toDb(newDate), newTime);

  @override
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) =>
      _datasource.getBookedSlots(doctorId, DateFormatter.toDb(date));
}
