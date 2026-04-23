import '../entities/specialty_entity.dart';

abstract class SpecialtiesRepository {
  Future<List<SpecialtyEntity>> getSpecialties();
  Future<SpecialtyEntity?> getSpecialtyById(String id);
}
