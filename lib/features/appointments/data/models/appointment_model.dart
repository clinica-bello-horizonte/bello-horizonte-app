import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.doctorId,
    required super.specialtyId,
    required super.appointmentDate,
    required super.appointmentTime,
    required super.status,
    super.reason,
    super.notes,
    required super.createdAt,
    super.doctorName,
    super.specialtyName,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>?;
    final specialty = json['specialty'] as Map<String, dynamic>?;
    final doctorName = doctor != null
        ? '${doctor['firstName']} ${doctor['lastName']}'
        : null;
    final statusStr =
        (json['status'] as String? ?? 'PENDING').toLowerCase();
    return AppointmentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      doctorId: json['doctorId'] as String,
      specialtyId: json['specialtyId'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == statusStr,
        orElse: () => AppointmentStatus.pending,
      ),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      doctorName: doctorName,
      specialtyName: specialty?['name'] as String?,
    );
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      doctorId: map['doctor_id'] as String,
      specialtyId: map['specialty_id'] as String,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      appointmentTime: map['appointment_time'] as String,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == (map['status'] as String),
        orElse: () => AppointmentStatus.pending,
      ),
      reason: map['reason'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      doctorName: map['doctor_name'] as String?,
      specialtyName: map['specialty_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'doctor_id': doctorId,
      'specialty_id': specialtyId,
      'appointment_date': appointmentDate.toIso8601String().split('T').first,
      'appointment_time': appointmentTime,
      'status': status.name,
      'reason': reason,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
