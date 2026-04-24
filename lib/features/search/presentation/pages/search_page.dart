import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../doctors/domain/entities/doctor_entity.dart';
import '../../../doctors/presentation/providers/doctors_provider.dart';
import '../../../doctors/presentation/widgets/doctor_card.dart';
import '../../../specialties/domain/entities/specialty_entity.dart';
import '../../../specialties/presentation/providers/specialties_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<DoctorEntity> _filterDoctors(List<DoctorEntity> all) {
    if (_query.isEmpty) { return []; }
    final q = _query.toLowerCase();
    return all
        .where((d) =>
            d.fullName.toLowerCase().contains(q) ||
            (d.specialtyId.toLowerCase().contains(q)))
        .toList();
  }

  List<SpecialtyEntity> _filterSpecialties(List<SpecialtyEntity> all) {
    if (_query.isEmpty) { return []; }
    final q = _query.toLowerCase();
    return all.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    final doctors = doctorsAsync.valueOrNull ?? [];
    final specialties = specialtiesAsync.valueOrNull ?? [];

    final filteredDoctors = _filterDoctors(doctors);
    final filteredSpecialties = _filterSpecialties(specialties);

    final hasResults = filteredDoctors.isNotEmpty || filteredSpecialties.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar médicos, especialidades...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          style: AppTextStyles.bodyMedium,
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
      body: _query.isEmpty
          ? _SearchHints(
              specialties: specialties,
              onSpecialtyTap: (s) => context.push('/specialties/${s.id}'),
            )
          : !hasResults
              ? _NoResults(query: _query)
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (filteredSpecialties.isNotEmpty) ...[
                      _SectionLabel(
                          label: 'Especialidades (${filteredSpecialties.length})'),
                      ...filteredSpecialties.map((s) => _SpecialtyTile(
                            specialty: s,
                            onTap: () => context.push('/specialties/${s.id}'),
                          )),
                    ],
                    if (filteredDoctors.isNotEmpty) ...[
                      _SectionLabel(
                          label: 'Médicos (${filteredDoctors.length})'),
                      ...filteredDoctors.map((d) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: DoctorCard(
                              doctor: d,
                              onTap: () => context.push('/doctors/${d.id}'),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}

// ── Search hints (shown when query is empty) ──────────────────────────────

class _SearchHints extends StatelessWidget {
  final List<SpecialtyEntity> specialties;
  final void Function(SpecialtyEntity) onSpecialtyTap;

  const _SearchHints({required this.specialties, required this.onSpecialtyTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Especialidades', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specialties
                .map((s) => GestureDetector(
                      onTap: () => onSpecialtyTap(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: s.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: s.color.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(s.iconData, size: 16, color: s.color),
                            const SizedBox(width: 6),
                            Text(
                              s.name,
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: s.color),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 28),
          Text('Sugerencias', style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...[
            'Cardiología',
            'Pediatría',
            'Medicina general',
            'Traumatología',
          ].map((hint) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.search_rounded,
                    color: AppColors.textGray, size: 20),
                title: Text(hint, style: AppTextStyles.bodyMedium),
                onTap: () {},
              )),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(label,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGray)),
    );
  }
}

// ── Specialty tile in results ─────────────────────────────────────────────

class _SpecialtyTile extends StatelessWidget {
  final SpecialtyEntity specialty;
  final VoidCallback onTap;

  const _SpecialtyTile({required this.specialty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: specialty.color.withAlpha(22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(specialty.iconData, color: specialty.color, size: 22),
      ),
      title: Text(specialty.name, style: AppTextStyles.cardTitle),
      subtitle: specialty.description != null
          ? Text(specialty.description!,
              style: AppTextStyles.cardSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis)
          : null,
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariantLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 36, color: AppColors.textGray),
          ),
          const SizedBox(height: 20),
          Text('Sin resultados', style: AppTextStyles.h4),
          const SizedBox(height: 8),
          Text(
            'No encontramos nada para "$query".',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
