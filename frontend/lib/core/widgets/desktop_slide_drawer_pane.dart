import 'package:flutter/material.dart';

/// Shared non-blocking desktop inline right slide drawer container.
///
/// Narrows [content] smoothly on the left while sliding [drawer] in from
/// the right edge so the active workspace remains interactive (no modal barrier).
class DesktopSlideDrawerPane extends StatelessWidget {
  final bool isOpen;
  final Widget content;
  final Widget? drawer;

  const DesktopSlideDrawerPane({
    super.key,
    required this.isOpen,
    required this.content,
    required this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final showDrawer = isOpen && drawer != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final drawerWidth = constraints.maxWidth < 1000 ? 380.0 : 440.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: content),
            AnimatedContainer(
              duration: disableMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 240),
              curve: Curves.easeInOutCubic,
              width: showDrawer ? drawerWidth : 0.0,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: showDrawer
                  ? OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: drawerWidth,
                      maxWidth: drawerWidth,
                      child: SizedBox(
                        width: drawerWidth,
                        height: double.infinity,
                        child: drawer,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
