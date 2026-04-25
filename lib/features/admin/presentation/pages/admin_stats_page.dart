import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_overlay.dart';

final _adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.watch(apiClientProvider).get(ApiEndpoints.adminStats);
  return data as Map<String, dynamic>;
});

class AdminStatsPage extends ConsumerWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_adminStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: statsAsync.when(
        loading: () => const FullScreenLoader(message: 'Cargando estadísticas...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) {
          final byStatus = (stats['byStatus'] as Map?)?.cast<String, dynamic>() ?? {};
          final byMonth = (stats['byMonth'] as List?) ?? [];
          final topDoctors = (stats['topDoctors'] as List?) ?? [];
          final topSpecialties = (stats['topSpecialties'] as List?) ?? [];
          final total = stats['totalAppointments'] as int? ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total card
                _StatCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Total de citas',
                  value: '$total',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),

                // Estado de citas
                Text('Por estado', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip('Pendientes', byStatus['PENDING'] ?? 0, const Color(0xFFF59E0B)),
                    const SizedBox(width: 8),
                    _buildStatusChip('Confirmadas', byStatus['CONFIRMED'] ?? 0, AppColors.primary),
                    const SizedBox(width: 8),
                    _buildStatusChip('Completadas', byStatus['COMPLETED'] ?? 0, const Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    _buildStatusChip('Canceladas', byStatus['CANCELLED'] ?? 0, Colors.red),
                  ],
                ),
                const SizedBox(height: 24),

                // Gráfica por mes
                if (byMonth.isNotEmpty) ...[
                  Text('Citas por mes', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (byMonth.map((m) => (m['count'] as int? ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) * 1.3),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= byMonth.length) return const SizedBox();
                                final month = (byMonth[i]['month'] as String).substring(5); // MM
                                return Text(month, style: AppTextStyles.caption);
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: byMonth.asMap().entries.map((e) => BarChartGroupData(
                          x: e.key,
                          barRods: [BarChartRodData(
                            toY: (e.value['count'] as int? ?? 0).toDouble(),
                            color: AppColors.primary,
                            width: 18,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          )],
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Top médicos
                if (topDoctors.isNotEmpty) ...[
                  Text('Médicos más solicitados', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ...topDoctors.map((d) => _RankRow(
                    name: d['name'] as String,
                    count: d['count'] as int,
                    color: AppColors.primary,
                  )),
                  const SizedBox(height: 24),
                ],

                // Top especialidades
                if (topSpecialties.isNotEmpty) ...[
                  Text('Especialidades más solicitadas', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ...topSpecialties.map((s) => _RankRow(
                    name: s['name'] as String,
                    count: s['count'] as int,
                    color: AppColors.secondary,
                  )),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color, color.withAlpha(180)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.whiteBody),
            Text(value, style: AppTextStyles.whiteTitle.copyWith(fontSize: 32)),
          ],
        ),
      ],
    ),
  );
}

class _RankRow extends StatelessWidget {
  final String name;
  final int count;
  final Color color;
  const _RankRow({required this.name, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(child: Text(name, style: AppTextStyles.bodyMedium)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
          child: Text('$count citas', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ),
  );
}
