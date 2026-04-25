import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentSuccessPage extends StatelessWidget {
  final AppointmentEntity appointment;
  const AppointmentSuccessPage({super.key, required this.appointment});

  static const _months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

  String get _formattedDate {
    final d = appointment.appointmentDate;
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Icono de éxito animado
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1FBF1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 60, color: Color(0xFF2E7D32)),
                ),
              ),
              const SizedBox(height: 24),
              Text('¡Cita reservada!', style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Tu cita ha sido registrada exitosamente.\nTe avisaremos el día anterior.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Tarjeta resumen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _row(Icons.person_rounded, appointment.doctorName ?? '—'),
                    _row(Icons.medical_services_outlined, appointment.specialtyName ?? '—'),
                    _row(Icons.calendar_today_rounded, _formattedDate),
                    _row(Icons.access_time_rounded, appointment.appointmentTime),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Ver mis citas',
                onPressed: () => context.go('/appointments'),
                trailingIcon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Ir al inicio',
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.whiteBody.copyWith(fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
