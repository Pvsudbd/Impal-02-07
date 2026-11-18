import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Extension on [BuildContext] providing studio-grade responsive layout calculations,
/// fluid typography, adaptive spacing, and low-end device optimization helpers.
///
/// Complies with AGENTS.md Section 1 & Section 3 requirements.
extension ResponsiveContext on BuildContext {
  /// Reference screen width based on standard mobile viewport (iPhone 14 / Pixel 7: 390dp)
  static const double _baseScreenWidth = 390.0;

  /// Retrieves the current screen size safely.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width in logical pixels.
  double get screenWidth => screenSize.width;

  /// Screen height in logical pixels.
  double get screenHeight => screenSize.height;

  /// True if current screen is classified as mobile (< 600dp).
  bool get isMobile => screenWidth < 600.0;

  /// True if current screen is classified as tablet (600dp - 1023dp).
  bool get isTablet => screenWidth >= 600.0 && screenWidth < 1024.0;

  /// True if current screen is classified as desktop/web (>= 1024dp).
  bool get isDesktop => screenWidth >= 1024.0;

  /// Check whether animations should be disabled for motion-sensitive users.
  bool get animationsDisabled => MediaQuery.disableAnimationsOf(this);

  /// Adaptive Font Sizing:
  /// Scales base font size according to screen width while enforcing [min] and [max] bounds
  /// to ensure readability across low-end compact phones to tablets.
  ///
  /// Example:
  /// ```dart
  /// fontSize: context.rFont(16, min: 14, max: 20)
  /// ```
  double rFont(double base, {double? min, double? max}) {
    // Clamp width ratio to prevent extreme scale on wide screens
    final effectiveWidth = screenWidth.clamp(320.0, 480.0);
    final scale = effectiveWidth / _baseScreenWidth;
    final calculated = base * scale;

    final lowerBound = min ?? (base * 0.85);
    final upperBound = max ?? (base * 1.25);
    return calculated.clamp(lowerBound, upperBound);
  }

  /// Adaptive Spacing & Gaps:
  /// Scales padding, margin, or gap dimensions based on viewport width.
  ///
  /// Example:
  /// ```dart
  /// SizedBox(height: context.rSpacing(24))
  /// ```
  double rSpacing(double base) {
    if (screenWidth <= 360.0) {
      return base * 0.9;
    } else if (screenWidth >= 600.0) {
      return base * 1.15;
    }
    return base;
  }

  /// Adaptive Icon Sizing:
  /// Scales icon dimensions proportionally without clipping.
  ///
  /// Example:
  /// ```dart
  /// Icon(Icons.star, size: context.rIcon(24))
  /// ```
  double rIcon(double base) {
    if (screenWidth <= 360.0) {
      return math.max(16.0, base - 2.0);
    } else if (screenWidth >= 600.0) {
      return base + 2.0;
    }
    return base;
  }

  /// Adaptive Logo & Banner Dimensions:
  /// Calculates size as a percentage of screen width within [minWidth] and [maxWidth].
  ///
  /// Example:
  /// ```dart
  /// double logoW = context.rLogo(percentWidth: 0.35, minWidth: 100, maxWidth: 200);
  /// ```
  double rLogo({
    double percentWidth = 0.35,
    double minWidth = 100.0,
    double maxWidth = 200.0,
  }) {
    final calculated = screenWidth * percentWidth;
    return calculated.clamp(minWidth, maxWidth);
  }

  /// Nested Border Radius Formula:
  /// Computes mathematically concentric inner radius based on outer container radius and padding:
  /// $$r_{inner} = r_{outer} - padding$$
  ///
  /// Prevents visual distortion when curved containers nest inside other curved containers.
  double nestedRadius(double outerRadius, double padding) {
    return math.max(0.0, outerRadius - padding);
  }

  /// Quick vertical spacing gap helper
  Widget vGap(double base) => SizedBox(height: rSpacing(base));

  /// Quick horizontal spacing gap helper
  Widget hGap(double base) => SizedBox(width: rSpacing(base));
}

