import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

const _kOnboardingKey = 'onboarding_done';

/// Loaded synchronously in main() before runApp — overridden via ProviderScope.
final onboardingDoneSyncProvider = Provider<bool>((ref) => false);

/// Kept for legacy use; prefer onboardingDoneSyncProvider in the router.
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final val = await storage.read(key: _kOnboardingKey);
  return val == 'true';
});

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.local_hospital_rounded,
      color: AppColors.primary,
      title: 'Bienvenido a\nClínica Bello Horizonte',
      subtitle: 'Tu salud es nuestra prioridad. Gestiona tus citas médicas desde donde estés.',
    ),
    _Slide(
      icon: Icons.calendar_today_rounded,
      color: Color(0xFF00897B),
      title: 'Reserva citas\nen segundos',
      subtitle: 'Elige tu especialidad, médico, fecha y hora favorita. Simple y rápido.',
    ),
    _Slide(
      icon: Icons.notifications_active_rounded,
      color: Color(0xFF6A1B9A),
      title: 'Nunca olvides\ntu cita',
      subtitle: 'Recibe recordatorios automáticos el día anterior para estar siempre preparado.',
    ),
    _Slide(
      icon: Icons.history_rounded,
      color: Color(0xFFE65100),
      title: 'Tu historial\nsiempre contigo',
      subtitle: 'Accede a diagnósticos, tratamientos y registros médicos en cualquier momento.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _kOnboardingKey, value: 'true');
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Omitir', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlideWidget(slide: _slides[i]),
              ),
            ),
            _buildDots(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                label: _page == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                onPressed: () {
                  if (_page == _slides.length - 1) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                trailingIcon: _page == _slides.length - 1
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _slides.length,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _page ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}

class _SlideWidget extends StatelessWidget {
  final _Slide slide;
  const _SlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: slide.color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 56, color: slide.color),
            ),
            const SizedBox(height: 40),
            Text(slide.title, style: AppTextStyles.h1, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              slide.subtitle,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _Slide {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _Slide({required this.icon, required this.color, required this.title, required this.subtitle});
}
