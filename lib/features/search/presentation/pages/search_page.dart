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
  final _focusNode = FocusNode();
  String _query = '';

  // Filtros
  String? _selectedSpecialtyId;
  double _maxPrice = 200;
  double _minRating = 0;
  bool _showFilters = false;

  // Días de la semana: 1=Lun … 6=Sab
  final Set<int> _selectedDays = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedSpecialtyId != null ||
      _maxPrice < 200 ||
      _minRating > 0 ||
      _selectedDays.isNotEmpty;

  List<DoctorEntity> _filterDoctors(List<DoctorEntity> all) {
    return all.where((d) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!d.fullName.toLowerCase().contains(q)) { return false; }
      }
      if (_selectedSpecialtyId != null && d.specialtyId != _selectedSpecialtyId) return false;
      if (d.consultationFee > _maxPrice) return false;
      if (d.rating < _minRating) return false;
      if (_selectedDays.isNotEmpty &&
          !_selectedDays.any((day) => d.availableDays.contains(day))) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  List<SpecialtyEntity> _filterSpecialties(List<SpecialtyEntity> all) {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return all.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final doctors = doctorsAsync.valueOrNull ?? [];
    final specialties = specialtiesAsync.valueOrNull ?? [];

    final showResults = _query.isNotEmpty || _hasActiveFilters;
    final filteredDoctors = showResults ? _filterDoctors(doctors) : <DoctorEntity>[];
    final filteredSpecialties = _filterSpecialties(specialties);

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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
                  color: _hasActiveFilters ? AppColors.primary : null,
                ),
                onPressed: () => setState(() => _showFilters = !_showFilters),
                tooltip: 'Filtros',
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFilterPanel(specialties),
          Expanded(
            child: showResults
                ? (filteredDoctors.isEmpty && filteredSpecialties.isEmpty)
                    ? _NoResults(query: _query)
                    : ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (filteredSpecialties.isNotEmpty) ...[
                            _SectionLabel(label: 'Especialidades (${filteredSpecialties.length})'),
                            ...filteredSpecialties.map((s) => _SpecialtyTile(
                                  specialty: s,
                                  onTap: () => context.push('/specialties/${s.id}'),
                                )),
                          ],
                          if (filteredDoctors.isNotEmpty) ...[
                            _SectionLabel(label: 'Médicos (${filteredDoctors.length})'),
                            ...filteredDoctors.map((d) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: DoctorCard(
                                    doctor: d,
                                    onTap: () => context.push('/doctors/${d.id}'),
                                  ),
                                )),
                          ],
                        ],
                      )
                : _SearchHints(
                    specialties: specialties,
                    onSpecialtyTap: (s) => context.push('/specialties/${s.id}'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(List<SpecialtyEntity> specialties) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S'];
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Especialidad
          Text('Especialidad', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todas',
                  selected: _selectedSpecialtyId == null,
                  onTap: () => setState(() => _selectedSpecialtyId = null),
                ),
                ...specialties.map((s) => _FilterChip(
                      label: s.name,
                      selected: _selectedSpecialtyId == s.id,
                      color: s.color,
                      onTap: () => setState(() => _selectedSpecialtyId =
                          _selectedSpecialtyId == s.id ? null : s.id),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Precio
          Row(
            children: [
              Text('Precio máx:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray)),
              const SizedBox(width: 8),
              Text('S/ ${_maxPrice.toStringAsFixed(0)}', style: AppTextStyles.labelMedium),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 50,
            max: 200,
            divisions: 15,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _maxPrice = v),
          ),
          // Rating mínimo
          Row(
            children: [
              Text('Rating mínimo:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray)),
              const SizedBox(width: 8),
              ...List.generate(5, (i) => GestureDetector(
                    onTap: () => setState(() => _minRating = _minRating == i + 1.0 ? 0 : i + 1.0),
                    child: Icon(
                      i < _minRating ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 22,
                      color: const Color(0xFFFFC107),
                    ),
                  )),
            ],
          ),
          // Días disponibles
          const SizedBox(height: 6),
          Text('Días disponibles', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGray)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(6, (i) {
              final day = i + 1;
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () => setState(() => selected ? _selectedDays.remove(day) : _selectedDays.add(day)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surfaceVariantLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      days[i],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: selected ? Colors.white : AppColors.textGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: () => setState(() {
                _selectedSpecialtyId = null;
                _maxPrice = 200;
                _minRating = 0;
                _selectedDays.clear();
              }),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Limpiar filtros'),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(30) : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? c : AppColors.textGray,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

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
            children: specialties.map((s) => GestureDetector(
                  onTap: () => onSpecialtyTap(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        Text(s.name, style: AppTextStyles.labelMedium.copyWith(color: s.color)),
                      ],
                    ),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGray)),
      );
}

class _SpecialtyTile extends StatelessWidget {
  final SpecialtyEntity specialty;
  final VoidCallback onTap;
  const _SpecialtyTile({required this.specialty, required this.onTap});
  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: specialty.color.withAlpha(22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(specialty.iconData, color: specialty.color, size: 22),
        ),
        title: Text(specialty.name, style: AppTextStyles.cardTitle),
        subtitle: specialty.description != null
            ? Text(specialty.description!, style: AppTextStyles.cardSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        onTap: onTap,
      );
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.textGray),
            const SizedBox(height: 16),
            Text('Sin resultados', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Text(
              'No encontramos nada para "$query".',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
