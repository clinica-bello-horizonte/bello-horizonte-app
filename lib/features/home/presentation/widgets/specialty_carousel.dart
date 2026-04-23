import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../specialties/domain/entities/specialty_entity.dart';

class SpecialtyCarouselWidget extends StatefulWidget {
  final List<SpecialtyEntity> specialties;

  const SpecialtyCarouselWidget({super.key, required this.specialties});

  @override
  State<SpecialtyCarouselWidget> createState() => _SpecialtyCarouselWidgetState();
}

class _SpecialtyCarouselWidgetState extends State<SpecialtyCarouselWidget> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const int _initialPage = 4998;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.88,
    );
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  int get _count => widget.specialties.length;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index % _count);
              _startAutoPlay();
            },
            itemBuilder: (context, index) {
              final specialty = widget.specialties[index % _count];
              return _SlideCard(
                specialty: specialty,
                onTap: () => _showSpecialtyModal(context, specialty),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_count, _buildDot),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
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
  }

  void _showSpecialtyModal(BuildContext context, SpecialtyEntity specialty) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SpecialtyDetailSheet(specialty: specialty),
    );
  }
}

class _SlideCard extends StatelessWidget {
  final SpecialtyEntity specialty;
  final VoidCallback onTap;

  const _SlideCard({required this.specialty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [specialty.color, specialty.color.withAlpha(190)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: specialty.color.withAlpha(80),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                specialty.iconData,
                size: 120,
                color: Colors.white.withAlpha(30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Especialidad destacada',
                      style: AppTextStyles.whiteBody.copyWith(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(specialty.name, style: AppTextStyles.whiteTitle),
                  const SizedBox(height: 3),
                  Text(
                    specialty.description != null &&
                            specialty.description!.isNotEmpty
                        ? specialty.description!
                        : '¿Tienes consultas sobre ${specialty.name}?',
                    style:
                        AppTextStyles.whiteBody.copyWith(fontSize: 12, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(100)),
                    ),
                    child: Text(
                      'Reservar cita  →',
                      style: AppTextStyles.whiteBody.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyDetailSheet extends StatelessWidget {
  final SpecialtyEntity specialty;

  const _SpecialtyDetailSheet({required this.specialty});

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
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Gradient header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [specialty.color, specialty.color.withAlpha(190)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(specialty.iconData, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(specialty.name, style: AppTextStyles.whiteTitle),
                        const SizedBox(height: 4),
                        Text(
                          '¿Tienes consultas sobre ${specialty.name}?',
                          style: AppTextStyles.whiteBody.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  specialty.description != null && specialty.description!.isNotEmpty
                      ? specialty.description!
                      : 'Nuestros especialistas en ${specialty.name} están disponibles para brindarte la mejor atención.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '¿Te gustaría sacar una cita con nuestros especialistas?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      '/appointments/create',
                      extra: {'specialtyId': specialty.id},
                    );
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: const Text('Haz click aquí para reservar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: specialty.color,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/specialties/${specialty.id}');
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Text('Ver más sobre esta especialidad'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: specialty.color,
                    side: BorderSide(color: specialty.color, width: 1.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
