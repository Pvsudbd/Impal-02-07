import 'dart:async';
import 'package:flutter/material.dart';

/// Pixel-perfect modal dialog based on Figma design for Password Updated notification.
class PasswordUpdatedDialog extends StatefulWidget {
  final int autoCloseSeconds;
  final VoidCallback? onDismissed;

  const PasswordUpdatedDialog({
    super.key,
    this.autoCloseSeconds = 2,
    this.onDismissed,
  });

  /// Convenient helper to show this dialog as a centered modal with smooth entrance animation.
  static Future<void> show(
    BuildContext context, {
    int autoCloseSeconds = 2,
    VoidCallback? onComplete,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PasswordUpdatedDialog',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: PasswordUpdatedDialog(
            autoCloseSeconds: autoCloseSeconds,
            onDismissed: () {
              if (Navigator.canPop(ctx)) {
                Navigator.pop(ctx);
              }
            },
          ),
        ),
      ),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.90, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
    onComplete?.call();
  }

  @override
  State<PasswordUpdatedDialog> createState() => _PasswordUpdatedDialogState();
}

class _PasswordUpdatedDialogState extends State<PasswordUpdatedDialog>
    with SingleTickerProviderStateMixin {
  late int _secondsLeft;
  Timer? _countdownTimer;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.autoCloseSeconds;

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.autoCloseSeconds),
    );

    _progressController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        _closeDialog();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _closeDialog() {
    if (widget.onDismissed != null) {
      widget.onDismissed!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 336,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF323846),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF3B4150),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 35,
            offset: Offset(0, 25),
            spreadRadius: -5,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Green Success Icon
          Container(
            width: 60,
            height: 60,
            decoration: ShapeDecoration(
              color: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x5910B981),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                )
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Title
          const Text(
            'Password Updated!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.30,
            ),
          ),

          const SizedBox(height: 8),

          // Subtitle / Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Your credentials have been securely updated. You can now access your dashboard with the new password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Auto-closing countdown text
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Auto-closing in ',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
                TextSpan(
                  text: '${_secondsLeft}s',
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.40,
                  ),
                ),
                const TextSpan(
                  text: '...',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.40,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Animated bottom progress bar
          Container(
            width: 294,
            height: 3,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF27272A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                final progress = (1.0 - _progressController.value).clamp(0.0, 1.0);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 294 * progress,
                    height: 3,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias for backwards compatibility with Figma layer naming
typedef BackgroundBorderShadow = PasswordUpdatedDialog;