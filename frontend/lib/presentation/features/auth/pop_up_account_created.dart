import 'dart:async';
import 'package:flutter/material.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';

export '../../common_widgets/pop_up_pemberitahuan.dart';

/// Top pop-up notification matching IMPAL design system for Account Created.
/// Slides down smoothly from the top with green (positif) styling and auto-dismisses.
class AccountCreatedDialog extends StatelessWidget {
  final String? name;
  final String? email;
  final int autoCloseSeconds;
  final VoidCallback? onDismissed;

  const AccountCreatedDialog({
    super.key,
    this.name,
    this.email,
    this.autoCloseSeconds = 2,
    this.onDismissed,
  });

  /// Displays the top pop-up notification confirming account creation.
  static Future<void> show(
    BuildContext context, {
    String? name,
    String? email,
    int autoCloseSeconds = 2,
    VoidCallback? onComplete,
  }) async {
    PopUpPemberitahuan.accountCreated(context, name: name);
    onComplete?.call();
    // Allow slight delay so the notification smoothly appears before route transition
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return PopUpPemberitahuan(
      title: 'Account Created',
      message: name != null && name!.trim().isNotEmpty
          ? 'Welcome, $name! Your account has been successfully created.'
          : 'Your account has been successfully registered.',
      icon: Icons.person_add_alt_1_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor, // Hijau untuk hal positif
      onDismissed: onDismissed,
    );
  }
}

typedef PopUpAccountCreated = AccountCreatedDialog;
