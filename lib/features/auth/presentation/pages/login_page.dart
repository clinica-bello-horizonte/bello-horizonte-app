import 'package:flutter/material.dart';
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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authStateProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (!success && mounted) {
      final error = ref.read(authStateProvider).error;
      context.showErrorSnackBar(error ?? 'Error al iniciar sesión');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const AuthHeader(),
              const SizedBox(height: 40),
              Text('Bienvenido de vuelta', style: AppTextStyles.h1),
              const SizedBox(height: 6),
              Text(
                'Inicia sesión para acceder a tus citas y servicios',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'DNI o Correo electrónico',
                      hint: 'Ej: 12345678 o correo@email.com',
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textGray),
                      validator: (v) => AppValidators.validateRequired(v, fieldName: 'Este campo'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Contraseña',
                      hint: 'Tu contraseña',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textGray),
                      validator: AppValidators.validatePassword,
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: 'Iniciar sesión',
                      onPressed: _login,
                      isLoading: authState.isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              _DemoLoginButton(
                onTap: () {
                  _identifierController.text = 'demo@bellohorizonte.pe';
                  _passwordController.text = 'demo123';
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿No tienes cuenta? ',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      'Regístrate',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DemoLoginButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.infoLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.info.withAlpha(76)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.info),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo demostración',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.info, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Toca para rellenar datos de prueba',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.info),
          ],
        ),
      ),
    );
  }
}
