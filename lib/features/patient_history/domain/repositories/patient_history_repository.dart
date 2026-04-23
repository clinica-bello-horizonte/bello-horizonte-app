import '../entities/patient_record_entity.dart';

abstract class PatientHistoryRepository {
  Future<List<PatientRecordEntity>> getPatientHistory(String userId);
  Future<PatientRecordEntity?> getRecordById(String id);
}
