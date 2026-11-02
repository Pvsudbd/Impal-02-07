import 'package:flutter/material.dart';

/// Skala dan template tipografi standar untuk IMPAL UI.
/// Lihat file `TYPOGRAPHY_GUIDE.md` untuk dokumentasi lengkap.
abstract class AppTypography {
  static const String fontFamily = 'Inter';

  // --- Headings ---
  static const TextStyle pageHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: Colors.white,
  );

  static const TextStyle pageSubHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Color(0xFFFF7D65),
  );

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: Color(0xFF8E95A5),
  );

  static const TextStyle dialogTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: Colors.white,
  );

  // --- Cards & Content ---
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.25,
    color: Colors.white,
  );

  static const TextStyle cardMeta = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
    color: Color(0xFF8E95A5),
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
  );

  // --- Buttons & Controls ---
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: Colors.white,
  );

  static const TextStyle dialogButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: Colors.white,
  );

  static const TextStyle filterPill = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.5,
    height: 1.0,
    letterSpacing: 0.1,
  );

  // --- Body & Descriptions ---
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: Color(0xFFD1D5DB),
  );

  // --- Notification Toast ---
  static const TextStyle notificationTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: Colors.white,
  );

  static const TextStyle notificationMessage = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: Color(0xFFD1D5DB),
  );
}
