import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
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
                if (appointment.cancelReason != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.cancel_rounded, 'Motivo de cancelación', appointment.cancelReason!, Colors.red),
                ],
                if (appointment.postponeReason != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.schedule_rounded, 'Motivo de postergación', appointment.postponeReason!, const Color(0xFFF59E0B)),
                  if (appointment.newDate != null)
                    _buildInfoRow(Icons.event_rounded, 'Nueva fecha', '${appointment.newDate} ${appointment.newTime ?? ''}', AppColors.primary),
                ],
                if (appointment.isRatable) ...[
                  const SizedBox(height: 24),
                  _RatingWidget(appointmentId: appointment.id, doctorId: appointment.doctorId),
                ],
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

  Widget _buildInfoRow(IconData icon, String label, String value, [Color? iconColor]) {
    final color = iconColor ?? AppColors.primary;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
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
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Por qué deseas cancelar esta cita?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Motivo de cancelación (obligatorio)...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar cita', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final reason = reasonController.text.trim();
    if (reason.length < 5) {
      context.showErrorSnackBar('El motivo debe tener al menos 5 caracteres');
      return;
    }

    final success = await ref
        .read(appointmentsNotifierProvider.notifier)
        .cancelAppointment(appointment.id, reason: reason);
    if (context.mounted) {
      if (success) {
        context.showSuccessSnackBar('Cita cancelada exitosamente');
        context.pop();
      } else {
        context.showErrorSnackBar('Error al cancelar. Recuerda que no puedes cancelar con menos de 2 horas de anticipación.');
      }
    }
  }
}

// ─── Rating Widget ────────────────────────────────────────────────────────────

final _ratingExistsProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, appointmentId) async {
  final api = ref.watch(apiClientProvider);
  final data = await api.get(ApiEndpoints.getAppointmentRating(appointmentId));
  return data != null;
});

class _RatingWidget extends ConsumerStatefulWidget {
  final String appointmentId;
  final String doctorId;
  const _RatingWidget({required this.appointmentId, required this.doctorId});

  @override
  ConsumerState<_RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends ConsumerState<_RatingWidget> {
  int _stars = 0;
  bool _submitted = false;
  bool _loading = false;

  Future<void> _submit() async {
    if (_stars == 0) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiClientProvider).post(
        ApiEndpoints.rateAppointment(widget.appointmentId),
        body: {'stars': _stars},
      );
      setState(() { _submitted = true; _loading = false; });
      if (mounted) context.showSuccessSnackBar('¡Gracias por tu calificación!');
    } catch (_) {
      setState(() => _loading = false);
      if (mounted) context.showErrorSnackBar('Error al enviar la calificación');
    }
  }

  @override
  Widget build(BuildContext context) {
    final existsAsync = ref.watch(_ratingExistsProvider(widget.appointmentId));

    return existsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (alreadyRated) {
        if (alreadyRated || _submitted) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Ya calificaste esta cita', style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Califica tu consulta', style: AppTextStyles.h4),
              const SizedBox(height: 4),
              Text('¿Cómo fue tu experiencia?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _stars = i + 1),
                  child: Icon(
                    i < _stars ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 36,
                    color: const Color(0xFFFFC107),
                  ),
                )),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _stars > 0 && !_loading ? _submit : null,
                  child: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar calificación'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
