import 'dart:async';
import 'package:flutter/material.dart';

/// Modal dialog shown when a schedule is deleted
class PopUpScheduleDeleted extends StatefulWidget {
  final String title;
  final String message;
  final int autoCloseSeconds;
  final VoidCallback? onDismissed;

  const PopUpScheduleDeleted({
    super.key,
    this.title = 'Schedule Deleted',
    this.message =
        'Your schedule has been deleted.\nSee your changes on your Schedule page.',
    this.autoCloseSeconds = 2,
    this.onDismissed,
  });

  /// Convenient helper to show this dialog with smooth animation and auto-close
  static Future<void> show(
    BuildContext context, {
    String title = 'Schedule Deleted',
    String message =
        'Your schedule has been deleted.\nSee your changes on your Schedule page.',
    int autoCloseSeconds = 2,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PopUpScheduleDeleted',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: PopUpScheduleDeleted(
            title: title,
            message: message,
            autoCloseSeconds: autoCloseSeconds,
            onDismissed: () {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
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
  }

  @override
  State<PopUpScheduleDeleted> createState() => _PopUpScheduleDeletedState();
}

class _PopUpScheduleDeletedState extends State<PopUpScheduleDeleted> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoCloseSeconds > 0) {
      _timer = Timer(Duration(seconds: widget.autoCloseSeconds), () {
        if (mounted) {
          widget.onDismissed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 336,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xFF323846),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B4150), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 35,
            offset: Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFA6144),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55FA6144),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA6144),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.onDismissed?.call();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}