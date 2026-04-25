import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_overlay.dart';

final myWaitlistProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final data = await ref.watch(apiClientProvider).get(ApiEndpoints.myWaitlist);
  return (data as List?) ?? [];
});

class WaitlistPage extends ConsumerWidget {
  const WaitlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(myWaitlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Lista de Espera')),
      body: listAsync.when(
        loading: () => const FullScreenLoader(message: 'Cargando...'),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.queue_rounded,
              title: 'Sin entradas',
              subtitle: 'No estás en ninguna lista de espera.\nCuando un slot esté ocupado podrás unirte.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myWaitlistProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final e = entries[i] as Map<String, dynamic>;
                final doctor = e['doctor'] as Map<String, dynamic>?;
                final doctorName = doctor != null
                    ? 'Dr. ${doctor['firstName']} ${doctor['lastName']}'
                    : '—';
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.schedule_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctorName, style: AppTextStyles.cardTitle),
                            Text('${e['date']} · ${e['time']}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.red),
                        tooltip: 'Salir de la lista',
                        onPressed: () async {
                          try {
                            await ref.read(apiClientProvider).delete(
                              ApiEndpoints.waitlistEntry(e['id'] as String),
                            );
                            if (context.mounted) context.showSuccessSnackBar('Saliste de la lista de espera');
                          } catch (_) {
                            if (context.mounted) context.showErrorSnackBar('Error al salir de la lista');
                          }
                          ref.invalidate(myWaitlistProvider);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
