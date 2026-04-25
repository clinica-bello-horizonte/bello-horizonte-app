import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../domain/entities/appointment_entity.dart';
import '../providers/appointments_provider.dart';
import '../providers/ratings_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  // Estático: persiste aunque el widget se recree al navegar entre tabs
  static final _shownPrompts = <String>{};
  bool _promptScheduled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkPendingRatings(List<AppointmentEntity> completed) async {
    if (_promptScheduled) return;
    // Buscar la primera cita completada cuya calificación no hayamos verificado
    for (final apt in completed) {
      if (_shownPrompts.contains(apt.id)) continue;
      _shownPrompts.add(apt.id);

      // Verificar si ya tiene rating en el backend
      final existing = await ref.read(appointmentRatingProvider(apt.id).future);
      if (existing != null) continue; // ya calificada

      if (!mounted) return;
      _promptScheduled = true;
      await _showRatingSheet(apt);
      _promptScheduled = false;
      return; // solo un prompt a la vez
    }
  }

  Future<void> _showRatingSheet(AppointmentEntity apt) async {
    int selectedStars = 0;
    final commentCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 40),
              const SizedBox(height: 12),
              Text('¿Cómo fue tu cita?', style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                apt.doctorName != null ? 'Con ${apt.doctorName}' : 'Califica tu experiencia',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Estrellas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setSheet(() => selectedStars = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 40,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Comentario opcional...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Omitir',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Enviar',
                      onPressed: selectedStars == 0 ? null : () async {
                        Navigator.pop(ctx);
                        final ok = await ref.read(ratingNotifierProvider.notifier)
                            .submitRating(apt.id, selectedStars, commentCtrl.text.trim());
                        if (mounted) {
                          if (ok) context.showSuccessSnackBar('¡Gracias por tu calificación!');
                          else context.showErrorSnackBar('Error al enviar calificación');
                        }
                      },
                      trailingIcon: Icons.send_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mis Citas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGray,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Próximas'), Tab(text: 'Historial')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/appointments/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva cita'),
        backgroundColor: AppColors.primary,
      ),
      body: appointmentsAsync.when(
        loading: () => buildSkeletonList(itemBuilder: () => const AppointmentCardSkeleton()),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (appointments) {
          final upcoming = appointments
              .where((a) => a.isUpcoming && a.status != AppointmentStatus.cancelled)
              .toList();
          final past = appointments
              .where((a) => a.isPast || a.status == AppointmentStatus.cancelled || a.status == AppointmentStatus.completed)
              .toList();

          final pendingRating = past.where((a) => a.status == AppointmentStatus.completed).toList();
          if (pendingRating.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingRatings(pendingRating));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(appointments: upcoming, emptyIcon: Icons.calendar_today_outlined, emptyTitle: 'Sin citas próximas', emptySubtitle: 'No tienes citas programadas.\nPresiona + para reservar una.'),
              _buildList(appointments: past, emptyIcon: Icons.history_rounded, emptyTitle: 'Sin historial', emptySubtitle: 'Aquí aparecerán tus citas pasadas.'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList({required List appointments, required IconData emptyIcon, required String emptyTitle, required String emptySubtitle}) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(icon: emptyIcon, title: emptyTitle, subtitle: emptySubtitle);
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(appointmentsProvider),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => AppointmentCard(
          appointment: appointments[index],
          onTap: () => context.push('/appointments/${appointments[index].id}'),
        ),
      ),
    );
  }
}
