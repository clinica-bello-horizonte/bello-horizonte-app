import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final _usersProvider = FutureProvider<List<_UserRow>>((ref) async {
  final api = ref.read(apiClientProvider);
  final data = await api.get(ApiEndpoints.adminNotificationUsers);
  return (data as List)
      .map((e) => _UserRow.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminNotificationsPage extends ConsumerStatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  ConsumerState<AdminNotificationsPage> createState() =>
      _AdminNotificationsPageState();
}

class _AdminNotificationsPageState
    extends ConsumerState<AdminNotificationsPage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sendToAll = true;
  final Set<String> _selectedIds = {};
  bool _isSending = false;
  String? _resultMessage;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() {
      _isSending = true;
      _resultMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final result = await api.post(
        ApiEndpoints.adminNotificationSend,
        body: {
          'title': title,
          'body': body,
          if (!_sendToAll) 'userIds': _selectedIds.toList(),
        },
      ) as Map<String, dynamic>?;

      final sent = result?['sent'] ?? 0;
      final skipped = result?['skipped'] ?? 0;
      setState(() {
        _resultMessage = 'Enviado a $sent dispositivo(s). $skipped sin token registrado.';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error al enviar: ${e.toString()}';
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Enviar Notificaciones')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompose(),
            const SizedBox(height: 20),
            _buildRecipients(),
            const SizedBox(height: 28),
            _buildSendButton(),
            if (_resultMessage != null) ...[
              const SizedBox(height: 16),
              _buildResult(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompose() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mensaje', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          AppTextField(
            controller: _titleCtrl,
            label: 'Título',
            hint: 'Ej: Recordatorio de cita',
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _bodyCtrl,
            label: 'Mensaje',
            hint: 'Ej: Su cita es mañana a las 10:00 AM',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Destinatarios', style: AppTextStyles.h4),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ToggleChip(
                label: 'Todos los usuarios',
                icon: Icons.group_rounded,
                selected: _sendToAll,
                onTap: () => setState(() {
                  _sendToAll = true;
                  _selectedIds.clear();
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ToggleChip(
                label: 'Seleccionar',
                icon: Icons.checklist_rounded,
                selected: !_sendToAll,
                onTap: () => setState(() => _sendToAll = false),
              ),
            ),
          ],
        ),
        if (!_sendToAll) ...[
          const SizedBox(height: 14),
          _buildUserList(),
        ],
      ],
    );
  }

  Widget _buildUserList() {
    final usersAsync = ref.watch(_usersProvider);
    return usersAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text('Error cargando usuarios: $e',
          style: const TextStyle(color: AppColors.error)),
      data: (users) {
        if (users.isEmpty) {
          return Text('No hay usuarios registrados.',
              style: AppTextStyles.bodyMedium);
        }
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: users.map((u) {
              final selected = _selectedIds.contains(u.id);
              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => setState(() {
                  if (selected) {
                    _selectedIds.remove(u.id);
                  } else {
                    _selectedIds.add(u.id);
                  }
                }),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            u.initials,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: selected ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.fullName, style: AppTextStyles.cardTitle),
                            Text(u.email,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (!u.hasToken)
                        const Tooltip(
                          message: 'Sin app instalada',
                          child: Icon(Icons.notifications_off_outlined,
                              size: 16, color: AppColors.textLight),
                        ),
                      Checkbox(
                        value: selected,
                        activeColor: AppColors.primary,
                        onChanged: (_) => setState(() {
                          if (selected) {
                            _selectedIds.remove(u.id);
                          } else {
                            _selectedIds.add(u.id);
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    final canSend = !_isSending &&
        _titleCtrl.text.trim().isNotEmpty &&
        _bodyCtrl.text.trim().isNotEmpty &&
        (_sendToAll || _selectedIds.isNotEmpty);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: canSend ? _send : null,
        icon: _isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.send_rounded),
        label: Text(_isSending ? 'Enviando...' : 'Enviar notificación'),
      ),
    );
  }

  Widget _buildResult() {
    final isError = _resultMessage!.startsWith('Error');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.error.withAlpha(20)
            : AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? AppColors.error.withAlpha(60) : AppColors.secondary.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.error : AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_resultMessage!, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle chip ──────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Theme.of(context).dividerColor,
            width: selected ? 0 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textGray),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class _UserRow {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool hasToken;

  const _UserRow({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.hasToken,
  });

  factory _UserRow.fromJson(Map<String, dynamic> j) => _UserRow(
        id: j['id'] as String,
        firstName: j['firstName'] as String,
        lastName: j['lastName'] as String,
        email: j['email'] as String,
        hasToken: j['fcmToken'] != null,
      );

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0].toUpperCase() : ''}'
      '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';
}
