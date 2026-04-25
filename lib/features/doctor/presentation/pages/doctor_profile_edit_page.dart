import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

final _doctorProfileEditLoadingProvider = StateProvider<bool>((ref) => false);

class DoctorProfileEditPage extends ConsumerStatefulWidget {
  const DoctorProfileEditPage({super.key});

  @override
  ConsumerState<DoctorProfileEditPage> createState() =>
      _DoctorProfileEditPageState();
}

class _DoctorProfileEditPageState
    extends ConsumerState<DoctorProfileEditPage> {
  final _descriptionCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<int> _availableDays = [];
  bool _loaded = false;

  static const _dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _feeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ref.read(apiClientProvider).get(ApiEndpoints.doctorProfile)
          as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _descriptionCtrl.text = data['description'] as String? ?? '';
        _feeCtrl.text =
            (data['consultationFee'] as num?)?.toStringAsFixed(0) ?? '';
        final days = (data['availableDays'] as List?)
                ?.map((d) => (d as num).toInt())
                .toList() ??
            [];
        _availableDays = days;

        final user = data['user'] as Map<String, dynamic>?;
        _phoneCtrl.text = user?['phone'] as String? ?? '';
        _loaded = true;
      });
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al cargar perfil: $e');
    }
  }

  Future<void> _save() async {
    if (_feeCtrl.text.trim().isEmpty || _availableDays.isEmpty) {
      context.showErrorSnackBar('Completa tarifa y al menos un día disponible');
      return;
    }
    ref.read(_doctorProfileEditLoadingProvider.notifier).state = true;
    try {
      await ref.read(apiClientProvider).patch(
        ApiEndpoints.doctorProfile,
        body: {
          'description': _descriptionCtrl.text.trim(),
          'consultationFee': double.tryParse(_feeCtrl.text.trim()) ?? 0,
          'availableDays': _availableDays,
          if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        },
      );
      if (mounted) {
        context.showSuccessSnackBar('Perfil actualizado');
        context.pop();
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Error al guardar: $e');
    } finally {
      if (mounted) {
        ref.read(_doctorProfileEditLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_doctorProfileEditLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar mi perfil médico')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Descripción profesional', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: 'Descripción',
                    hint: 'Especialidad, experiencia, enfoque clínico...',
                    controller: _descriptionCtrl,
                    maxLines: 4,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 20),
                  Text('Tarifa de consulta (S/)', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: 'Tarifa',
                    hint: 'Ej: 120',
                    controller: _feeCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Text('Teléfono de contacto', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: 'Teléfono',
                    hint: 'Ej: 987654321',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Text('Días de atención', style: AppTextStyles.h4),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (i) {
                      final selected = _availableDays.contains(i);
                      return FilterChip(
                        label: Text(_dayNames[i]),
                        selected: selected,
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: AppColors.primary,
                        onSelected: (_) => setState(() {
                          if (selected) {
                            _availableDays.remove(i);
                          } else {
                            _availableDays = [..._availableDays, i]..sort();
                          }
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  SafeArea(
                    top: false,
                    child: AppButton(
                      label: 'Guardar cambios',
                      onPressed: isLoading ? null : _save,
                      isLoading: isLoading,
                      trailingIcon: Icons.save_rounded,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
