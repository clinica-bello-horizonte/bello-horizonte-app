import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../providers/patient_history_provider.dart';

class PatientRecordDetailPage extends ConsumerWidget {
  final String recordId;
  const PatientRecordDetailPage({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(patientRecordByIdProvider(recordId));

    return recordAsync.when(
      loading: () => const Scaffold(body: FullScreenLoader()),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (record) {
        if (record == null) {
          return const Scaffold(body: Center(child: Text('Registro no encontrado')));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle Médico'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.specialtyName ?? 'Consulta médica',
                        style: AppTextStyles.whiteBody.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.diagnosis ?? 'Sin diagnóstico registrado',
                        style: AppTextStyles.whiteTitle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, color: Colors.white70, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              record.doctorName != null ? 'Dr. ${record.doctorName}' : 'Médico',
                              style: AppTextStyles.whiteBody,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            DateFormatter.toDisplay(record.recordDate),
                            style: AppTextStyles.whiteBody,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (record.treatment != null) ...[
                  _buildSection('Tratamiento prescrito', Icons.medication_rounded, record.treatment!, AppColors.primary),
                  const SizedBox(height: 16),
                ],
                if (record.notes != null) ...[
                  _buildSection('Notas clínicas', Icons.notes_rounded, record.notes!, AppColors.secondary),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Este es un registro informativo local. Para uso médico oficial, consulta directamente con la clínica.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, IconData icon, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTextStyles.h4),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Text(content, style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
        ),
      ],
    );
  }
}
