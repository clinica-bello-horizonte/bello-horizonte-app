import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? height;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 52.0;
    final buttonWidth = isFullWidth ? double.infinity : width;

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(buttonWidth ?? 0, buttonHeight),
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withAlpha(153),
          ),
          child: _buildChild(Colors.white),
        ),
      AppButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(buttonWidth ?? 0, buttonHeight),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
          ),
          child: _buildChild(Colors.white),
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(buttonWidth ?? 0, buttonHeight),
          ),
          child: _buildChild(AppColors.primary),
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: Size(buttonWidth ?? 0, buttonHeight),
          ),
          child: _buildChild(AppColors.primary),
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(buttonWidth ?? 0, buttonHeight),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: _buildChild(Colors.white),
        ),
    };
  }

  Widget _buildChild(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: contentColor,
        ),
      );
    }

    if (leadingIcon != null || trailingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 18, color: contentColor),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTextStyles.button.copyWith(color: contentColor)),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 18, color: contentColor),
          ],
        ],
      );
    }

    return Text(label, style: AppTextStyles.button.copyWith(color: contentColor));
  }
}
