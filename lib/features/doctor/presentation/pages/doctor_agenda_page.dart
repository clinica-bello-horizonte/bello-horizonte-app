import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../providers/doctor_provider.dart';

class DoctorAgendaPage extends ConsumerStatefulWidget {
  const DoctorAgendaPage({super.key});

  @override
  ConsumerState<DoctorAgendaPage> createState() => _DoctorAgendaPageState();
}

class _DoctorAgendaPageState extends ConsumerState<DoctorAgendaPage> {
  DateTime _selectedDate = DateTime.now();

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    final agendaAsync = ref.watch(doctorAgendaProvider(_dateStr));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: agendaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (appointments) => appointments.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _AppointmentDoctorCard(appointment: appointments[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE', 'es').format(_selectedDate).toUpperCase(),
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    DateFormat('d MMMM yyyy', 'es').format(_selectedDate),
                    style: AppTextStyles.h4,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => setState(
              () => _selectedDate = _selectedDate.add(const Duration(days: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 56, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text('Sin citas este día', style: AppTextStyles.h4.copyWith(color: AppColors.textGray)),
          ],
        ),
      );
}

class _AppointmentDoctorCard extends ConsumerStatefulWidget {
  final AppointmentEntity appointment;
  const _AppointmentDoctorCard({required this.appointment});

  @override
  ConsumerState<_AppointmentDoctorCard> createState() => _AppointmentDoctorCardState();
}

class _AppointmentDoctorCardState extends ConsumerState<_AppointmentDoctorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final apt = widget.appointment;
    final isLoading = ref.watch(doctorActionsProvider).isLoading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: apt.status.color.withAlpha(80)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(30),
              backgroundImage: apt.patientPhotoUrl != null
                  ? NetworkImage(apt.patientPhotoUrl!)
                  : null,
              child: apt.patientPhotoUrl == null
                  ? Text(
                      apt.patientName?.isNotEmpty == true
                          ? apt.patientName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(apt.patientName ?? 'Paciente', style: AppTextStyles.cardTitle),
            subtitle: Text(
              '${apt.appointmentTime} · ${apt.specialtyName ?? ''}',
              style: AppTextStyles.caption,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: apt.status.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    apt.status.label,
                    style: AppTextStyles.caption.copyWith(
                      color: apt.status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.textGray,
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (apt.reason != null) ...[
                    Text('Motivo:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray)),
                    const SizedBox(height: 4),
                    Text(apt.reason!, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 12),
                  ],
                  if (apt.patientPhone != null)
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 16, color: AppColors.textGray),
                        const SizedBox(width: 6),
                        Text(apt.patientPhone!, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  const SizedBox(height: 16),
                  _buildActions(apt, isLoading),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(AppointmentEntity apt, bool isLoading) {
    if (!apt.isCancellable && !apt.isCompletable) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (apt.status == AppointmentStatus.pending)
          AppButton(
            label: 'Confirmar',
            onPressed: isLoading ? null : () => _confirm(apt),
            isLoading: isLoading,
            trailingIcon: Icons.check_rounded,
          ),
        if (apt.isCompletable)
          AppButton(
            label: 'Completar',
            onPressed: isLoading ? null : () => _complete(apt),
            variant: AppButtonVariant.outline,
            trailingIcon: Icons.done_all_rounded,
          ),
        if (apt.isPostponable)
          AppButton(
            label: 'Postergar',
            onPressed: isLoading ? null : () => _postpone(apt),
            variant: AppButtonVariant.outline,
            trailingIcon: Icons.schedule_rounded,
          ),
        if (apt.isCancellable)
          AppButton(
            label: 'Cancelar',
            onPressed: isLoading ? null : () => _cancel(apt),
            variant: AppButtonVariant.outline,
            trailingIcon: Icons.cancel_rounded,
          ),
      ],
    );
  }

  Future<void> _confirm(AppointmentEntity apt) async {
    final success = await ref.read(doctorActionsProvider.notifier).confirmAppointment(apt.id);
    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('Cita confirmada');
        ref.invalidate(doctorAgendaProvider);
      } else {
        context.showErrorSnackBar('Error al confirmar la cita');
      }
    }
  }

  Future<void> _complete(AppointmentEntity apt) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Completar cita'),
        content: const Text('¿Marcar esta cita como completada?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Completar')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final success = await ref.read(doctorActionsProvider.notifier).completeAppointment(apt.id);
    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('Cita completada');
        ref.invalidate(doctorAgendaProvider);
      } else {
        context.showErrorSnackBar('Error al completar la cita');
      }
    }
  }

  Future<void> _cancel(AppointmentEntity apt) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Indica el motivo de cancelación:'),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Motivo',
              hint: 'Ej: Emergencia médica, reagendamiento...',
              controller: reasonController,
              maxLines: 2,
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
    if (confirmed != true || !mounted) return;

    if (reasonController.text.trim().length < 5) {
      context.showErrorSnackBar('El motivo debe tener al menos 5 caracteres');
      return;
    }

    final success = await ref
        .read(doctorActionsProvider.notifier)
        .cancelAppointment(apt.id, reasonController.text.trim());
    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('Cita cancelada. Se notificó al paciente.');
        ref.invalidate(doctorAgendaProvider);
      } else {
        context.showErrorSnackBar('Error al cancelar la cita');
      }
    }
  }

  Future<void> _postpone(AppointmentEntity apt) async {
    final reasonController = TextEditingController();
    DateTime? newDate;
    String? newTime;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Postergar cita'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Motivo de postergación',
                  hint: 'Ej: Reagendamiento por emergencia...',
                  controller: reasonController,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) setDialogState(() => newDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(newDate != null
                      ? DateFormat('d MMM yyyy', 'es').format(newDate!)
                      : 'Seleccionar nueva fecha'),
                ),
                if (newDate != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setDialogState(() => newTime =
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
                      }
                    },
                    icon: const Icon(Icons.access_time_rounded),
                    label: Text(newTime ?? 'Seleccionar nueva hora'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Volver')),
            TextButton(
              onPressed: newDate != null && newTime != null
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Postergar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted || newDate == null || newTime == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(newDate!);
    final success = await ref.read(doctorActionsProvider.notifier).postponeAppointment(
          apt.id,
          reasonController.text.trim(),
          dateStr,
          newTime!,
        );
    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('Cita postergada. Se notificó al paciente.');
        ref.invalidate(doctorAgendaProvider);
      } else {
        context.showErrorSnackBar('Error al postergar la cita');
      }
    }
  }
}
