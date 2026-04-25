import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/role_guard.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';
import '../providers/doctors_provider.dart';
import '../widgets/doctor_card.dart';

class DoctorsPage extends ConsumerStatefulWidget {
  const DoctorsPage({super.key});

  @override
  ConsumerState<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends ConsumerState<DoctorsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(doctorSearchProvider);
    final doctorsAsync = ref.watch(filteredDoctorsProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Nuestros Médicos'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  ref.read(doctorSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Buscar médico...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textGray),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(doctorSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Admin banner
          RoleGuard(
            requiredRole: UserRole.admin,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_rounded,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Modo administrador: puedes editar la información de los médicos.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Doctors list
          Expanded(
            child: doctorsAsync.when(
              loading: () => buildSkeletonList(itemBuilder: () => const DoctorCardSkeleton()),
              error: (e, _) => ErrorStateWidget(message: e.toString()),
              data: (doctors) {
                if (doctors.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.person_search_rounded,
                    title: searchQuery.isNotEmpty ? 'Sin resultados' : 'Sin médicos',
                    subtitle: searchQuery.isNotEmpty
                        ? 'No encontramos médicos con ese nombre'
                        : 'No hay médicos disponibles',
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return specialtiesAsync.when(
                      data: (specialties) {
                        final specialty = specialties
                            .where((s) => s.id == doctor.specialtyId)
                            .firstOrNull;
                        return _DoctorListItem(
                          doctor: doctor,
                          specialtyName: specialty?.name,
                          onTap: () =>
                              context.push('/doctors/${doctor.id}'),
                          onEdit: () =>
                              context.push('/doctors/${doctor.id}/edit'),
                        );
                      },
                      loading: () => _DoctorListItem(
                        doctor: doctor,
                        onTap: () => context.push('/doctors/${doctor.id}'),
                        onEdit: () =>
                            context.push('/doctors/${doctor.id}/edit'),
                      ),
                      error: (_, __) => _DoctorListItem(
                        doctor: doctor,
                        onTap: () => context.push('/doctors/${doctor.id}'),
                        onEdit: () =>
                            context.push('/doctors/${doctor.id}/edit'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps [DoctorCard] and adds an admin-only edit icon overlay.
class _DoctorListItem extends ConsumerWidget {
  final dynamic doctor;
  final String? specialtyName;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _DoctorListItem({
    required this.doctor,
    this.specialtyName,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        DoctorCard(
          doctor: doctor,
          specialtyName: specialtyName,
          onTap: onTap,
        ),
        // Edit button shown only to admins
        Positioned(
          top: 8,
          right: 8,
          child: RoleGuard(
            requiredRole: UserRole.admin,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.edit_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
