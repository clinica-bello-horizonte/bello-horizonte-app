import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String specialtyId;
  final String? description;
  final String? photoUrl;
  final double rating;
  final int yearsExperience;
  final double consultationFee;
  final List<int> availableDays;
  final DateTime createdAt;

  const DoctorEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialtyId,
    this.description,
    this.photoUrl,
    this.rating = 0,
    this.yearsExperience = 0,
    this.consultationFee = 0,
    this.availableDays = const [],
    required this.createdAt,
  });

  String get fullName => 'Dr. $firstName $lastName';
  String get shortName => 'Dr. $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  String get availabilityText {
    const dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    if (availableDays.isEmpty) return 'Sin horario';
    return availableDays.map((d) => dayNames[d]).join(', ');
  }

  bool isAvailableOn(int weekday) => availableDays.contains(weekday);

  @override
  List<Object?> get props => [id, firstName, lastName, specialtyId];
}
