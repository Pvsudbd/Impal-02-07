import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../notifikasi/widgets/notification_bell_button.dart';

/// Top header bar for the desktop workspace (`72 dp` height, bottom border `#3B4150`).
/// Contains title/subtitle, `⌘K` interactive search field, notification bell, and `+ Add Task` CTA.
class DesktopTopHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final String searchQuery;
  final String searchHint;
  final Color searchBgColor;
  final bool showLeadingSearchIcon;
  final bool showShortcutHint;
  final String addButtonLabel;
  final Color addButtonColor;
  final String? secondaryButtonLabel;
  final IconData? secondaryButtonIcon;
  final VoidCallback? onSecondaryButtonTap;
  final bool showNotificationBell;
  final double? titleFontSize;
  final double? horizontalPadding;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddTaskTap;

  const DesktopTopHeader({
    super.key,
    this.title = 'Dashboard Overview',
    this.subtitle =
        'Stay productive and keep track of your ongoing courses & tasks',
    required this.searchQuery,
    this.searchHint = 'Search tasks or courses...',
    this.searchBgColor = AppColors.bgCard,
    this.showLeadingSearchIcon = false,
    this.showShortcutHint = true,
    this.addButtonLabel = '+ Add Task',
    this.addButtonColor = AppColors.primary,
    this.secondaryButtonLabel,
    this.secondaryButtonIcon,
    this.onSecondaryButtonTap,
    this.showNotificationBell = true,
    this.titleFontSize,
    this.horizontalPadding,
    required this.onSearchChanged,
    required this.onAddTaskTap,
  });

  @override
  State<DesktopTopHeader> createState() => _DesktopTopHeaderState();
}

class _DesktopTopHeaderState extends State<DesktopTopHeader> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant DesktopTopHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.collapsed(
        offset: widget.searchQuery.length,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _focusSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _focusSearch,
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding ?? context.rSpacing(28),
          vertical: 14,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgPrimary,
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.titleFontSize ??
                          context.rFont(20, min: 18, max: 22),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: context.rFont(12, min: 11, max: 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildSearchBox(context),
            if (widget.secondaryButtonLabel != null &&
                widget.onSecondaryButtonTap != null) ...[
              const SizedBox(width: 12),
              _buildSecondaryButton(context),
            ],
            if (widget.showNotificationBell) ...[
              const SizedBox(width: 12),
              const NotificationBellButton(size: 40, iconSize: 19),
            ],
            const SizedBox(width: 12),
            _buildAddTaskButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final hasText = widget.searchQuery.isNotEmpty;

    return Container(
      width: 260,
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: widget.showLeadingSearchIcon ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: widget.searchBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          if (widget.showLeadingSearchIcon) ...[
            const Icon(
              Icons.search_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: TextField(
              key: const ValueKey('desktop_search_field'),
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: widget.onSearchChanged,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintText: widget.searchHint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (hasText || widget.showShortcutHint) const SizedBox(width: 8),
          if (hasText)
            InkWell(
              onTap: () {
                _searchController.clear();
                widget.onSearchChanged('');
              },
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else if (widget.showShortcutHint)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '⌘K',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: const ValueKey('desktop_header_secondary_btn'),
        onTap: widget.onSecondaryButtonTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.secondaryButtonIcon != null) ...[
                Icon(
                  widget.secondaryButtonIcon,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.secondaryButtonLabel!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(13, min: 12, max: 14),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return Material(
      color: widget.addButtonColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: const ValueKey('desktop_add_task_btn'),
        onTap: widget.onAddTaskTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.addButtonLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(13, min: 12, max: 14),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

