import '../../domain/entities/doctor_entity.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.specialtyId,
    super.description,
    super.photoUrl,
    super.rating,
    super.yearsExperience,
    super.consultationFee,
    super.availableDays,
    required super.createdAt,
    super.userId,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final days = (json['availableDays'] as List?)
            ?.map((d) => (d as num).toInt())
            .toList() ??
        <int>[];
    return DoctorModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      specialtyId: json['specialtyId'] as String,
      description: json['description'] as String?,
      photoUrl: json['photoUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      yearsExperience: (json['yearsExperience'] as num?)?.toInt() ?? 0,
      consultationFee: (json['consultationFee'] as num?)?.toDouble() ?? 0,
      availableDays: days,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      userId: json['userId'] as String?,
    );
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    final daysStr = map['available_days'] as String? ?? '';
    final days = daysStr.isNotEmpty
        ? daysStr.split(',').map((d) => int.tryParse(d.trim()) ?? 0).toList()
        : <int>[];

    return DoctorModel(
      id: map['id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      specialtyId: map['specialty_id'] as String,
      description: map['description'] as String?,
      photoUrl: map['photo_url'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      yearsExperience: (map['years_experience'] as int?) ?? 0,
      consultationFee: (map['consultation_fee'] as num?)?.toDouble() ?? 0,
      availableDays: days,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'specialty_id': specialtyId,
      'description': description,
      'photo_url': photoUrl,
      'rating': rating,
      'years_experience': yearsExperience,
      'consultation_fee': consultationFee,
      'available_days': availableDays.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
