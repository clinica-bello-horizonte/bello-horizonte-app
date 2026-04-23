import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../doctors/presentation/providers/doctors_provider.dart';
import '../../../doctors/presentation/widgets/doctor_card.dart';
import '../providers/specialties_provider.dart';

class SpecialtyDetailPage extends ConsumerWidget {
  final String specialtyId;
  const SpecialtyDetailPage({super.key, required this.specialtyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtyAsync = ref.watch(specialtyByIdProvider(specialtyId));
    final doctorsAsync = ref.watch(doctorsBySpecialtyProvider(specialtyId));

    return specialtyAsync.when(
      loading: () => const Scaffold(body: FullScreenLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (specialty) {
        if (specialty == null) return const Scaffold(body: Center(child: Text('Especialidad no encontrada')));

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: specialty.color,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    specialty.name,
                    style: AppTextStyles.whiteTitle.copyWith(fontSize: 16),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [specialty.color, specialty.color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(specialty.iconData, size: 80, color: Colors.white.withOpacity(0.3)),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: specialty.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: specialty.color.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(specialty.iconData, color: specialty.color, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                specialty.description ?? 'Especialidad médica de Clínica Bello Horizonte.',
                                style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text('Médicos especialistas', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Reconocidos médicos más cerca de ti',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              doctorsAsync.when(
                loading: () => const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: FullScreenLoader())),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
                data: (doctors) {
                  if (doctors.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(child: Text('No hay médicos disponibles para esta especialidad')),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DoctorCard(
                            doctor: doctors[index],
                            onTap: () => context.push('/doctors/${doctors[index].id}'),
                          ),
                        ),
                        childCount: doctors.length,
                      ),
                    ),
                  );
                },
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: AppButton(
                    label: 'Reservar cita',
                    onPressed: () => context.push(
                      '/appointments/create',
                      extra: {'specialtyId': specialtyId},
                    ),
                    leadingIcon: Icons.calendar_today_rounded,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
