import 'package:flutter/material.dart';

/// Smooth, clean fade transition between authentication pages (Login <-> Register).
/// Completely eliminates horizontal/vertical sliding movement for an elegant, in-place crossfade.
class AuthFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool? fromRight;

  AuthFadeRoute({
    required this.page,
    this.fromRight,
    Duration duration = const Duration(milliseconds: 250),
    Duration reverseDuration = const Duration(milliseconds: 200),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeInOut,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
}

/// Kept as an alias for backwards compatibility.
typedef AuthSlideFadeRoute<T> = AuthFadeRoute<T>;
