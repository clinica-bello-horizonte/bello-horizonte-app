import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/doctor_model.dart';

class DoctorsRemoteDatasource {
  final ApiClient _api;
  DoctorsRemoteDatasource(this._api);

  Future<List<DoctorModel>> getAll() async {
    final data = await _api.get(ApiEndpoints.doctors) as List;
    return data
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DoctorModel?> getById(String id) async {
    try {
      final data =
          await _api.get(ApiEndpoints.doctorById(id)) as Map<String, dynamic>;
      return DoctorModel.fromJson(data);
    } on NotFoundException {
      return null;
    }
  }

  Future<List<DoctorModel>> getBySpecialty(String specialtyId) async {
    final data = await _api.get(
      ApiEndpoints.doctors,
      queryParameters: {'specialtyId': specialtyId},
    ) as List;
    return data
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DoctorModel>> search(String query) async {
    final data = await _api.get(
      ApiEndpoints.doctors,
      queryParameters: {'search': query},
    ) as List;
    return data
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(DoctorModel doctor) async {
    await _api.patch(ApiEndpoints.doctorById(doctor.id), body: {
      'firstName': doctor.firstName,
      'lastName': doctor.lastName,
      'specialtyId': doctor.specialtyId,
      'description': doctor.description,
      'yearsExperience': doctor.yearsExperience,
      'consultationFee': doctor.consultationFee,
      'availableDays': doctor.availableDays,
    });
  }
}
