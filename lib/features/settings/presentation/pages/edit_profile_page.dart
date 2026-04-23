import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  String? _birthDate;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).user;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phone);
    _birthDate = user?.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authStateProvider.notifier).updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          birthDate: _birthDate,
        );

    if (mounted) {
      if (success) {
        context.showSuccessSnackBar('Perfil actualizado exitosamente');
        context.pop();
      } else {
        context.showErrorSnackBar('Error al actualizar el perfil');
      }
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime initial = DateTime(1990);
    if (_birthDate != null) {
      try { initial = DateTime.parse(_birthDate!); } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365)),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (picked != null) {
      setState(() {
        _birthDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final isLoading = ref.watch(authStateProvider).isLoading;
    final birthdateDisplay = _birthDate != null
        ? _birthDate!.split('-').reversed.join('/')
        : 'Seleccionar fecha';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // DNI & Email (readonly)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: AppColors.textGray, size: 18),
                        const SizedBox(width: 10),
                        Text('DNI: ${user?.dni ?? ''}', style: const TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, color: AppColors.textGray, size: 18),
                        const SizedBox(width: 10),
                        Text('${user?.email ?? ''}', style: const TextStyle(color: AppColors.textGray)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El DNI y correo no pueden ser modificados',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Nombres',
                controller: _firstNameController,
                textInputAction: TextInputAction.next,
                validator: (v) => AppValidators.validateName(v, fieldName: 'Los nombres'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Apellidos',
                controller: _lastNameController,
                textInputAction: TextInputAction.next,
                validator: (v) => AppValidators.validateName(v, fieldName: 'Los apellidos'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Teléfono',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textGray),
                validator: AppValidators.validatePhone,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha de nacimiento', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _selectBirthDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: AppColors.textGray, size: 20),
                          const SizedBox(width: 12),
                          Text(birthdateDisplay, style: TextStyle(color: _birthDate != null ? AppColors.textDark : AppColors.textLight)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Guardar cambios',
                onPressed: _save,
                isLoading: isLoading,
                leadingIcon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
