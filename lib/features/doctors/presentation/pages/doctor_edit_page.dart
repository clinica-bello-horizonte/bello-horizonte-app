import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';
import '../../domain/entities/doctor_entity.dart';
import '../providers/doctors_provider.dart';

class DoctorEditPage extends ConsumerStatefulWidget {
  final String doctorId;
  const DoctorEditPage({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorEditPage> createState() => _DoctorEditPageState();
}

class _DoctorEditPageState extends ConsumerState<DoctorEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeController = TextEditingController();
  final _experienceController = TextEditingController();

  String? _selectedSpecialtyId;
  List<int> _selectedDays = [];
  bool _initialized = false;

  static const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _initFromDoctor(DoctorEntity doctor) {
    if (_initialized) return;
    _initialized = true;
    _firstNameController.text = doctor.firstName;
    _lastNameController.text = doctor.lastName;
    _descriptionController.text = doctor.description ?? '';
    _feeController.text = doctor.consultationFee.toStringAsFixed(0);
    _experienceController.text = doctor.yearsExperience.toString();
    _selectedSpecialtyId = doctor.specialtyId;
    _selectedDays = List.from(doctor.availableDays);
  }

  Future<void> _save(DoctorEntity original) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecialtyId == null) {
      context.showSnackBar('Selecciona una especialidad');
      return;
    }
    FocusScope.of(context).unfocus();

    final updated = DoctorEntity(
      id: original.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      specialtyId: _selectedSpecialtyId!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      photoUrl: original.photoUrl,
      rating: original.rating,
      yearsExperience:
          int.tryParse(_experienceController.text.trim()) ?? original.yearsExperience,
      consultationFee:
          double.tryParse(_feeController.text.trim()) ?? original.consultationFee,
      availableDays: _selectedDays,
      createdAt: original.createdAt,
    );

    final ok = await ref.read(doctorEditProvider.notifier).save(updated);
    if (mounted) {
      if (ok) {
        context.showSuccessSnackBar('Médico actualizado correctamente');
        context.pop();
      } else {
        final err = ref.read(doctorEditProvider).error ?? 'Error desconocido';
        context.showErrorSnackBar(err);
        ref.read(doctorEditProvider.notifier).reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorByIdProvider(widget.doctorId));
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final editState = ref.watch(doctorEditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar médico'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  'Solo admin',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: doctorAsync.when(
        loading: () => const FullScreenLoader(message: 'Cargando médico...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (doctor) {
          if (doctor == null) {
            return const Center(child: Text('Médico no encontrado'));
          }
          _initFromDoctor(doctor);

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Avatar header
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            doctor.initials,
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name section
                    Text('Datos personales', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Nombres *',
                      controller: _firstNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Apellidos *',
                      controller: _lastNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 20),

                    // Specialty
                    Text('Especialidad *', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    specialtiesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) =>
                          const Text('Error al cargar especialidades'),
                      data: (specialties) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: specialties.map((s) {
                          final selected = _selectedSpecialtyId == s.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedSpecialtyId = s.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? s.color.withAlpha(25)
                                    : Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? s.color : AppColors.border,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(s.iconData,
                                      color: selected
                                          ? s.color
                                          : AppColors.textGray,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    s.name,
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: selected
                                          ? s.color
                                          : AppColors.textGray,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Professional info
                    Text('Información profesional', style: AppTextStyles.h4),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Años de experiencia',
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Tarifa (S/)',
                            controller: _feeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Descripción',
                      hint: 'Especialista en...',
                      controller: _descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Schedule
                    Text('Horarios de atención', style: AppTextStyles.h4),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona los días que atiende el médico',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (i) {
                        final selected = _selectedDays.contains(i);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _selectedDays.remove(i);
                            } else {
                              _selectedDays.add(i);
                              _selectedDays.sort();
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _dayNames[i],
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textGray,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Guardar cambios',
                      isLoading: editState.isLoading,
                      onPressed: () => _save(doctor),
                      leadingIcon: Icons.save_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (editState.isLoading)
                const FullScreenLoader(message: 'Guardando...'),
            ],
          );
        },
      ),
    );
  }
}
