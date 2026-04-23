import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/patient_history_remote_datasource.dart';
import '../../data/repositories/patient_history_repository_impl.dart';
import '../../domain/entities/patient_record_entity.dart';
import '../../domain/repositories/patient_history_repository.dart';

final patientHistoryRepositoryProvider = Provider<PatientHistoryRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return PatientHistoryRepositoryImpl(PatientHistoryRemoteDatasource(api));
});

final patientHistoryProvider = FutureProvider<List<PatientRecordEntity>>((ref) async {
  final userId = ref.watch(authStateProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(patientHistoryRepositoryProvider).getPatientHistory(userId);
});

final patientRecordByIdProvider = FutureProvider.family<PatientRecordEntity?, String>((ref, id) async {
  return ref.watch(patientHistoryRepositoryProvider).getRecordById(id);
});
