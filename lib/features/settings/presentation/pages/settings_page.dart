import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/upload_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final themeMode = ref.watch(themeModeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && systemBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).cardColor,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final url = await ref.read(uploadProvider.notifier).pickAndUpload();
                      if (url == null && context.mounted) {
                        final err = ref.read(uploadProvider).hasError;
                        if (err) context.showErrorSnackBar('Error al subir la foto');
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(76),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            image: user?.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user!.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: user?.photoUrl == null
                              ? Center(
                                  child: Text(
                                    user?.initials ?? 'U',
                                    style: AppTextStyles.displayMedium.copyWith(color: Colors.white, fontSize: 30),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Theme.of(context).cardColor, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                        if (ref.watch(uploadProvider).isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user?.fullName ?? 'Usuario', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'DNI: ${user?.dni ?? ''}',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/settings/edit-profile'),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Editar perfil'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Settings sections
            _buildSection(
              context,
              title: 'Cuenta',
              items: [
                _SettingsItem(
                  icon: Icons.badge_outlined,
                  title: 'Datos personales',
                  subtitle: 'DNI, nombre, teléfono',
                  onTap: () => context.push('/settings/edit-profile'),
                ),
                _SettingsItem(
                  icon: Icons.phone_rounded,
                  title: 'Teléfono',
                  subtitle: user?.phone ?? '',
                  onTap: () {},
                ),
              ],
            ),

            _buildSection(
              context,
              title: 'Apariencia',
              items: [
                _SettingsItem(
                  icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: 'Modo oscuro',
                  subtitle: isDark ? 'Activado' : 'Desactivado',
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(systemBrightness),
                    activeColor: AppColors.primary,
                  ),
                  onTap: null,
                ),
              ],
            ),

            _buildSection(
              context,
              title: 'Información',
              items: [
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Sobre la app',
                  subtitle: 'Clínica Bello Horizonte v1.0.0',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.location_on_outlined,
                  title: 'Dirección',
                  subtitle: 'Piura, Perú - Sector Oeste',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Contacto',
                  subtitle: '+51 (073) 123-4567',
                  onTap: () {},
                ),
              ],
            ),

            if (user?.role == UserRole.user)
              _buildSection(
                context,
                title: 'Mis reservas',
                items: [
                  _SettingsItem(
                    icon: Icons.queue_rounded,
                    title: 'Lista de espera',
                    subtitle: 'Slots que estás esperando',
                    iconColor: AppColors.secondary,
                    onTap: () => context.push('/waitlist'),
                  ),
                ],
              ),

            if (user?.isAdmin == true)
              _buildSection(
                context,
                title: 'Administración',
                items: [
                  _SettingsItem(
                    icon: Icons.campaign_rounded,
                    title: 'Enviar notificaciones',
                    subtitle: 'Avisos a pacientes',
                    iconColor: AppColors.secondary,
                    onTap: () => context.push('/admin/notifications'),
                  ),
                  _SettingsItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Estadísticas',
                    subtitle: 'Citas, médicos y especialidades',
                    iconColor: AppColors.primary,
                    onTap: () => context.push('/admin/stats'),
                  ),
                ],
              ),

            _buildSection(
              context,
              title: 'Sesión',
              items: [
                _SettingsItem(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de tu cuenta',
                  iconColor: AppColors.error,
                  titleColor: AppColors.error,
                  onTap: () => _logout(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Text(
              'Clínica Bello Horizonte\nTu familia es nuestra prioridad',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<_SettingsItem> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...items.map((item) => _buildTile(context, item)),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, _SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (item.iconColor ?? AppColors.primary).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.iconColor ?? AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.cardTitle.copyWith(color: item.titleColor)),
                  if (item.subtitle != null)
                    Text(item.subtitle!, style: AppTextStyles.cardSubtitle),
                ],
              ),
            ),
            item.trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirm = await context.showConfirmDialog(
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      confirmText: 'Salir',
      cancelText: 'Cancelar',
      isDangerous: true,
    );
    if (confirm == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
    this.trailing,
  });
}
