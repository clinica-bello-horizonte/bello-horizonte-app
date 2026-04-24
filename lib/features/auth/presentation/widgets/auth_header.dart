import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  final bool compact;
  const AuthHeader({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 44 : 56,
          height: compact ? 44 : 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(76),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.local_hospital_rounded,
            color: Colors.white,
            size: compact ? 24 : 30,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clínica',
              style: (compact ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium).copyWith(
                color: AppColors.textGray,
              ),
            ),
            Text(
              'Bello Horizonte',
              style: (compact ? AppTextStyles.h4 : AppTextStyles.h3).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
