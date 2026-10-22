import 'package:flutter/material.dart';

/// Custom animated page route tailored for smooth authentication transitions.
/// Combines a subtle horizontal slide with an elegant fade transition,
/// avoiding harsh screen jumps or jarring 100% swipes on wide displays (Web/Desktop).
class AuthSlideFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool fromRight;

  AuthSlideFadeRoute({
    required this.page,
    this.fromRight = true,
    Duration duration = const Duration(milliseconds: 360),
    Duration reverseDuration = const Duration(milliseconds: 320),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            final beginOffset = fromRight
                ? const Offset(0.12, 0.0)
                : const Offset(-0.12, 0.0);

            return SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}
