import 'dart:async';
import 'package:flutter/material.dart';

/// Reusable top pop-up notification matching the sleek IMPAL design system.
/// Drops down smoothly from the top, displays a colored icon badge:
/// - POSITIF -> Hijau (0xFF10B981)
/// - NEGATIF / WARNING -> Orange (0xFFFA6144)
/// Title, message, and auto-dismisses after a short duration.
class PopUpPemberitahuan extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconBgColor;
  final Duration duration;
  final VoidCallback? onDismissed;

  const PopUpPemberitahuan({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline_rounded,
    this.iconBgColor = positiveColor,
    this.duration = const Duration(milliseconds: 2800),
    this.onDismissed,
  });

  // Standard color constants based on user rules
  static const Color positiveColor = Color(0xFF10B981); // Hijau untuk hal positif
  static const Color negativeColor = Color(0xFFFA6144); // Orange untuk hal negatif/warning

  static OverlayEntry? _activeEntry;
  static _PopUpPemberitahuanWidgetState? _activeState;

  /// General helper to display the top notification pop-up.
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle_outline_rounded,
    Color iconBgColor = positiveColor,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    _removeEntry();

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (ctx) => _PopUpPemberitahuanWidget(
        title: title,
        message: message,
        icon: icon,
        iconBgColor: iconBgColor,
        duration: duration,
        onDismissed: () {
          if (entry != null && entry.mounted) {
            try {
              entry.remove();
            } catch (_) {}
          }
          if (_activeEntry == entry) {
            _activeEntry = null;
            _activeState = null;
          }
        },
        onStateReady: (state) {
          _activeState = state;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  // --- Sentiment Helpers ---

  /// Helper untuk notifikasi sukses / positif (Hijau)
  static void success(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle_outline_rounded,
  }) {
    show(
      context,
      title: title,
      message: message,
      icon: icon,
      iconBgColor: positiveColor,
    );
  }

  /// Helper untuk notifikasi warning / peringatan (Orange)
  static void warning(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.warning_amber_rounded,
  }) {
    show(
      context,
      title: title,
      message: message,
      icon: icon,
      iconBgColor: negativeColor,
    );
  }

  /// Helper untuk notifikasi error / negatif (Orange)
  static void error(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.error_outline_rounded,
  }) {
    show(
      context,
      title: title,
      message: message,
      icon: icon,
      iconBgColor: negativeColor,
    );
  }

  // --- Schedule Preset Notifications ---

  /// Preset notification when a schedule is created (Positif -> Hijau).
  static void scheduleCreated(BuildContext context) {
    show(
      context,
      title: 'Schedule Created',
      message: 'Your schedule has been successfully created.',
      icon: Icons.calendar_month_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when a schedule is updated (Positif -> Hijau).
  static void scheduleUpdated(BuildContext context) {
    show(
      context,
      title: 'Schedule Updated',
      message: 'Your schedule has been successfully updated.',
      icon: Icons.check_circle_outline_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when a schedule is deleted (Negatif -> Orange).
  static void scheduleDeleted(BuildContext context) {
    show(
      context,
      title: 'Schedule Deleted',
      message: 'Your schedule has been successfully removed.',
      icon: Icons.delete_outline_rounded,
      iconBgColor: negativeColor,
    );
  }

  // --- Auth Preset Notifications ---

  /// Preset notification when an account is registered (Positif -> Hijau).
  static void accountCreated(BuildContext context, {String? name}) {
    show(
      context,
      title: 'Account Created',
      message: name != null && name.trim().isNotEmpty
          ? 'Welcome, $name! Your account has been successfully created.'
          : 'Your account has been successfully registered.',
      icon: Icons.person_add_alt_1_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when password has been successfully updated (Positif -> Hijau).
  static void passwordUpdated(BuildContext context) {
    show(
      context,
      title: 'Password Updated',
      message: 'Your password has been successfully updated.',
      icon: Icons.lock_reset_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when recovery code has been sent (Positif -> Hijau).
  static void recoveryCodeSent(BuildContext context, {String? destination}) {
    show(
      context,
      title: 'Recovery Code Sent',
      message: destination != null && destination.trim().isNotEmpty
          ? 'Recovery code has been sent to $destination.'
          : 'Recovery code has been sent to your email.',
      icon: Icons.mark_email_read_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when reset code is correct / verified (Positif -> Hijau).
  static void codeVerified(BuildContext context) {
    show(
      context,
      title: 'Code Verified',
      message: 'Verification code confirmed successfully.',
      icon: Icons.verified_rounded,
      iconBgColor: positiveColor,
    );
  }

  /// Preset notification when user hasn't agreed to Terms & Privacy Policy (Negatif/Warning -> Orange).
  static void termsWarning(BuildContext context) {
    show(
      context,
      title: 'Terms & Privacy Policy',
      message: 'Please read and agree to the Terms of Service & Privacy Policy first.',
      icon: Icons.warning_amber_rounded,
      iconBgColor: negativeColor,
    );
  }

  /// Preset notification when user successfully logs in (Positif -> Hijau).
  static void loginSuccess(BuildContext context, {String? username}) {
    final displayName =
        username != null && username.trim().isNotEmpty ? username.trim() : 'User';
    show(
      context,
      title: 'Login Successful',
      message: 'Welcome back, $displayName!',
      icon: Icons.check_circle_outline_rounded,
      iconBgColor: positiveColor,
    );
  }

  static void _removeEntry() {
    if (_activeState != null && _activeState!.mounted) {
      _activeState!.dismiss();
    } else if (_activeEntry != null) {
      try {
        if (_activeEntry!.mounted) {
          _activeEntry!.remove();
        }
      } catch (_) {}
      _activeEntry = null;
      _activeState = null;
    }
  }

  @override
  State<PopUpPemberitahuan> createState() => _PopUpPemberitahuanState();
}

class _PopUpPemberitahuanState extends State<PopUpPemberitahuan> {
  @override
  Widget build(BuildContext context) {
    return _buildNotificationCard(
      title: widget.title,
      message: widget.message,
      icon: widget.icon,
      iconBgColor: widget.iconBgColor,
      onClose: widget.onDismissed,
    );
  }
}

class _PopUpPemberitahuanWidget extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconBgColor;
  final Duration duration;
  final VoidCallback onDismissed;
  final ValueChanged<_PopUpPemberitahuanWidgetState> onStateReady;

  const _PopUpPemberitahuanWidget({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconBgColor,
    required this.duration,
    required this.onDismissed,
    required this.onStateReady,
  });

  @override
  State<_PopUpPemberitahuanWidget> createState() =>
      _PopUpPemberitahuanWidgetState();
}

class _PopUpPemberitahuanWidgetState extends State<_PopUpPemberitahuanWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  Timer? _timer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    widget.onStateReady(this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _animController.forward();

    _timer = Timer(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _timer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 14,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: dismiss,
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null &&
                        details.primaryVelocity! < 0) {
                      dismiss();
                    }
                  },
                  child: _buildNotificationCard(
                    title: widget.title,
                    message: widget.message,
                    icon: widget.icon,
                    iconBgColor: widget.iconBgColor,
                    onClose: dismiss,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNotificationCard({
  required String title,
  required String message,
  required IconData icon,
  required Color iconBgColor,
  VoidCallback? onClose,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF323846),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFF3B4150),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 20,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ],
    ),
    child: Row(
      children: [
        // Brand icon badge: Hijau (Positif) atau Orange (Negatif)
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: iconBgColor.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Title and description
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Close button
        if (onClose != null)
          InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.close_rounded,
                color: Color(0xFF8E95A5),
                size: 18,
              ),
            ),
          ),
      ],
    ),
  );
}
