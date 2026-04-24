import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/presentation/providers/doctors_provider.dart';
import '../../../specialties/domain/entities/specialty_entity.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';
import '../providers/appointments_provider.dart';

class CreateAppointmentPage extends ConsumerStatefulWidget {
  final String? initialSpecialtyId;
  final String? initialDoctorId;

  /// When set, the wizard skips to step 2 and submits a reschedule instead of create.
  final String? rescheduleAppointmentId;

  const CreateAppointmentPage({
    super.key,
    this.initialSpecialtyId,
    this.initialDoctorId,
    this.rescheduleAppointmentId,
  });

  @override
  ConsumerState<CreateAppointmentPage> createState() =>
      _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends ConsumerState<CreateAppointmentPage> {
  int _step = 0;
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  SpecialtyEntity? _selectedSpecialty;
  DoctorEntity? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTime;

  bool get _isReschedule => widget.rescheduleAppointmentId != null;

  @override
  void initState() {
    super.initState();
    // Jump to date/time step immediately so the page never flashes step 0
    if (widget.rescheduleAppointmentId != null) {
      _step = 2;
    }
    if (widget.initialSpecialtyId != null || widget.initialDoctorId != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _preSelectFromParams());
    }
  }

  Future<void> _preSelectFromParams() async {
    final specialties = await ref.read(specialtiesProvider.future);
    final specialtyMatch = specialties
        .where((s) => s.id == widget.initialSpecialtyId)
        .firstOrNull;

    DoctorEntity? doctorMatch;
    if (widget.initialDoctorId != null) {
      doctorMatch =
          await ref.read(doctorByIdProvider(widget.initialDoctorId!).future);
    }

    if (!mounted) return;
    setState(() {
      if (specialtyMatch != null) _selectedSpecialty = specialtyMatch;
      if (doctorMatch != null) _selectedDoctor = doctorMatch;
      // Jump to date/time step if we already have both
      if (_selectedSpecialty != null && _selectedDoctor != null) {
        _step = 2;
      } else if (_selectedSpecialty != null) {
        _step = 1;
      }
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canProceed => switch (_step) {
        0 => _selectedSpecialty != null,
        1 => _selectedDoctor != null,
        2 => _selectedDate != null && _selectedTime != null,
        3 => _reasonController.text.trim().length >= 10,
        _ => false,
      };

  void _nextStep() {
    if (_canProceed && _step < 3) setState(() => _step++);
  }

  Future<void> _submit() async {
    if (!_canProceed) return;
    FocusScope.of(context).unfocus();

    final success =
        await ref.read(appointmentsNotifierProvider.notifier).createAppointment(
              doctorId: _selectedDoctor!.id,
              specialtyId: _selectedSpecialty!.id,
              date: _selectedDate!,
              time: _selectedTime!,
              reason: _reasonController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );

    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('¡Cita reservada exitosamente!');
        context.go('/appointments');
      } else {
        context.showErrorSnackBar('Error al reservar la cita. Intenta nuevamente.');
      }
    }
  }

  Future<void> _submitReschedule() async {
    if (_selectedDate == null || _selectedTime == null) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(appointmentsNotifierProvider.notifier)
        .rescheduleAppointment(
          widget.rescheduleAppointmentId!,
          _selectedDate!,
          _selectedTime!,
        );

    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('¡Cita reprogramada exitosamente!');
        context.go('/appointments');
      } else {
        context.showErrorSnackBar('Error al reprogramar la cita. Intenta nuevamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(appointmentsNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isReschedule ? 'Reprogramar Cita' : 'Nueva Cita'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildBottomBar(isLoading),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = _isReschedule
        ? const ['Fecha y hora', 'Listo']
        : const ['Especialidad', 'Médico', 'Fecha y hora', 'Motivo'];

    // Map real step index to indicator index when rescheduling
    final indicatorStep = _isReschedule ? _step - 2 : _step;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: _isReschedule
          ? Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: indicatorStep >= 0
                        ? (indicatorStep > 0 ? AppColors.success : AppColors.primary)
                        : AppColors.surfaceVariantLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: indicatorStep > 0
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : const Text('1',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona nueva fecha y hora',
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (_selectedDoctor != null)
                        Text(
                          _selectedDoctor!.fullName,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textGray),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: List.generate(steps.length, (i) {
                final isDone = i < indicatorStep;
                final isActive = i == indicatorStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.success
                                    : isActive
                                        ? AppColors.primary
                                        : AppColors.surfaceVariantLight,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(Icons.check_rounded,
                                        size: 16, color: Colors.white)
                                    : Text(
                                        '${i + 1}',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: isActive
                                              ? Colors.white
                                              : AppColors.textGray,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              steps[i],
                              style: AppTextStyles.caption.copyWith(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textGray,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (i < steps.length - 1)
                        Container(
                          height: 2,
                          width: 16,
                          color: i < indicatorStep
                              ? AppColors.success
                              : AppColors.divider,
                          margin: const EdgeInsets.only(bottom: 22),
                        ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildCurrentStep() {
    return switch (_step) {
      0 => _buildSpecialtyStep(),
      1 => _buildDoctorStep(),
      2 => _buildDateTimeStep(),
      3 => _buildReasonStep(),
      _ => const SizedBox(),
    };
  }

  Widget _buildSpecialtyStep() {
    final specialtiesAsync = ref.watch(specialtiesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Qué especialidad necesitas?', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text('Selecciona la especialidad médica',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textGray)),
        const SizedBox(height: 20),
        Expanded(
          child: specialtiesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (specialties) => GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: specialties.length,
              itemBuilder: (context, i) {
                final s = specialties[i];
                final isSelected = _selectedSpecialty?.id == s.id;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedSpecialty = s;
                    _selectedDoctor = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? s.color.withAlpha(38)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? s.color
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.iconData, color: s.color, size: 28),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            s.name,
                            style: AppTextStyles.labelMedium.copyWith(
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorStep() {
    final doctorsAsync =
        ref.watch(doctorsBySpecialtyProvider(_selectedSpecialty!.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selecciona tu médico', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(_selectedSpecialty!.name,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        Expanded(
          child: doctorsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (doctors) {
              if (doctors.isEmpty) {
                return const Center(
                    child: Text(
                        'No hay médicos disponibles para esta especialidad'));
              }
              return ListView.separated(
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final d = doctors[i];
                  final isSelected = _selectedDoctor?.id == d.id;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedDoctor = d;
                      _selectedDate = null;
                      _selectedTime = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                d.initials,
                                style: AppTextStyles.h4.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textGray),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.fullName,
                                    style: AppTextStyles.cardTitle),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 13,
                                        color: Color(0xFFFFC107)),
                                    const SizedBox(width: 3),
                                    Text('${d.rating}',
                                        style: AppTextStyles.caption
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 8),
                                    Text('${d.yearsExperience} años exp.',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                                Text(
                                    'S/ ${d.consultationFee.toStringAsFixed(0)} consulta',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    if (_isReschedule && _selectedDoctor == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fecha y hora', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            _isReschedule
                ? 'Elige la nueva fecha y hora para tu cita'
                : 'Selecciona cuándo quieres tu cita',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textGray),
          ),
          if (_isReschedule && _selectedDoctor != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _selectedDoctor!.fullName,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _buildDatePicker(),
          if (_selectedDate != null && _selectedDoctor != null) ...[
            const SizedBox(height: 20),
            _buildTimePicker(),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    return SizedBox(
      height: 200,
      child: CalendarDatePicker(
        initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
        firstDate: now.add(const Duration(days: 1)),
        lastDate: now.add(const Duration(days: 90)),
        onDateChanged: (date) {
          final weekday = date.weekday - 1;
          if (_selectedDoctor != null &&
              !_selectedDoctor!.isAvailableOn(weekday)) {
            context.showSnackBar('El médico no atiende este día. Elige otro.');
            return;
          }
          setState(() {
            _selectedDate = date;
            _selectedTime = null;
          });
        },
      ),
    );
  }

  Widget _buildTimePicker() {
    final bookedAsync = ref.watch(bookedSlotsProvider(
        (doctorId: _selectedDoctor!.id, date: _selectedDate!)));
    final bookedSlots = bookedAsync.valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hora disponible', style: AppTextStyles.h4),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.timeSlots.map((time) {
            final isBooked = bookedSlots.contains(time);
            final isSelected = _selectedTime == time;
            return GestureDetector(
              onTap: isBooked
                  ? null
                  : () => setState(() => _selectedTime = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isBooked
                      ? AppColors.surfaceVariantLight
                      : isSelected
                          ? AppColors.primary
                          : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isBooked
                        ? AppColors.border
                        : isSelected
                            ? AppColors.primary
                            : AppColors.border,
                  ),
                ),
                child: Text(
                  time,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isBooked
                        ? AppColors.textLight
                        : isSelected
                            ? Colors.white
                            : AppColors.textDark,
                    decoration:
                        isBooked ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Motivo de la consulta', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text('Describe brevemente el motivo de tu visita',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textGray)),
        const SizedBox(height: 20),
        _buildSummaryCard(),
        const SizedBox(height: 20),
        AppTextField(
          label: 'Motivo de consulta *',
          hint:
              'Ej: Dolor de cabeza persistente, chequeo general, revisión de presión...',
          controller: _reasonController,
          maxLines: 3,
          maxLength: 200,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Notas adicionales (opcional)',
          hint:
              'Alergias, medicamentos actuales, síntomas adicionales...',
          controller: _notesController,
          maxLines: 2,
          maxLength: 300,
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
              Icons.medical_services_outlined, _selectedSpecialty?.name ?? ''),
          _buildSummaryRow(
              Icons.person_rounded, _selectedDoctor?.fullName ?? ''),
          if (_selectedDate != null)
            _buildSummaryRow(
              Icons.calendar_today_rounded,
              '${_selectedDate!.day} ${months[_selectedDate!.month - 1]} ${_selectedDate!.year}',
            ),
          if (_selectedTime != null)
            _buildSummaryRow(Icons.access_time_rounded, _selectedTime!),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 10),
          Text(text,
              style: AppTextStyles.whiteBody
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isLoading) {
    // In reschedule mode: step 2 is the only step → confirm directly
    final isConfirmStep = _isReschedule ? _step == 2 : _step == 3;
    final confirmLabel =
        _isReschedule ? 'Confirmar reprogramación' : 'Confirmar cita';
    final showBack = _isReschedule ? false : _step > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border:
            Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          if (showBack)
            Expanded(
              flex: 1,
              child: AppButton(
                label: 'Atrás',
                variant: AppButtonVariant.outline,
                onPressed: () => setState(() => _step--),
                leadingIcon: Icons.arrow_back_rounded,
              ),
            ),
          if (showBack) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: AppButton(
              label: isConfirmStep ? confirmLabel : 'Continuar',
              onPressed: _canProceed
                  ? (isConfirmStep
                      ? (_isReschedule ? _submitReschedule : _submit)
                      : _nextStep)
                  : null,
              isLoading: isLoading,
              trailingIcon: isConfirmStep
                  ? Icons.check_rounded
                  : Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
