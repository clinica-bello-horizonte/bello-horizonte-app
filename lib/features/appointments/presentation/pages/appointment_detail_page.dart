import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/appointment_entity.dart';
import '../providers/appointments_provider.dart';

class AppointmentDetailPage extends ConsumerWidget {
  final String appointmentId;
  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(appointmentByIdProvider(appointmentId));

    return appointmentAsync.when(
      loading: () => const Scaffold(body: FullScreenLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (appointment) {
        if (appointment == null) {
          return const Scaffold(body: Center(child: Text('Cita no encontrada')));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Cita'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(appointment),
                const SizedBox(height: 24),
                _buildInfoCard(context, appointment),
                const SizedBox(height: 16),
                if (appointment.reason != null) _buildReasonCard(appointment),
                const SizedBox(height: 24),
                if (appointment.isCancellable) ...[
                  AppButton(
                    label: 'Cancelar cita',
                    variant: AppButtonVariant.danger,
                    leadingIcon: Icons.cancel_outlined,
                    onPressed: () => _cancelAppointment(context, ref, appointment),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Reprogramar cita',
                    variant: AppButtonVariant.outline,
                    leadingIcon: Icons.update_rounded,
                    onPressed: () => context.push(
                      '/appointments/create',
                      extra: {
                        'specialtyId': appointment.specialtyId,
                        'doctorId': appointment.doctorId,
                        'rescheduleId': appointment.id,
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusHeader(AppointmentEntity appointment) {
    final status = appointment.status;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: status.color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withAlpha(76)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: status.color.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(status.icon, color: status.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.label, style: AppTextStyles.h3.copyWith(color: status.color)),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.toDayMonthYear(appointment.appointmentDate),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                ),
                Text(
                  'a las ${appointment.appointmentTime}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, AppointmentEntity appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_rounded, 'Médico', appointment.doctorName != null ? 'Dr. ${appointment.doctorName}' : 'Médico'),
          const Divider(height: 20),
          _buildInfoRow(Icons.medical_services_rounded, 'Especialidad', appointment.specialtyName ?? 'Especialidad'),
          const Divider(height: 20),
          _buildInfoRow(Icons.calendar_today_rounded, 'Fecha', DateFormatter.toDayMonthYear(appointment.appointmentDate)),
          const Divider(height: 20),
          _buildInfoRow(Icons.access_time_rounded, 'Hora', appointment.appointmentTime),
          const Divider(height: 20),
          _buildInfoRow(Icons.confirmation_number_rounded, 'ID de cita', '#${appointment.id.substring(0, 8).toUpperCase()}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.cardTitle),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonCard(AppointmentEntity appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text('Motivo de consulta', style: AppTextStyles.labelLarge.copyWith(color: AppColors.info)),
            ],
          ),
          const SizedBox(height: 8),
          Text(appointment.reason!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
          if (appointment.notes != null) ...[
            const SizedBox(height: 10),
            Text('Notas: ${appointment.notes}', style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelAppointment(BuildContext context, WidgetRef ref, AppointmentEntity appointment) async {
    final confirm = await context.showConfirmDialog(
      title: 'Cancelar cita',
      message: '¿Estás seguro de que deseas cancelar esta cita? Esta acción no se puede deshacer.',
      confirmText: 'Cancelar cita',
      cancelText: 'No, mantener',
      isDangerous: true,
    );

    if (confirm == true) {
      final success = await ref.read(appointmentsNotifierProvider.notifier).cancelAppointment(appointment.id);
      if (context.mounted) {
        if (success) {
          context.showSuccessSnackBar('Cita cancelada exitosamente');
          context.pop();
        } else {
          context.showErrorSnackBar('Error al cancelar la cita');
        }
      }
    }
  }
}
