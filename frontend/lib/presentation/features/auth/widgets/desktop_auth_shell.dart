import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';

/// Shared 60/40 Desktop Split-Screen shell for authentication flows
/// (`Login`, `Register`, `TermsPrivacyPage` during onboarding,
/// `ForgotPassword`, `VerificationCodePage`, and `ResetPasswordPage`).
///
/// Built for 60 FPS on low-end devices (no [BackdropFilter] GPU blurs;
/// soft ambient glows use lightweight radial gradients inside [IgnorePointer]).
class DesktopAuthSplitShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;
  final IconData backIcon;
  final String backTooltip;
  final Widget? topTrailingAction;
  final double formMaxWidth;

  const DesktopAuthSplitShell({
    super.key,
    required this.child,
    this.onBack,
    this.backIcon = Icons.arrow_back_rounded,
    this.backTooltip = 'Back',
    this.topTrailingAction,
    this.formMaxWidth = 440.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Exact 40% right panel at 1440dp (576dp), clamped so 1024dp remains roomy.
    final rightPanelWidth = (screenWidth * 0.4).clamp(480.0, 620.0);
    final leftHorizontalPadding = screenWidth >= 1320 ? 72.0 : 40.0;
    final rightHorizontalPadding = screenWidth >= 1320 ? 56.0 : 32.0;

    return Scaffold(
      backgroundColor: const Color(0xFF191D26),
      body: UnfocusOnTap(
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Brand & Value Proposition Hero Panel
              Expanded(
                child: _DesktopAuthHeroPanel(
                  horizontalPadding: leftHorizontalPadding,
                ),
              ),

              // Right Interactive Authentication Panel
              SizedBox(
                width: rightPanelWidth,
                child: _DesktopAuthRightPanel(
                  horizontalPadding: rightHorizontalPadding,
                  formMaxWidth: formMaxWidth,
                  onBack: onBack,
                  backIcon: backIcon,
                  backTooltip: backTooltip,
                  topTrailingAction: topTrailingAction,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopAuthHeroPanel extends StatelessWidget {
  final double horizontalPadding;

  const _DesktopAuthHeroPanel({required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final headlineSize = screenWidth >= 1280 ? 40.0 : 32.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF191D26),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient top-left coral radial glow
          Positioned(
            left: -140,
            top: -140,
            child: IgnorePointer(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF26444).withValues(alpha: 0.20),
                      const Color(0xFFF26444).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.72],
                  ),
                ),
              ),
            ),
          ),

          // Soft ambient bottom-right indigo radial glow
          Positioned(
            right: -60,
            bottom: -120,
            child: IgnorePointer(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.14),
                      const Color(0xFF6366F1).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.72],
                  ),
                ),
              ),
            ),
          ),

          // Main Column: Top Brand Header, Centered Hero Copy, Bottom Meta Footer
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF6B4A), Color(0xFFF26444)],
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x7FF26444),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                            spreadRadius: -4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Smart Task Manager',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            letterSpacing: -0.45,
                          ),
                        ),
                        Text(
                          'AI Academic Ecosystem',
                          style: TextStyle(
                            color: Color(0xFF8E95A5),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Vertically Centered Hero Content
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0x19F26444),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0x3FF26444),
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 14,
                                            color: Color(0xFFFF6B4A),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'INTELLIGENT DECISION SUPPORT',
                                            style: TextStyle(
                                              color: Color(0xFFFF6B4A),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1.33,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                'AI-Driven Academic Task &\nSchedule ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: headlineSize,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                              height: 1.18,
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Prioritization System',
                                            style: TextStyle(
                                              color: const Color(0xFFFF6B4A),
                                              fontSize: headlineSize,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w800,
                                              height: 1.18,
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 560),
                                      child: const Text(
                                        'Automatically rank coursework deadlines, lab deliverables, and group sprints using real-time weight analysis, credit load, and personal energy windows.',
                                        style: TextStyle(
                                          color: Color(0xFF8E95A5),
                                          fontSize: 15.5,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Left Meta Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      const Text(
                        'IMPAL Group 7 • Telkom University © 2026',
                        style: TextStyle(
                          color: Color(0xFF8E95A5),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 20,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF26444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Fuzzy-AHP Engine',
                                style: TextStyle(
                                  color: Color(0xFF8E95A5),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Bandung, Indonesia',
                            style: TextStyle(
                              color: Color(0xFF8E95A5),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopAuthRightPanel extends StatelessWidget {
  final double horizontalPadding;
  final double formMaxWidth;
  final VoidCallback? onBack;
  final IconData backIcon;
  final String backTooltip;
  final Widget? topTrailingAction;
  final Widget child;

  const _DesktopAuthRightPanel({
    required this.horizontalPadding,
    required this.formMaxWidth,
    required this.onBack,
    required this.backIcon,
    required this.backTooltip,
    required this.topTrailingAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgDialog,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft ambient top-right coral radial glow
          Positioned(
            right: -60,
            top: -40,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF26444).withValues(alpha: 0.12),
                      const Color(0xFFF26444).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.72],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 28,
            ),
            child: Column(
              children: [
                // Top Bar (Optional Back + Optional Trailing Action + Authentication page pill)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (onBack != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: onBack,
                          child: Tooltip(
                            message: backTooltip,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF323846),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.07),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    backIcon,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    const SizedBox(width: 8),

                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (topTrailingAction != null) ...[
                              topTrailingAction!,
                              const SizedBox(width: 8),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: ShapeDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: const Text(
                                'Authentication page',
                                style: TextStyle(
                                  color: Color(0xFFD1D5DB),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  height: 1.33,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Vertically Centered Scrollable Form Viewport
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: (constraints.maxHeight - 32).clamp(0.0, double.infinity),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: formMaxWidth),
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Compliance & Version Footer
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Protected by Telkom University Academic Auth',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xB28E95A5),
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'v2.4.0',
                        style: TextStyle(
                          color: Color(0xB28E95A5),
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
