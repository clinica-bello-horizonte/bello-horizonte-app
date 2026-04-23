import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  rescheduled;

  String get label => switch (this) {
        pending => 'Pendiente',
        confirmed => 'Confirmada',
        cancelled => 'Cancelada',
        completed => 'Completada',
        rescheduled => 'Reprogramada',
      };

  Color get color => switch (this) {
        pending => AppColors.statusPending,
        confirmed => AppColors.statusConfirmed,
        cancelled => AppColors.statusCancelled,
        completed => AppColors.statusCompleted,
        rescheduled => AppColors.statusRescheduled,
      };

  IconData get icon => switch (this) {
        pending => Icons.hourglass_empty_rounded,
        confirmed => Icons.check_circle_rounded,
        cancelled => Icons.cancel_rounded,
        completed => Icons.done_all_rounded,
        rescheduled => Icons.update_rounded,
      };
}

class AppointmentEntity extends Equatable {
  final String id;
  final String userId;
  final String doctorId;
  final String specialtyId;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final DateTime createdAt;

  // Joined data (from queries)
  final String? doctorName;
  final String? specialtyName;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.specialtyId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
    this.doctorName,
    this.specialtyName,
  });

  bool get isUpcoming =>
      appointmentDate.isAfter(DateTime.now()) ||
      (appointmentDate.day == DateTime.now().day &&
          appointmentDate.month == DateTime.now().month &&
          appointmentDate.year == DateTime.now().year);

  bool get isPast => !isUpcoming;
  bool get isCancellable => status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.rescheduled;
  bool get isReschedulable => isCancellable;

  AppointmentEntity copyWith({
    AppointmentStatus? status,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? notes,
  }) {
    return AppointmentEntity(
      id: id,
      userId: userId,
      doctorId: doctorId,
      specialtyId: specialtyId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
      reason: reason,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      doctorName: doctorName,
      specialtyName: specialtyName,
    );
  }

  @override
  List<Object?> get props => [id, status, appointmentDate, appointmentTime];
}
