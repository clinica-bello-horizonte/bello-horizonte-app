import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/patient_record_entity.dart';
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
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                tooltip: 'Exportar PDF',
                onPressed: () => _exportPdf(context, record),
              ),
            ],
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
                    border: Border.all(color: AppColors.warning.withAlpha(76)),
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

  Future<void> _exportPdf(BuildContext context, PatientRecordEntity record) async {
    try {
    final pdf = pw.Document();
    final dateStr = '${record.recordDate.day.toString().padLeft(2,'0')}/'
        '${record.recordDate.month.toString().padLeft(2,'0')}/'
        '${record.recordDate.year}';
    final fileDate = '${record.recordDate.year}-'
        '${record.recordDate.month.toString().padLeft(2,'0')}-'
        '${record.recordDate.day.toString().padLeft(2,'0')}';
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(color: PdfColors.blue800),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Clínica Bello Horizonte',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Registro Médico', style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 12)),
                    ],
                  ),
                  pw.Text(dateStr, style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Info
            if (record.doctorName != null) _pdfRow('Médico', 'Dr. ${record.doctorName}'),
            if (record.specialtyName != null) _pdfRow('Especialidad', record.specialtyName!),
            pw.SizedBox(height: 16),
            if (record.diagnosis != null) ...[
              pw.Text('Diagnóstico', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue200), borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Text(record.diagnosis!, style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 14),
            ],
            if (record.treatment != null) ...[
              pw.Text('Tratamiento prescrito', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue200), borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Text(record.treatment!, style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 14),
            ],
            if (record.notes != null) ...[
              pw.Text('Notas clínicas', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Text(record.notes!, style: const pw.TextStyle(fontSize: 12)),
              ),
            ],
            pw.Spacer(),
            pw.Divider(),
            pw.Text('Este documento es informativo. Para uso clínico oficial consulte directamente con la clínica.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'registro_medico_$fileDate.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      children: [
        pw.Text('$label: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
      ],
    ),
  );

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
                color: color.withAlpha(30),
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
            color: color.withAlpha(13),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(38)),
          ),
          child: Text(content, style: AppTextStyles.bodyMedium.copyWith(height: 1.7)),
        ),
      ],
    );
  }
}
