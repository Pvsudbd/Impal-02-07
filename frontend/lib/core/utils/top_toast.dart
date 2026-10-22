import 'dart:async';
import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class TopToast {
  static OverlayEntry? _activeEntry;
  static _TopToastWidgetState? _activeState;
  static String? _lastMessage;
  static DateTime? _lastShownTime;

  /// Display a top notification pop-up.
  /// Guarantees that toasts NEVER stack or overlap, and throttles duplicate messages.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    final now = DateTime.now();

    // Anti-spam debounce: suppress identical message spammed within 1.5 seconds
    if (_lastMessage == message &&
        _lastShownTime != null &&
        now.difference(_lastShownTime!) < const Duration(milliseconds: 1500)) {
      return;
    }

    _lastMessage = message;
    _lastShownTime = now;

    // Immediately dismiss & remove any previous toast so they NEVER stack
    _removeEntry();

    final overlay = Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopToastWidget(
        key: UniqueKey(),
        message: message,
        type: type,
        customBackgroundColor: backgroundColor,
        customIcon: icon,
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

  /// Instantly dismiss any currently active toast.
  static void dismiss() {
    if (_activeState != null && _activeState!.mounted) {
      _activeState!.dismiss();
    } else {
      _removeEntry();
    }
  }

  static void _removeEntry() {
    if (_activeEntry != null) {
      try {
        if (_activeEntry!.mounted) {
          _activeEntry!.remove();
        }
      } catch (_) {}
      _activeEntry = null;
    }
    _activeState = null;
  }
}

class _TopToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Color? customBackgroundColor;
  final IconData? customIcon;
  final Duration duration;
  final VoidCallback onDismissed;
  final ValueChanged<_TopToastWidgetState> onStateReady;

  const _TopToastWidget({
    super.key,
    required this.message,
    required this.type,
    this.customBackgroundColor,
    this.customIcon,
    required this.duration,
    required this.onDismissed,
    required this.onStateReady,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
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
      duration: const Duration(milliseconds: 250),
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

    final (Color defaultBg, IconData defaultIcon) = switch (widget.type) {
      ToastType.error => (const Color(0xFFEF4444), Icons.error_outline_rounded),
      ToastType.warning => (const Color(0xFFF59E0B), Icons.warning_amber_rounded),
      ToastType.success => (const Color(0xFF10B981), Icons.check_circle_outline_rounded),
      ToastType.info => (const Color(0xFFFA6144), Icons.info_outline_rounded),
    };

    final bgColor = widget.customBackgroundColor ?? defaultBg;
    final iconData = widget.customIcon ?? defaultIcon;

    return Positioned(
      top: topPadding + 16,
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
                    if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                      dismiss();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconData, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: dismiss,
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                          ),
                        ),
                      ],
                    ),
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

/// Convenience function to show a top toast notification.
void showTopToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  bool? isError,
  Color? backgroundColor,
  IconData? icon,
  Duration duration = const Duration(milliseconds: 2800),
}) {
  final resolvedType = isError == true
      ? ToastType.error
      : (isError == false && type == ToastType.error ? ToastType.info : type);

  TopToast.show(
    context,
    message: message,
    type: resolvedType,
    backgroundColor: backgroundColor,
    icon: icon,
    duration: duration,
  );
}

/// Dismiss any active top toast notification.
void dismissTopToast() {
  TopToast.dismiss();
}
