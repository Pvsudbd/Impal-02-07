import 'package:flutter/material.dart';

/// Standard brand header for authentication pages.
/// Displays signature IMPAL glowing brand container, title, and descriptive subtitle.
class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? iconWidget;
  final double bottomSpacing;
  final bool alignStart;

  const AuthBrandHeader({
    super.key,
    this.title = 'Smart Task Manager',
    this.subtitle = 'AI-Driven Academic Task & Schedule\nPrioritization System',
    this.iconWidget,
    this.bottomSpacing = 32.0,
    this.alignStart = false,
  });

  @override
  Widget build(BuildContext context) {
    final crossAlign =
        alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = alignStart ? TextAlign.left : TextAlign.center;

    return SizedBox(
      width: alignStart ? double.infinity : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAlign,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: ShapeDecoration(
              color: const Color(0xFFFA6144),
              shape: RoundedRectangleBorder(
                side: alignStart
                    ? BorderSide(
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.15),
                      )
                    : BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x59EF4444),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: iconWidget ??
                (alignStart
                    ? const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 30,
                      )
                    : const Text(
                        '⚡',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      )),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: textAlign,
            style: TextStyle(
              color: Colors.white,
              fontSize: alignStart ? 26 : 24,
              fontFamily: 'Inter',
              fontWeight: alignStart ? FontWeight.w700 : FontWeight.w800,
              letterSpacing: alignStart ? -0.65 : -0.50,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: textAlign,
            style: TextStyle(
              color: alignStart
                  ? const Color(0xFF8E95A5)
                  : const Color(0xFF9CA3AF),
              fontSize: alignStart ? 13.5 : 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.45,
            ),
          ),
          SizedBox(height: bottomSpacing),
        ],
      ),
    );
  }
}

