import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctors_repository.dart';
import '../datasources/doctors_remote_datasource.dart';
import '../models/doctor_model.dart';

class DoctorsRepositoryImpl implements DoctorsRepository {
  final DoctorsRemoteDatasource _datasource;
  DoctorsRepositoryImpl(this._datasource);

  @override
  Future<List<DoctorEntity>> getDoctors() => _datasource.getAll();

  @override
  Future<DoctorEntity?> getDoctorById(String id) => _datasource.getById(id);

  @override
  Future<List<DoctorEntity>> getDoctorsBySpecialty(String specialtyId) =>
      _datasource.getBySpecialty(specialtyId);

  @override
  Future<List<DoctorEntity>> searchDoctors(String query) =>
      _datasource.search(query);

  @override
  Future<void> updateDoctor(DoctorEntity doctor) => _datasource.update(
        DoctorModel(
          id: doctor.id,
          firstName: doctor.firstName,
          lastName: doctor.lastName,
          specialtyId: doctor.specialtyId,
          description: doctor.description,
          photoUrl: doctor.photoUrl,
          rating: doctor.rating,
          yearsExperience: doctor.yearsExperience,
          consultationFee: doctor.consultationFee,
          availableDays: doctor.availableDays,
          createdAt: doctor.createdAt,
        ),
      );
}
