import 'package:flutter/material.dart';

/// Smooth, clean fade transition between authentication pages (Login <-> Register).
/// Completely eliminates horizontal/vertical sliding movement for an elegant, in-place crossfade.
class AuthFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool? fromRight;

  AuthFadeRoute({
    required this.page,
    this.fromRight,
    Duration duration = const Duration(milliseconds: 140),
    Duration reverseDuration = const Duration(milliseconds: 100),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
              child: child,
            );
          },
        );
}

/// Kept as an alias for backwards compatibility.
typedef AuthSlideFadeRoute<T> = AuthFadeRoute<T>;
