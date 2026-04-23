import '../../domain/entities/patient_record_entity.dart';

class PatientRecordModel extends PatientRecordEntity {
  const PatientRecordModel({
    required super.id,
    required super.userId,
    super.appointmentId,
    super.diagnosis,
    super.treatment,
    super.notes,
    required super.recordDate,
    super.doctorName,
    super.specialtyName,
    required super.createdAt,
  });

  factory PatientRecordModel.fromJson(Map<String, dynamic> json) {
    return PatientRecordModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      appointmentId: json['appointmentId'] as String?,
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      recordDate: DateTime.parse(json['recordDate'] as String),
      doctorName: json['doctorName'] as String?,
      specialtyName: json['specialtyName'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  factory PatientRecordModel.fromMap(Map<String, dynamic> map) {
    return PatientRecordModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      appointmentId: map['appointment_id'] as String?,
      diagnosis: map['diagnosis'] as String?,
      treatment: map['treatment'] as String?,
      notes: map['notes'] as String?,
      recordDate: DateTime.parse(map['record_date'] as String),
      doctorName: map['doctor_name'] as String?,
      specialtyName: map['specialty_name'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'appointment_id': appointmentId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'record_date': recordDate.toIso8601String().split('T').first,
      'doctor_name': doctorName,
      'specialty_name': specialtyName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
