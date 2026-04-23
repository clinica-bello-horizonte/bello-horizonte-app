import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Static contact config — swap for API values when backend is ready.
const _kPhoneNumber = '51073123456';
const _kWhatsappNumber = '51999000001';
const _kWhatsappMessage =
    'Hola, deseo reservar una cita en Clínica Bello Horizonte.';

class ContactFab extends StatefulWidget {
  const ContactFab({super.key});

  @override
  State<ContactFab> createState() => _ContactFabState();
}

class _ContactFabState extends State<ContactFab> {
  Timer? _iconTimer;
  bool _showPhone = true;

  @override
  void initState() {
    super.initState();
    _iconTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (mounted) setState(() => _showPhone = !_showPhone);
    });
  }

  @override
  void dispose() {
    _iconTimer?.cancel();
    super.dispose();
  }

  void _openPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ContactPanel(
        phoneNumber: _kPhoneNumber,
        whatsappNumber: _kWhatsappNumber,
        whatsappMessage: _kWhatsappMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _showPhone ? AppColors.primary : const Color(0xFF25D366),
        boxShadow: [
          BoxShadow(
            color: (_showPhone ? AppColors.primary : const Color(0xFF25D366))
                .withAlpha(90),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _openPanel,
        backgroundColor: Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Icon(
            _showPhone ? Icons.phone_rounded : Icons.chat_bubble_rounded,
            key: ValueKey(_showPhone),
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

// ── Contact panel bottom sheet ─────────────────────────────────────────────

class _ContactPanel extends StatelessWidget {
  final String phoneNumber;
  final String whatsappNumber;
  final String whatsappMessage;

  const _ContactPanel({
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.whatsappMessage,
  });

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '¿Desea reservar una cita directamente\ncon alguno de nuestros asesores?',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Contáctenos por el medio de su preferencia',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _ContactOption(
                  icon: Icons.phone_rounded,
                  label: 'Llamar ahora',
                  subtitle: '+51 073 123 456',
                  color: AppColors.primary,
                  onTap: () => _launch('tel:+$phoneNumber'),
                ),
                const SizedBox(height: 12),
                _ContactOption(
                  icon: Icons.chat_bubble_rounded,
                  label: 'WhatsApp',
                  subtitle: '+51 999 000 001',
                  color: const Color(0xFF25D366),
                  onTap: () => _launch(
                    'https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(whatsappMessage)}',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textGray),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.cardTitle),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
