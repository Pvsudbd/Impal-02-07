import 'package:flutter/material.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

/// Re-export PopUpPemberitahuan for convenience within the Team feature
export '../../common_widgets/pop_up_pemberitahuan.dart';

/// Specialized PopUp Pemberitahuan helpers for Team operations
/// follows the exact IMPAL notification template (Positive -> Green, Negative -> Orange)
class PopUpPemberitahuanTeam {
  /// Notifikasi ketika invite code berhasil disalin ke clipboard
  static void codeCopied(BuildContext context, {String? code}) {
    PopUpPemberitahuan.codeCopied(context, code: code);
  }

  /// Notifikasi ketika team berhasil dibuat
  static void teamCreated(
    BuildContext context, {
    required String teamName,
    String? inviteCode,
  }) {
    PopUpPemberitahuan.teamCreated(
      context,
      teamName: teamName,
      inviteCode: inviteCode,
    );
  }

  /// Notifikasi ketika berhasil bergabung ke team
  static void teamJoined(
    BuildContext context, {
    String? teamName,
    String? inviteCode,
  }) {
    PopUpPemberitahuan.teamJoined(
      context,
      teamName: teamName,
      inviteCode: inviteCode,
    );
  }

  /// Notifikasi peringatan / warning saat validasi form team
  static void warning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    PopUpPemberitahuan.teamWarning(
      context,
      title: title,
      message: message,
    );
  }
}
