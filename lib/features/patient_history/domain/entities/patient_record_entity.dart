import 'package:equatable/equatable.dart';

class PatientRecordEntity extends Equatable {
  final String id;
  final String userId;
  final String? appointmentId;
  final String? diagnosis;
  final String? treatment;
  final String? notes;
  final DateTime recordDate;
  final String? doctorName;
  final String? specialtyName;
  final DateTime createdAt;

  const PatientRecordEntity({
    required this.id,
    required this.userId,
    this.appointmentId,
    this.diagnosis,
    this.treatment,
    this.notes,
    required this.recordDate,
    this.doctorName,
    this.specialtyName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, recordDate];
}
