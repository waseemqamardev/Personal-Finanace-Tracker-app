import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double responsiveValue(
      BuildContext context, {
        required double mobile,
        double? tablet,
        double? desktop,
      }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: responsiveValue(
        context,
        mobile: 16,
        tablet: 32,
        desktop: 64,
      ),
      vertical: responsiveValue(
        context,
        mobile: 8,
        tablet: 16,
        desktop: 24,
      ),
    );
  }

  static double responsiveFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile + 2,
      desktop: desktop ?? mobile + 4,
    );
  }

  static double responsiveIconSize(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 24,
      tablet: 28,
      desktop: 32,
    );
  }

  static double responsiveButtonHeight(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 50,
      tablet: 55,
      desktop: 60,
    );
  }
}