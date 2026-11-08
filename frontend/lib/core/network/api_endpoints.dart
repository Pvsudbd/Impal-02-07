import 'package:flutter/foundation.dart';

/// Centralized API Endpoints and Adaptive Base URL configuration
/// for Dart Frog & PostgreSQL backend.
///
/// Adheres to AGENTS.md Section 6 domain kapling specifications:
/// - Dev 1 (Valen): Auth, Employees, Shifts, Attendances, Schedules
/// - Dev 2 (Royul): Marketing, Upload
/// - Dev 3: Leaves, Overtimes, Reports
abstract class ApiEndpoints {
  /// Adaptive Base URL:
  /// - Android Emulator requires `http://10.0.2.2:8080`
  /// - iOS Simulator, Chrome Web, Windows Desktop use `http://localhost:8080`
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8080';
    }
  }

  // --- DEV 1 (Valen): Auth, Employees, Shifts, Attendances, Schedules ---
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authProfile = '/api/v1/auth/profile';
  static const String employees = '/api/v1/employees';
  static const String shifts = '/api/v1/shifts';
  static const String attendances = '/api/v1/attendances';
  static const String schedules = '/api/v1/schedules';

  // --- DEV 3 (Leaves & HRD): Leaves, Overtimes, Reports ---
  static const String leaves = '/api/v1/leaves';
  static const String leaveApproval = '/api/v1/leaves/approve';
  static const String overtimes = '/api/v1/overtimes';
  static const String reports = '/api/v1/reports';

  // --- DEV 2 (Royul): Marketing & Upload ---
  static const String marketing = '/api/v1/marketing';
  static const String upload = '/api/v1/upload';
}

