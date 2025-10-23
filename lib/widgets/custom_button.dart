import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive_utils.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: ResponsiveUtils.responsiveButtonHeight(context),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: textColor ?? Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: textColor ?? Colors.white,
            fontSize: ResponsiveUtils.responsiveFontSize(
              context,
              mobile: 16,
              tablet: 17,
            ),
          ),
        ),
      ),
    );
  }
}