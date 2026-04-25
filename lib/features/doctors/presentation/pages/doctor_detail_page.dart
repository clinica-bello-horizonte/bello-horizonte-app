import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../../appointments/presentation/providers/ratings_provider.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

        final currentUser = ref.watch(authStateProvider).user;
        final isAdmin = currentUser?.role == UserRole.admin;
        final isOwnProfile = currentUser?.role == UserRole.doctor &&
            doctor.userId != null &&
            doctor.userId == currentUser?.id;

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
                actions: [
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                      tooltip: 'Editar médico',
                      onPressed: () => context.push('/doctors/${doctor.id}/edit'),
                    ),
                  if (isOwnProfile)
                    IconButton(
                      icon: const Icon(Icons.manage_accounts_rounded, color: Colors.white),
                      tooltip: 'Editar mi perfil',
                      onPressed: () => context.push('/doctor/profile/edit'),
                    ),
                ],
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
                            color: Colors.white.withAlpha(51),
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

                      // Próximas fechas disponibles
                      Text('Próximas fechas disponibles', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      _NextAvailableDates(doctor: doctor),
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
                      _DoctorReviewsSection(doctorId: doctor.id),
                      const SizedBox(height: 24),
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
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(51)),
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

// ─── Próximas fechas disponibles ─────────────────────────────────────────────

class _NextAvailableDates extends ConsumerWidget {
  final dynamic doctor;
  const _NextAvailableDates({required this.doctor});

  List<DateTime> _getNextDates() {
    final now = DateTime.now();
    final List<DateTime> dates = [];
    var day = now.add(const Duration(days: 1));
    while (dates.length < 5) {
      // availableDays usa 1=Lun…6=Sab, DateTime.weekday usa 1=Lun…7=Dom
      final weekday = day.weekday; // 1-7
      if ((doctor.availableDays as List<int>).contains(weekday)) {
        dates.add(day);
      }
      day = day.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dates = _getNextDates();

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          final date = dates[i];
          final bookedAsync = ref.watch(
            bookedSlotsProvider((doctorId: doctor.id, date: date)),
          );
          final booked = bookedAsync.valueOrNull ?? [];
          final freeSlots = AppConstants.timeSlots.length - booked.length;

          return GestureDetector(
            onTap: () => context.push(
              '/appointments/create',
              extra: {'specialtyId': doctor.specialtyId, 'doctorId': doctor.id},
            ),
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: freeSlots > 0
                    ? AppColors.primaryContainer
                    : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: freeSlots > 0 ? AppColors.primary.withAlpha(80) : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'es').format(date),
                    style: AppTextStyles.caption.copyWith(
                      color: freeSlots > 0 ? AppColors.primary : AppColors.textGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('d MMM', 'es').format(date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: freeSlots > 0 ? AppColors.textDark : AppColors.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    freeSlots > 0 ? '$freeSlots libres' : 'Lleno',
                    style: AppTextStyles.caption.copyWith(
                      color: freeSlots > 0 ? AppColors.success : AppColors.error,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Reseñas del médico ───────────────────────────────────────────────────────

class _DoctorReviewsSection extends ConsumerWidget {
  final String doctorId;
  const _DoctorReviewsSection({required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsAsync = ref.watch(doctorRatingsProvider(doctorId));

    return ratingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (ratings) {
        if (ratings.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reseñas de pacientes', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            ...ratings.take(5).map((r) {
              final stars = r['stars'] as int? ?? 0;
              final comment = r['comment'] as String?;
              final specialty = (r['appointment']?['specialty']?['name']) as String?;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 16, color: const Color(0xFFFFC107),
                        )),
                        const Spacer(),
                        if (specialty != null)
                          Text(specialty, style: AppTextStyles.caption.copyWith(color: AppColors.textGray)),
                      ],
                    ),
                    if (comment != null && comment.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(comment, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
                    ],
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
