import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../appointments/data/models/appointment_model.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';

final _adminDoctorApptsProvider = FutureProvider.autoDispose
    .family<List<AppointmentEntity>, ({String doctorId, String? date, String? status})>(
  (ref, args) async {
    final api = ref.watch(apiClientProvider);
    final params = <String, dynamic>{};
    if (args.date != null) params['date'] = args.date;
    if (args.status != null) params['status'] = args.status;
    final data = await api.get(
      ApiEndpoints.adminAppointmentsByDoctor(args.doctorId),
      queryParameters: params,
    );
    if (data == null) return [];
    return (data as List)
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);

class AdminDoctorAppointmentsPage extends ConsumerStatefulWidget {
  final DoctorEntity doctor;
  const AdminDoctorAppointmentsPage({super.key, required this.doctor});

  @override
  ConsumerState<AdminDoctorAppointmentsPage> createState() =>
      _AdminDoctorAppointmentsPageState();
}

class _AdminDoctorAppointmentsPageState
    extends ConsumerState<AdminDoctorAppointmentsPage> {
  DateTime? _selectedDate;
  String? _selectedStatus;

  String? get _dateStr =>
      _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null;

  static const _statuses = [
    null, 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'POSTPONED',
  ];
  static const _statusLabels = [
    'Todas', 'Pendiente', 'Confirmada', 'Completada', 'Cancelada', 'Postergada',
  ];

  @override
  Widget build(BuildContext context) {
    final args = (doctorId: widget.doctor.id, date: _dateStr, status: _selectedStatus);
    final apptsAsync = ref.watch(_adminDoctorApptsProvider(args));

    return Scaffold(
      appBar: AppBar(
        title: Text('Citas — Dr. ${widget.doctor.lastName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: apptsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (apts) => apts.isEmpty
                  ? const Center(child: Text('Sin citas con estos filtros'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: apts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) => _AdminApptTile(
                        appointment: apts[i],
                        onStatusChange: (newStatus) async {
                          await ref.read(apiClientProvider).patch(
                            '/admin/appointments/${apts[i].id}/status/$newStatus',
                          );
                          ref.invalidate(_adminDoctorApptsProvider);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today_rounded, size: 16),
                  label: Text(_selectedDate != null
                      ? DateFormat('d MMM yyyy', 'es').format(_selectedDate!)
                      : 'Filtrar por fecha'),
                  onPressed: _pickDate,
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => setState(() => _selectedDate = null),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_statuses.length, (i) {
                final selected = _selectedStatus == _statuses[i];
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = _statuses[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabels[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected ? Colors.white : AppColors.textGray,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}

class _AdminApptTile extends StatelessWidget {
  final AppointmentEntity appointment;
  final Future<void> Function(String) onStatusChange;

  const _AdminApptTile({required this.appointment, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final apt = appointment;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: apt.status.color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(apt.patientName ?? 'Paciente', style: AppTextStyles.cardTitle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: apt.status.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  apt.status.label,
                  style: AppTextStyles.caption.copyWith(
                    color: apt.status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${apt.appointmentDate.toLocal().toString().split(' ')[0]} — ${apt.appointmentTime}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGray),
          ),
          if (apt.reason != null) ...[
            const SizedBox(height: 4),
            Text(apt.reason!, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (apt.status == AppointmentStatus.pending)
                TextButton(
                  onPressed: () => onStatusChange('CONFIRMED'),
                  child: const Text('Confirmar'),
                ),
              if (apt.status == AppointmentStatus.confirmed)
                TextButton(
                  onPressed: () => onStatusChange('COMPLETED'),
                  child: const Text('Completar'),
                ),
              if (apt.isCancellable)
                TextButton(
                  onPressed: () => onStatusChange('CANCELLED'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancelar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
