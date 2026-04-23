import '../../domain/entities/patient_record_entity.dart';
import '../../domain/repositories/patient_history_repository.dart';
import '../datasources/patient_history_remote_datasource.dart';

class PatientHistoryRepositoryImpl implements PatientHistoryRepository {
  final PatientHistoryRemoteDatasource _datasource;
  PatientHistoryRepositoryImpl(this._datasource);

  @override
  Future<List<PatientRecordEntity>> getPatientHistory(String userId) =>
      _datasource.getAll();

  @override
  Future<PatientRecordEntity?> getRecordById(String id) =>
      _datasource.getById(id);
}
