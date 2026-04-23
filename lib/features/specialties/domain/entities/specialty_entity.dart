import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SpecialtyEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? colorHex;

  const SpecialtyEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.colorHex,
  });

  Color get color {
    if (colorHex == null) return AppColors.primary;
    try {
      return Color(int.parse(colorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData get iconData {
    return switch (icon) {
      'heart' => Icons.favorite_rounded,
      'stethoscope' => Icons.medical_services_rounded,
      'baby' => Icons.child_care_rounded,
      'brain' => Icons.psychology_rounded,
      'bone' => Icons.accessibility_new_rounded,
      'skin' => Icons.face_rounded,
      'child' => Icons.child_friendly_rounded,
      'eye' => Icons.visibility_rounded,
      'kidney' => Icons.water_drop_rounded,
      'stomach' => Icons.fiber_manual_record_rounded,
      'hormone' => Icons.science_rounded,
      'tooth' => Icons.masks_rounded,
      _ => Icons.local_hospital_rounded,
    };
  }

  @override
  List<Object?> get props => [id, name, description, icon, colorHex];
}
