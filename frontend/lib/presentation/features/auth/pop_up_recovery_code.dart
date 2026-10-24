import 'dart:async';
import 'package:flutter/material.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

export '../../common_widgets/pop_up_pemberitahuan.dart';

/// Top pop-up notification matching IMPAL design system for Recovery Code Sent.
/// Slides down smoothly from the top with green (positif) styling and auto-dismisses.
class RecoveryCodeSentDialog extends StatelessWidget {
  final String destination;
  final int autoCloseSeconds;
  final VoidCallback? onDismissed;

  const RecoveryCodeSentDialog({
    super.key,
    this.destination = 'yogaperkakas@gmail.com',
    this.autoCloseSeconds = 2,
    this.onDismissed,
  });

  /// Displays the top pop-up notification confirming recovery code was sent.
  static Future<void> show(
    BuildContext context, {
    required String destination,
    int autoCloseSeconds = 2,
    VoidCallback? onComplete,
  }) async {
    PopUpPemberitahuan.recoveryCodeSent(context, destination: destination);
    onComplete?.call();
    // Allow slight delay so the notification smoothly appears before route transition
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return PopUpPemberitahuan(
      title: 'Recovery Code Sent',
      message: destination.trim().isNotEmpty
          ? 'Recovery code has been sent to $destination.'
          : 'Recovery code has been sent to your email.',
      icon: Icons.mark_email_read_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor, // Hijau untuk hal positif
      onDismissed: onDismissed,
    );
  }
}

typedef BackgroundBorderShadow = RecoveryCodeSentDialog;
typedef PopUpRecoveryCode = RecoveryCodeSentDialog;