import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/specialties_remote_datasource.dart';
import '../../data/repositories/specialties_repository_impl.dart';
import '../../domain/entities/specialty_entity.dart';
import '../../domain/repositories/specialties_repository.dart';

final specialtiesRepositoryProvider = Provider<SpecialtiesRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return SpecialtiesRepositoryImpl(SpecialtiesRemoteDatasource(api));
});

final specialtiesProvider = FutureProvider<List<SpecialtyEntity>>((ref) async {
  final repo = ref.watch(specialtiesRepositoryProvider);
  return repo.getSpecialties();
});

final specialtyByIdProvider = FutureProvider.family<SpecialtyEntity?, String>((ref, id) async {
  final repo = ref.watch(specialtiesRepositoryProvider);
  return repo.getSpecialtyById(id);
});
