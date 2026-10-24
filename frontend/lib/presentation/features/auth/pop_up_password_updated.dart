import 'dart:async';
import 'package:flutter/material.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

export '../../common_widgets/pop_up_pemberitahuan.dart';

/// Top pop-up notification matching IMPAL design system for Password Updated.
/// Slides down smoothly from the top with green (positif) styling and auto-dismisses.
class PasswordUpdatedDialog extends StatelessWidget {
  final int autoCloseSeconds;
  final VoidCallback? onDismissed;

  const PasswordUpdatedDialog({
    super.key,
    this.autoCloseSeconds = 2,
    this.onDismissed,
  });

  /// Displays the top pop-up notification confirming password has been updated.
  static Future<void> show(
    BuildContext context, {
    int autoCloseSeconds = 2,
    VoidCallback? onComplete,
  }) async {
    PopUpPemberitahuan.passwordUpdated(context);
    onComplete?.call();
    // Allow slight delay so the notification smoothly appears before route transition
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return PopUpPemberitahuan(
      title: 'Password Updated',
      message: 'Your password has been successfully updated.',
      icon: Icons.lock_reset_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor, // Hijau untuk hal positif
      onDismissed: onDismissed,
    );
  }
}

typedef BackgroundBorderShadow = PasswordUpdatedDialog;
typedef PopUpPasswordUpdated = PasswordUpdatedDialog;