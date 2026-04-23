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

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authStateProvider.notifier).resetPassword(
          identifier: _identifierController.text.trim(),
        );

    if (mounted) {
      if (success) {
        setState(() => _emailSent = true);
      } else {
        final error = ref.read(authStateProvider).error;
        context.showErrorSnackBar(error ?? 'Error al procesar la solicitud');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessState() : _buildFormState(isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text('¿Olvidaste tu contraseña?', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu DNI o correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'DNI o Correo electrónico',
                hint: '12345678 o correo@email.com',
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.person_search_outlined, color: AppColors.textGray),
                validator: (v) => AppValidators.validateRequired(v, fieldName: 'Este campo'),
                onSubmitted: (_) => _sendReset(),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Enviar instrucciones',
                onPressed: _sendReset,
                isLoading: isLoading,
                leadingIcon: Icons.send_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Volver al inicio de sesión'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 50, color: AppColors.success),
        ),
        const SizedBox(height: 28),
        Text('¡Instrucciones enviadas!', style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'Revisa tu correo electrónico o mensaje de texto.\n\nEn un entorno local, la contraseña puede ser restablecida directamente en la app.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        AppButton(
          label: 'Volver al inicio de sesión',
          onPressed: () => context.go('/login'),
          leadingIcon: Icons.arrow_back_rounded,
        ),
      ],
    );
  }
}
