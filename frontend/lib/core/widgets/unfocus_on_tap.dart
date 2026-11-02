import 'package:flutter/material.dart';

/// Unfocuses active keyboard when the user taps outside form input fields.
/// Mandatory form ergonomics per AGENTS.md Section 3 (web-interface-guidelines).
class UnfocusOnTap extends StatelessWidget {
  final Widget child;

  const UnfocusOnTap({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}

