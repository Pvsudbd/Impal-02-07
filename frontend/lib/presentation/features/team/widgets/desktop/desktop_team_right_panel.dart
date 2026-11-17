import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../models/desktop_team_directory_models.dart';

/// Right sidebar panel (`340 dp` fixed width) matching FigCraft `Aside Right Panel` (node 5550)
/// inside `Desktop - Group Directory (List Kelompok)`.
class DesktopTeamRightPanel extends StatefulWidget {
  final List<DesktopTeamDeadlineItem> deadlines;
  final List<DesktopTeamActivityItem> activities;
  final ValueChanged<String> onJoinByCode;

  const DesktopTeamRightPanel({
    super.key,
    required this.deadlines,
    required this.activities,
    required this.onJoinByCode,
  });

  @override
  State<DesktopTeamRightPanel> createState() => _DesktopTeamRightPanelState();
}

class _DesktopTeamRightPanelState extends State<DesktopTeamRightPanel> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitJoinCode() {
    final code = _codeController.text.trim().toUpperCase();
    widget.onJoinByCode(code);
    if (code.isNotEmpty) {
      _codeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildJoinCodeWidget(context),
          const SizedBox(height: 20),
          _buildDeadlinesWidget(context),
          const SizedBox(height: 20),
          _buildActivityWidget(context),
        ],
      ),
    );
  }

  Widget _buildJoinCodeWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Have a Team Invite Code?',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14, min: 13, max: 15.5),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the 4-character invite code from your teammate to join a workspace.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11, min: 10.5, max: 12),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              key: const ValueKey('desktop_team_inline_code_input'),
              controller: _codeController,
              maxLength: 20,
              buildCounter: (
                context, {
                required currentLength,
                required isFocused,
                required maxLength,
              }) =>
                  null,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                hintText: 'Example: 7X29',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              onSubmitted: (_) => _submitJoinCode(),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              key: const ValueKey('desktop_team_inline_join_btn'),
              onTap: _submitJoinCode,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 38,
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text(
                  'Join Team',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinesWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Upcoming Team Deadlines',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14, min: 13, max: 15.5),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          for (int i = 0; i < widget.deadlines.length; i++) ...[
            const SizedBox(height: 14),
            _buildDeadlineRow(widget.deadlines[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildDeadlineRow(DesktopTeamDeadlineItem item) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.timeText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 20,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: item.pillBgColor,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              item.priorityLabel,
              style: TextStyle(
                color: item.pillTextColor,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.bgSidebar,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recent Team Activity',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(14, min: 13, max: 15.5),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          for (int i = 0; i < widget.activities.length; i++) ...[
            const SizedBox(height: 12),
            _buildActivityRow(widget.activities[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityRow(DesktopTeamActivityItem item) {
    return SizedBox(
      height: 38,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: item.avatarColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              item.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.timeAgo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
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
    );
  }
}
