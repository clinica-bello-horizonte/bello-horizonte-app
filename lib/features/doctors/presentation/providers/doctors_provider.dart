import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/doctors_remote_datasource.dart';
import '../../data/repositories/doctors_repository_impl.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctors_repository.dart';

final doctorsRepositoryProvider = Provider<DoctorsRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return DoctorsRepositoryImpl(DoctorsRemoteDatasource(api));
});

final doctorsProvider = FutureProvider<List<DoctorEntity>>((ref) async {
  return ref.watch(doctorsRepositoryProvider).getDoctors();
});

final doctorByIdProvider = FutureProvider.family<DoctorEntity?, String>((ref, id) async {
  return ref.watch(doctorsRepositoryProvider).getDoctorById(id);
});

final doctorsBySpecialtyProvider = FutureProvider.family<List<DoctorEntity>, String>((ref, specialtyId) async {
  return ref.watch(doctorsRepositoryProvider).getDoctorsBySpecialty(specialtyId);
});

final doctorSearchProvider = StateProvider<String>((ref) => '');

final filteredDoctorsProvider = FutureProvider<List<DoctorEntity>>((ref) async {
  final query = ref.watch(doctorSearchProvider);
  final repo = ref.watch(doctorsRepositoryProvider);
  if (query.trim().isEmpty) return repo.getDoctors();
  return repo.searchDoctors(query);
});

// ── Admin: doctor editing ──────────────────────────────────────────────────

class DoctorEditState {
  final bool isLoading;
  final bool success;
  final String? error;

  const DoctorEditState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

class DoctorEditNotifier extends StateNotifier<DoctorEditState> {
  final DoctorsRepository _repository;
  final Ref _ref;

  DoctorEditNotifier(this._repository, this._ref)
      : super(const DoctorEditState());

  Future<bool> save(DoctorEntity doctor) async {
    state = const DoctorEditState(isLoading: true);
    try {
      await _repository.updateDoctor(doctor);
      // Invalidate caches so lists/detail pages reflect the update.
      _ref.invalidate(doctorsProvider);
      _ref.invalidate(doctorByIdProvider(doctor.id));
      _ref.invalidate(filteredDoctorsProvider);
      state = const DoctorEditState(success: true);
      return true;
    } catch (e) {
      state = DoctorEditState(error: e.toString());
      return false;
    }
  }

  void reset() => state = const DoctorEditState();
}

final doctorEditProvider =
    StateNotifierProvider<DoctorEditNotifier, DoctorEditState>((ref) {
  return DoctorEditNotifier(ref.watch(doctorsRepositoryProvider), ref);
});
