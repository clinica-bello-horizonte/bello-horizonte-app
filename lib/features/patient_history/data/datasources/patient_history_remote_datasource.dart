import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/patient_record_model.dart';

class PatientHistoryRemoteDatasource {
  final ApiClient _api;
  PatientHistoryRemoteDatasource(this._api);

  Future<List<PatientRecordModel>> getAll() async {
    final data = await _api.get(ApiEndpoints.patientRecords) as List;
    return data
        .map((e) => PatientRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PatientRecordModel?> getById(String id) async {
    try {
      final data = await _api.get(ApiEndpoints.patientRecordById(id))
          as Map<String, dynamic>;
      return PatientRecordModel.fromJson(data);
    } on NotFoundException {
      return null;
    }
  }
}
