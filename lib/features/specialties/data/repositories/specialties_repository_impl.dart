import '../../domain/entities/specialty_entity.dart';
import '../../domain/repositories/specialties_repository.dart';
import '../datasources/specialties_remote_datasource.dart';

class SpecialtiesRepositoryImpl implements SpecialtiesRepository {
  final SpecialtiesRemoteDatasource _datasource;
  SpecialtiesRepositoryImpl(this._datasource);

  @override
  Future<List<SpecialtyEntity>> getSpecialties() => _datasource.getAll();

  @override
  Future<SpecialtyEntity?> getSpecialtyById(String id) =>
      _datasource.getById(id);
}
