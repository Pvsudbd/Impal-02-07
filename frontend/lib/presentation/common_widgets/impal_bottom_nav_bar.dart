import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable Standard Bottom Navigation Bar for IMPAL Smart Task Manager.
///
/// Features the signature scooped bar with a protruding coral circle button
/// nested seamlessly in the concentric cutout. Used across all primary views
/// (Home, Task, Team/Kelompok, and Schedule) to ensure 100% design consistency.
class ImpalBottomNavBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;
  final Color barColor;
  final Color pocketColor;

  const ImpalBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
    this.barColor = const Color(0xFF323846),
    this.pocketColor = const Color(0xFF282D37),
  });

  static const double barTop = 26.0;
  static const double circleTop = 2.0;
  static const double circleDiameter = 54.0;
  static const double circleRadius = circleDiameter / 2; // 27.0
  static const double circleCenterY = circleTop + circleRadius; // 29.0
  static const double gap = 6.0; // 6px gap wider than the circle
  static const double notchRadius = circleRadius + gap; // 33.0

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final totalHeight = barTop + 68.0 + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: currentTab.toDouble()),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        builder: (context, animValue, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final tabWidth = width / 4;
              final activeCenterX = (animValue + 0.5) * tabWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Scooped Navbar Background
                  CustomPaint(
                    size: Size(width, totalHeight),
                    painter: _ScoopedNavBarPainter(
                      centerX: activeCenterX,
                      barTop: barTop,
                      circleCenterY: circleCenterY,
                      notchRadius: notchRadius,
                      barColor: barColor,
                      pocketColor: pocketColor,
                    ),
                  ),

                  // 2. Inactive Tab Icons
                  Positioned(
                    left: 0,
                    right: 0,
                    top: barTop,
                    height: 68.0,
                    child: Row(
                      children: List.generate(4, (index) {
                        final tabDistance = (animValue - index).abs();
                        final opacity = tabDistance.clamp(0.0, 1.0);

                        return Expanded(
                          child: InkWell(
                            key: ValueKey('impal_nav_tab_$index'),
                            onTap: () => onTabSelected(index),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Center(
                              child: Opacity(
                                opacity: opacity,
                                child: Icon(
                                  _getInactiveIcon(index),
                                  color: const Color(0xFF8E95A5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // 3. Protruding Floating Coral Circle Button (nestled in scoop)
                  Positioned(
                    left: activeCenterX - circleRadius,
                    top: 2.0,
                    child: GestureDetector(
                      key: const ValueKey('impal_nav_floating_button'),
                      onTap: () => onTabSelected(currentTab),
                      child: Container(
                        width: circleDiameter,
                        height: circleDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFF7253),
                              Color(0xFFFA6144),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFA6144).withValues(alpha: 0.50),
                              blurRadius: 18,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            ),
                            child: Icon(
                              _getActiveIcon(currentTab),
                              key: ValueKey<int>(currentTab),
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static IconData _getActiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.checklist_rounded;
      case 2:
        return Icons.groups_rounded;
      case 3:
      default:
        return Icons.calendar_month_rounded;
    }
  }

  static IconData _getInactiveIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.checklist_rounded;
      case 2:
        return Icons.groups_outlined;
      case 3:
      default:
        return Icons.calendar_month_outlined;
    }
  }
}

class _ScoopedNavBarPainter extends CustomPainter {
  final double centerX;
  final double barTop;
  final double circleCenterY;
  final double notchRadius;
  final Color barColor;
  final Color pocketColor;

  const _ScoopedNavBarPainter({
    required this.centerX,
    required this.barTop,
    required this.circleCenterY,
    required this.notchRadius,
    required this.barColor,
    required this.pocketColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 0;
    final double right = size.width;
    final double top = barTop;
    final double bottom = size.height;
    const double cr = 5.0; // 5 px corner radius on top navbar edges

    final double rNotch = notchRadius; // 33.0 (concentric to 27.0 radius circle, exactly 6px gap)
    const double rShoulder = 10.0; // smooth, gentle shoulder transition radius
    final double dY = (top + rShoulder) - circleCenterY;
    final double distSq = (rNotch + rShoulder) * (rNotch + rShoulder) - dY * dY;
    final double dX = distSq > 0 ? math.sqrt(distSq) : rNotch;

    final double ratio = rNotch / (rNotch + rShoulder);
    final Offset pTanLeft = Offset(centerX - dX * ratio, circleCenterY + dY * ratio);
    final Offset pTanRight = Offset(centerX + dX * ratio, circleCenterY + dY * ratio);
    final double leftShoulderX = (centerX - dX).clamp(left + cr, right - cr);
    final double rightShoulderX = (centerX + dX).clamp(left + cr, right - cr);

    // 1. Recessed pocket behind the scoop (matches scaffold background so scrolled items don't bleed through)
    final pocketPath = Path()
      ..moveTo(leftShoulderX, top)
      ..arcToPoint(
        pTanLeft,
        radius: const Radius.circular(rShoulder),
        clockwise: true,
      )
      ..arcToPoint(
        pTanRight,
        radius: Radius.circular(rNotch),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(rightShoulderX, top),
        radius: const Radius.circular(rShoulder),
        clockwise: true,
      )
      ..close();

    final pocketPaint = Paint()
      ..color = pocketColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pocketPath, pocketPaint);

    // 2. Build full navbar body path with circular cutout concentric to the button
    final path = Path();
    path.moveTo(left, bottom);
    path.lineTo(left, top + cr);

    // Top-left corner (5px)
    path.arcToPoint(
      Offset(left + cr, top),
      radius: const Radius.circular(cr),
    );
    path.lineTo(leftShoulderX, top);

    // Smooth shoulder down into circular arc cupping the circle with 6px gap
    path.arcToPoint(
      pTanLeft,
      radius: const Radius.circular(rShoulder),
      clockwise: true,
    );
    path.arcToPoint(
      pTanRight,
      radius: Radius.circular(rNotch),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(rightShoulderX, top),
      radius: const Radius.circular(rShoulder),
      clockwise: true,
    );

    // Line to top-right corner (5px)
    path.lineTo(right - cr, top);
    path.arcToPoint(
      Offset(right, top + cr),
      radius: const Radius.circular(cr),
    );

    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    path.close();

    // 3. Elevation drop shadow along navbar top contour
    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.35),
      14.0,
      false,
    );

    // 4. Fill navbar body
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScoopedNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.barTop != barTop ||
        oldDelegate.circleCenterY != circleCenterY ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.barColor != barColor ||
        oldDelegate.pocketColor != pocketColor;
  }
}
