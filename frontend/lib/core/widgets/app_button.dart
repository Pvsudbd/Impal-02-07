import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive_context.dart';

/// Standard interactive button conforming to AGENTS.md and web-interface-guidelines:
/// 1. MUST retain the original label text alongside spinner when [isLoading] is true.
/// 2. MUST disable interaction when submitting to prevent double-submits.
/// 3. Provides 60 FPS subtle press/bounce feedback via [AnimatedScale].
/// 4. Respects reduced motion settings.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Widget? suffixIcon;
  final double? width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height = 48.0,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(12.0);
    final disableMotion = context.animationsDisabled;

    return AnimatedScale(
      scale: (_isPressed && _isEnabled && !disableMotion) ? 0.98 : 1.0,
      duration: disableMotion ? Duration.zero : const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: _isEnabled ? widget.onPressed : null,
          onHighlightChanged: (highlighted) {
            if (_isEnabled && !disableMotion) {
              setState(() => _isPressed = highlighted);
            }
          },
          child: Ink(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: _isEnabled
                  ? widget.backgroundColor
                  : widget.backgroundColor.withValues(alpha: 0.6),
              borderRadius: effectiveRadius,
              boxShadow: _isEnabled
                  ? [
                      BoxShadow(
                        color: widget.backgroundColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ] else if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  // Label text is strictly retained per web-interface-guidelines
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: context.rFont(14, min: 13, max: 16),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                  if (widget.suffixIcon != null && !widget.isLoading) ...[
                    const SizedBox(width: 8),
                    widget.suffixIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

