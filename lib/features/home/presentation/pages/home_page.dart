import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/contact_fab.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../appointments/presentation/providers/appointments_provider.dart';
import '../../../appointments/presentation/widgets/appointment_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final upcomingAsync = ref.watch(activeUpcomingAppointmentsProvider);
    final healthTips = ref.watch(healthTipsProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const ContactFab(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(appointmentsProvider);
          ref.invalidate(specialtiesProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, user?.firstName ?? 'Paciente'),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _buildQuickActions(context),
              ),
            ),

            // Upcoming Appointments
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: SectionHeader(
                  title: 'Próximas citas',
                  actionLabel: 'Ver todas',
                  onAction: () => context.go('/appointments'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: upcomingAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (appointments) {
                  if (appointments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildNoAppointments(context),
                    );
                  }
                  final limited = appointments.take(2).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: limited
                          .map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AppointmentCard(
                                  appointment: a,
                                  onTap: () =>
                                      context.push('/appointments/${a.id}'),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),

            // Health Tips — auto-play carousel with dots
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SectionHeader(title: 'Consejos de salud'),
              ),
            ),
            SliverToBoxAdapter(
              child: _HealthTipsCarousel(
                tips: healthTips,
                onTap: _showTipDetail,
              ),
            ),

            // All Specialties compact row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SectionHeader(
                  title: 'Especialidades',
                  actionLabel: 'Ver todas',
                  onAction: () => context.go('/specialties'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: specialtiesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (specialties) => SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: specialties.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final s = specialties[index];
                      return GestureDetector(
                        onTap: () => context.push('/specialties/${s.id}'),
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: s.color.withAlpha(25),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: s.color.withAlpha(75)),
                              ),
                              child: Icon(s.iconData, color: s.color, size: 30),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 72,
                              child: Text(
                                s.name,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  static void _showTipDetail(BuildContext context, HealthTip tip) {
    Color color;
    try {
      color = Color(int.parse(tip.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = AppColors.primary;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HealthTipDetailSheet(tip: tip, color: color),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    final greeting =
        hour < 12 ? 'Buenos días' : hour < 18 ? 'Buenas tardes' : 'Buenas noches';

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting, style: AppTextStyles.whiteBody),
                  Text('Hola, $name! 👋', style: AppTextStyles.whiteTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Tu familia es nuestra prioridad',
                    style: AppTextStyles.whiteBody
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded,
                    color: AppColors.textGray, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Buscar médicos, especialidades...',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
          icon: Icons.calendar_today_rounded,
          label: 'Reservar\ncita',
          color: AppColors.primary,
          path: '/appointments/create'),
      _QuickAction(
          icon: Icons.people_rounded,
          label: 'Nuestros\nmédicos',
          color: AppColors.secondary,
          path: '/doctors'),
      _QuickAction(
          icon: Icons.medical_services_rounded,
          label: 'Especiali-\ndades',
          color: const Color(0xFF6A1B9A),
          path: '/specialties'),
      _QuickAction(
          icon: Icons.history_rounded,
          label: 'Mi\nhistorial',
          color: const Color(0xFFE65100),
          path: '/history'),
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _QuickActionCard(action: a),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNoAppointments(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/appointments/create'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sin citas próximas', style: AppTextStyles.cardTitle),
                  Text(
                    'Toca aquí para reservar una cita',
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ── Health tip detail sheet ────────────────────────────────────────────────

class _HealthTipDetailSheet extends StatelessWidget {
  final HealthTip tip;
  final Color color;

  const _HealthTipDetailSheet({required this.tip, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Gradient header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withAlpha(190)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(tip.icon, style: const TextStyle(fontSize: 42)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: AppTextStyles.whiteTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Body content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              tip.body,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Divider(),
          ),
          // CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              '¿Te gustaría hablar con un especialista?',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/appointments/create');
              },
              icon: const Icon(Icons.calendar_today_rounded),
              label: const Text('Reservar una cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + 20,
          ),
        ],
      ),
    );
  }
}

// ── Reusable private widgets ───────────────────────────────────────────────

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String path;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.path,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (action.path == '/appointments/create') {
          context.push(action.path);
        } else {
          context.go(action.path);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: action.color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: action.color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: action.color.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Health tips auto-play carousel ────────────────────────────────────────

class _HealthTipsCarousel extends StatefulWidget {
  final List<HealthTip> tips;
  final void Function(BuildContext, HealthTip) onTap;

  const _HealthTipsCarousel({required this.tips, required this.onTap});

  @override
  State<_HealthTipsCarousel> createState() => _HealthTipsCarouselState();
}

class _HealthTipsCarouselState extends State<_HealthTipsCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;

  static const int _initialPage = 5000;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.88,
    );
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  int get _count => widget.tips.length;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentPage = index % _count);
              _startAutoPlay();
            },
            itemBuilder: (context, index) {
              final tip = widget.tips[index % _count];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => widget.onTap(context, tip),
                  child: _HealthTipCard(tip: tip),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_count, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Health tip card ────────────────────────────────────────────────────────

class _HealthTipCard extends StatelessWidget {
  final HealthTip tip;
  const _HealthTipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = Color(int.parse(tip.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = AppColors.primary;
    }

    return Container(
      // no fixed width — fills the PageView page
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(190)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(tip.title,
              style: AppTextStyles.whiteTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              tip.body,
              style:
                  AppTextStyles.whiteBody.copyWith(fontSize: 12, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Subtle tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ver más →',
                style: AppTextStyles.whiteBody.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
