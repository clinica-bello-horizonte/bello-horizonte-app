import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/specialty_model.dart';

class SpecialtiesRemoteDatasource {
  final ApiClient _api;
  SpecialtiesRemoteDatasource(this._api);

  Future<List<SpecialtyModel>> getAll() async {
    final data = await _api.get(ApiEndpoints.specialties) as List;
    return data
        .map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SpecialtyModel?> getById(String id) async {
    try {
      final data = await _api.get(ApiEndpoints.specialtyById(id))
          as Map<String, dynamic>;
      return SpecialtyModel.fromJson(data);
    } on NotFoundException {
      return null;
    }
  }
}
