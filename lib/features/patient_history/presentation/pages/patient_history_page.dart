import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/patient_history_provider.dart';
import '../widgets/patient_record_card.dart';

class PatientHistoryPage extends ConsumerWidget {
  const PatientHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(patientHistoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Mi Historial Médico')),
      body: historyAsync.when(
        loading: () => const FullScreenLoader(message: 'Cargando historial...'),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'Sin registros médicos',
              subtitle: 'Aquí aparecerán tus consultas y registros médicos previos.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(patientHistoryProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => PatientRecordCard(
                record: records[index],
                onTap: () => context.push('/history/${records[index].id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
