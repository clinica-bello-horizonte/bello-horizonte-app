import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/doctor_entity.dart';

class DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback onTap;
  final String? specialtyName;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.specialtyName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.fullName, style: AppTextStyles.cardTitle),
                  if (specialtyName != null) ...[
                    const SizedBox(height: 2),
                    Text(specialtyName!, style: AppTextStyles.cardSubtitle),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRating(),
                      const SizedBox(width: 12),
                      _buildExperience(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textGray),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.availabilityText,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'S/ ${doctor.consultationFee.toStringAsFixed(0)}',
                  style: AppTextStyles.price.copyWith(fontSize: 15),
                ),
                Text('consulta', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          doctor.initials,
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
        const SizedBox(width: 3),
        Text(
          doctor.rating.toStringAsFixed(1),
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExperience() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.work_outline_rounded, size: 13, color: AppColors.textGray),
        const SizedBox(width: 3),
        Text(
          '${doctor.yearsExperience} años',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
