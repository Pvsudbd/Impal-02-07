import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../../core/widgets/unfocus_on_tap.dart';
import 'desktop_auth_shell.dart';

/// Responsive wrapper for authentication pages.
/// - Mobile (< 600dp): Dark compact layout + copyright footer.
/// - Tablet (600dp - 1023dp): Centered card + copyright footer.
/// - Desktop (>= 1024dp): 60/40 Split-Screen Hero + Auth Form Shell.
class AuthCardWrapper extends StatelessWidget {
  final Widget child;
  final Widget? topNavBar;
  final double maxWidth;
  final VoidCallback? onDesktopBack;
  final Widget? desktopTopTrailingAction;
  final double? desktopFormMaxWidth;

  const AuthCardWrapper({
    super.key,
    required this.child,
    this.topNavBar,
    this.maxWidth = 440.0,
    this.onDesktopBack,
    this.desktopTopTrailingAction,
    this.desktopFormMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return DesktopAuthSplitShell(
        onBack: onDesktopBack,
        topTrailingAction: desktopTopTrailingAction,
        formMaxWidth: desktopFormMaxWidth ?? maxWidth,
        child: child,
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFF282D37) : const Color(0xFF1E222B),
      body: UnfocusOnTap(
        child: SafeArea(
          child: isMobile
              ? Column(
                  children: [
                    if (topNavBar != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: topNavBar!,
                      ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                                maxWidth: maxWidth,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    child,
                                    const Spacer(),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 24, top: 16),
                                      child: Center(
                                        child: Text(
                                          'IMPAL Group 7 • Telkom University © 2026',
                                          style: TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: RepaintBoundary(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282D37),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 10),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (topNavBar != null) ...[
                                  topNavBar!,
                                  const SizedBox(height: 16),
                                ],
                                child,
                                const SizedBox(height: 24),
                                const Text(
                                  'IMPAL Group 7 • Telkom University © 2026',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
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
      ),
    );
  }
}

