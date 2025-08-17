import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 6;
    if (width >= tabletBreakpoint) return 4;
    if (width >= mobileBreakpoint) return 3;
    return 2;
  }

  static int getItemListColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletBreakpoint) return 3;
    if (width >= mobileBreakpoint) return 2;
    return 1;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 12;
    return 8;
  }

  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double getTitleFontSize(BuildContext context) {
    if (isDesktop(context)) return 28;
    if (isTablet(context)) return 24;
    return 22;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isDesktop(context)) return 18;
    if (isTablet(context)) return 17;
    return 16;
  }

  static double getSmallFontSize(BuildContext context) {
    if (isDesktop(context)) return 14;
    if (isTablet(context)) return 13;
    return 12;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static EdgeInsets getCardPadding(BuildContext context) {
    final horizontal = isDesktop(context) ? 24.0 : isTablet(context) ? 20.0 : 16.0;
    final vertical = isDesktop(context) ? 20.0 : isTablet(context) ? 16.0 : 12.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static double getIconSize(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 22;
    return 20;
  }

  static double getNavigationRailWidth(BuildContext context) {
    if (isDesktop(context)) return 280;
    return 200;
  }
}