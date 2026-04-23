import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _birthDate;

  @override
  void dispose() {
    _dniController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authStateProvider.notifier).register(
          dni: _dniController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          password: _passwordController.text,
          birthDate: _birthDate,
        );

    if (!success && mounted) {
      final error = ref.read(authStateProvider).error;
      context.showErrorSnackBar(error ?? 'Error al registrarse');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final birthdateDisplay = _birthDate != null
        ? _birthDate!.split('-').reversed.join('/')
        : 'Seleccionar fecha';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(compact: true),
            const SizedBox(height: 24),
            Text('Crear cuenta', style: AppTextStyles.h1),
            const SizedBox(height: 6),
            Text(
              'Completa tus datos para registrarte',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSectionLabel('Información personal'),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'DNI',
                    hint: '12345678',
                    controller: _dniController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textGray),
                    validator: AppValidators.validateDni,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Nombres',
                          hint: 'Ej: Juan Carlos',
                          controller: _firstNameController,
                          textInputAction: TextInputAction.next,
                          validator: (v) => AppValidators.validateName(v, fieldName: 'Los nombres'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Apellidos',
                          hint: 'Ej: García López',
                          controller: _lastNameController,
                          textInputAction: TextInputAction.next,
                          validator: (v) => AppValidators.validateName(v, fieldName: 'Los apellidos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha de nacimiento', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w500)),
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
                              Text(
                                birthdateDisplay,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: _birthDate != null ? AppColors.textDark : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Contacto'),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Correo electrónico',
                    hint: 'correo@ejemplo.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textGray),
                    validator: AppValidators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Teléfono',
                    hint: '999 888 777',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textGray),
                    validator: AppValidators.validatePhone,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Seguridad'),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Contraseña',
                    hint: 'Mínimo 6 caracteres',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textGray),
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Confirmar contraseña',
                    hint: 'Repite tu contraseña',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textGray),
                    validator: (v) => AppValidators.validateConfirmPassword(v, _passwordController.text),
                    onSubmitted: (_) => _register(),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Crear cuenta',
                    onPressed: _register,
                    isLoading: authState.isLoading,
                    leadingIcon: Icons.person_add_outlined,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Iniciar sesión',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.h4.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}
