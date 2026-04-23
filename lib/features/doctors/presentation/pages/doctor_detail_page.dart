import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';
import '../providers/doctors_provider.dart';

class DoctorDetailPage extends ConsumerWidget {
  final String doctorId;
  const DoctorDetailPage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorByIdProvider(doctorId));
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return doctorAsync.when(
      loading: () => const Scaffold(body: FullScreenLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (doctor) {
        if (doctor == null) {
          return const Scaffold(body: Center(child: Text('Médico no encontrado')));
        }

        final specialty = specialtiesAsync.valueOrNull?.where((s) => s.id == doctor.specialtyId).firstOrNull;
        const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              doctor.initials,
                              style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(doctor.fullName, style: AppTextStyles.whiteTitle),
                        if (specialty != null)
                          Text(specialty.name, style: AppTextStyles.whiteBody),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats row
                      Row(
                        children: [
                          Expanded(child: _buildStat(Icons.star_rounded, '${doctor.rating}', 'Calificación', const Color(0xFFFFC107))),
                          Expanded(child: _buildStat(Icons.work_outline, '${doctor.yearsExperience}', 'Años de exp.', AppColors.secondary)),
                          Expanded(child: _buildStat(Icons.monetization_on_outlined, 'S/ ${doctor.consultationFee.toStringAsFixed(0)}', 'Consulta', AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // About
                      Text('Sobre el médico', style: AppTextStyles.h3),
                      const SizedBox(height: 10),
                      Text(
                        doctor.description ?? 'Médico especialista con amplia experiencia en su área.',
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
                      ),
                      const SizedBox(height: 24),

                      // Schedule
                      Text('Días de atención', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(7, (i) {
                          final isAvailable = doctor.availableDays.contains(i);
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isAvailable ? AppColors.primary : AppColors.surfaceVariantLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    dayNames[i],
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isAvailable ? Colors.white : AppColors.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (isAvailable) ...[
                                    const SizedBox(height: 4),
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textGray),
                          const SizedBox(width: 6),
                          Text('Horario: 08:00 - 18:30', style: AppTextStyles.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'Reservar cita con este médico',
                        onPressed: () => context.push(
                          '/appointments/create',
                          extra: {
                            'specialtyId': doctor.specialtyId,
                            'doctorId': doctor.id,
                          },
                        ),
                        leadingIcon: Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.h4.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
