import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _userTabs = [
    _TabItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, label: 'Inicio', path: '/home'),
    _TabItem(icon: Icons.calendar_month_rounded, outlinedIcon: Icons.calendar_month_outlined, label: 'Citas', path: '/appointments'),
    _TabItem(icon: Icons.people_rounded, outlinedIcon: Icons.people_outline_rounded, label: 'Médicos', path: '/doctors'),
    _TabItem(icon: Icons.history_rounded, outlinedIcon: Icons.history_rounded, label: 'Historial', path: '/history'),
    _TabItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, label: 'Perfil', path: '/settings'),
  ];

  static const _doctorTabs = [
    _TabItem(icon: Icons.home_rounded, outlinedIcon: Icons.home_outlined, label: 'Inicio', path: '/home'),
    _TabItem(icon: Icons.calendar_today_rounded, outlinedIcon: Icons.calendar_today_outlined, label: 'Agenda', path: '/doctor/agenda'),
    _TabItem(icon: Icons.people_rounded, outlinedIcon: Icons.people_outline_rounded, label: 'Médicos', path: '/doctors'),
    _TabItem(icon: Icons.person_rounded, outlinedIcon: Icons.person_outline_rounded, label: 'Perfil', path: '/settings'),
  ];

  int _currentIndex(BuildContext context, List<_TabItem> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final isDoctor = user?.role == UserRole.doctor;
    final tabs = isDoctor ? _doctorTabs : _userTabs;
    final currentIndex = _currentIndex(context, tabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 16, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = i == currentIndex;
                return _NavItem(
                  icon: isSelected ? tab.icon : tab.outlinedIcon,
                  label: tab.label,
                  isSelected: isSelected,
                  onTap: () => context.go(tab.path),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final String path;
  const _TabItem({required this.icon, required this.outlinedIcon, required this.label, required this.path});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textLight),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(inherit: false),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
