import '../entities/doctor_entity.dart';

abstract class DoctorsRepository {
  Future<List<DoctorEntity>> getDoctors();
  Future<DoctorEntity?> getDoctorById(String id);
  Future<List<DoctorEntity>> getDoctorsBySpecialty(String specialtyId);
  Future<List<DoctorEntity>> searchDoctors(String query);
  Future<void> updateDoctor(DoctorEntity doctor);
}
