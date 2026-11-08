import 'package:flutter/material.dart';

/// Centralized Design Token Colors for IMPAL Smart ToDoList.
/// Adheres to AGENTS.md UI Art Director specifications and Figma token standards.
abstract class AppColors {
  // --- Surface & Background Palettes ---
  /// Main Scaffold background color (#282D37)
  static const Color bgPrimary = Color(0xFF282D37);

  /// Desktop outer container / backdrop (#1E222B)
  static const Color bgSecondary = Color(0xFF1E222B);

  /// Card, elevated containers, and bottom nav background (#323846)
  static const Color bgCard = Color(0xFF323846);

  /// Recessed pocket behind scooped navbar (#282D37)
  static const Color bgPocket = Color(0xFF282D37);

  /// Dialog outer container background (#282D37)
  static const Color bgDialog = Color(0xFF282D37);

  // --- Primary Brand Coral Accent ---
  /// Core brand primary action color (#FA6144)
  static const Color primary = Color(0xFFFA6144);

  /// Brand coral gradient start (#FF7253)
  static const Color primaryGradientStart = Color(0xFFFF7253);

  /// Brand coral gradient end (#FA6144)
  static const Color primaryGradientEnd = Color(0xFFFA6144);

  /// Header subtitle coral highlight (#FF7D65)
  static const Color primaryAccent = Color(0xFFFF7D65);

  /// Ongoing status badge & lecture accent coral (#FF826E)
  static const Color primaryLight = Color(0xFFFF826E);

  // --- Typography & Content Colors ---
  /// Pure white headings and high-emphasis text (#FFFFFF)
  static const Color textWhite = Colors.white;

  /// Secondary muted text, labels, and icons (#8E95A5)
  static const Color textMuted = Color(0xFF8E95A5);

  /// Subtle hint text, placeholders, and footer copyright (#6B7280)
  static const Color textSubtle = Color(0xFF6B7280);

  /// Body copy and readable descriptions (#D1D5DB)
  static const Color textBody = Color(0xFFD1D5DB);

  // --- Border & Divider Lines ---
  /// Standard structural card & dialog border line (#3B4150)
  static const Color borderSubtle = Color(0xFF3B4150);

  /// Inactive checkbox & field outline border (#4B5563)
  static const Color borderMedium = Color(0xFF4B5563);

  // --- Status & Category Semantics ---
  /// Ongoing schedule / active progress (#FF826E)
  static const Color statusOngoing = Color(0xFFFF826E);

  /// Completed schedule / success emerald (#10B981)
  static const Color statusCompleted = Color(0xFF10B981);

  /// Upcoming schedule slate gray (#8E95A5)
  static const Color statusUpcoming = Color(0xFF8E95A5);

  /// Error message, delete action, destructive alert (#EF4444)
  static const Color error = Color(0xFFEF4444);

  /// Warning badge (#F59E0B)
  static const Color warning = Color(0xFFF59E0B);

  /// Meeting / Team category accent (#4A90E2)
  static const Color categoryMeeting = Color(0xFF4A90E2);

  /// External / Other activity accent (#38EF7D)
  static const Color categoryExternal = Color(0xFF38EF7D);

  // --- Layered Shadow Tokens ---
  /// Floating active nav button glow shadow
  static const List<BoxShadow> primaryGlowShadow = [
    BoxShadow(
      color: Color(0x80FA6144),
      blurRadius: 18,
      spreadRadius: 1,
      offset: Offset(0, 6),
    ),
  ];

  /// Standard card elevated shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  /// Dialog modal deep elevation shadow
  static const List<BoxShadow> dialogShadow = [
    BoxShadow(
      color: Color(0x99000000),
      blurRadius: 35,
      offset: Offset(0, 18),
      spreadRadius: -4,
    ),
  ];
}

