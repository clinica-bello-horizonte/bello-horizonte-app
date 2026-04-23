import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/appointment_entity.dart';
import '../providers/appointments_provider.dart';
import '../widgets/appointment_card.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/appointments/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva cita'),
        backgroundColor: AppColors.primary,
      ),
      body: appointmentsAsync.when(
        loading: () => const FullScreenLoader(message: 'Cargando citas...'),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (appointments) {
          final upcoming = appointments.where((a) =>
              a.isUpcoming && a.status != AppointmentStatus.cancelled).toList();
          final past = appointments.where((a) =>
              a.isPast || a.status == AppointmentStatus.cancelled ||
              a.status == AppointmentStatus.completed).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(
                appointments: upcoming,
                emptyIcon: Icons.calendar_today_outlined,
                emptyTitle: 'Sin citas próximas',
                emptySubtitle: 'No tienes citas programadas.\nPresiona + para reservar una.',
              ),
              _buildList(
                appointments: past,
                emptyIcon: Icons.history_rounded,
                emptyTitle: 'Sin historial',
                emptySubtitle: 'Aquí aparecerán tus citas pasadas.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList({
    required List appointments,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
  }) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
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
