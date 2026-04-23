import '../../domain/entities/specialty_entity.dart';

class SpecialtyModel extends SpecialtyEntity {
  const SpecialtyModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    super.colorHex,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      colorHex: json['color'] as String?,
    );
  }

  factory SpecialtyModel.fromMap(Map<String, dynamic> map) {
    return SpecialtyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      colorHex: map['color'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': colorHex,
    };
  }
}
