import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import '../../../core/widgets/unfocus_on_tap.dart';
import '../../common_widgets/pop_up_pemberitahuan.dart';
import 'models/desktop_team_directory_models.dart';
import 'models/team_repository.dart';

/// Aliases for backwards compatibility with Figma export & routes
typedef JoinTeam = PopUpJoinTeam;

/// Unified Join Study Team modal dialog for both Mobile and Desktop.
///
/// Mirrors FigCraft `Modal - Join Team (Pop-Up)` (node `7097`) with the
/// 4-character invite code boxes, top-right `[✕]` close button, no Team Found
/// preview card, and full-width `Join Workspace Now` CTA (without Cancel).
class PopUpJoinTeam extends StatefulWidget {
  final String initialCode;
  final ValueChanged<String>? onJoined;

  const PopUpJoinTeam({
    super.key,
    this.initialCode = '',
    this.onJoined,
  });

  /// Helper to show the Join Study Team popup as a modal dialog.
  static Future<String?> show(
    BuildContext context, {
    String initialCode = '',
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpJoinTeam(
        initialCode: initialCode,
      ),
    );
  }

  @override
  State<PopUpJoinTeam> createState() => _PopUpJoinTeamState();
}

class _PopUpJoinTeamState extends State<PopUpJoinTeam> {
  late final TextEditingController _codeController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(
      text: widget.initialCode.trim().toUpperCase(),
    );
    _codeController.addListener(_onCodeChanged);
    _focusNode.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _focusNode.removeListener(_onCodeChanged);
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DesktopTeamCardData? _findTeamByCode(String code) {
    if (code.length < 4) return null;
    for (final team in TeamRepository().teams) {
      if (team.inviteCode?.toUpperCase() == code) {
        return DesktopTeamCardData(
          id: team.id,
          name: team.name,
          subtitle: 'Kelompok kolaborasi',
          badgeLabel: 'Mata Kuliah',
          badgeBgColor: const Color(0xFF47373B),
          badgeTextColor: AppColors.primaryAccent,
          category: TeamDirectoryCategory.mataKuliah,
          members: team.memberColors
              .map((c) => TeamMemberAvatar(
                    initials: team.name.isNotEmpty ? team.name[0].toUpperCase() : 'M',
                    bgColor: c,
                  ))
              .toList(),
          completedTasks: 0,
          totalTasks: 0,
          progressColor: AppColors.primaryAccent,
          percentTextColor: AppColors.primaryAccent,
          inviteCode: team.inviteCode ?? code,
        );
      }
    }
    for (final team in DesktopTeamDirectoryFixtures.defaultTeams) {
      if (team.inviteCode.toUpperCase() == code) {
        return team;
      }
    }
    return null;
  }

  void _handleJoin() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 4) {
      PopUpPemberitahuan.teamWarning(
        context,
        title: 'Invite Code Required',
        message: 'Please enter the 4-character team invite code.',
      );
      return;
    }

    widget.onJoined?.call(code);
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final horizontalPad = isMobile ? 18.0 : 28.0;
    final verticalPad = isMobile ? 18.0 : 24.0;
    final sectionGap = isMobile ? 16.0 : 22.0;
    final code = _codeController.text.trim().toUpperCase();
    final hasFullCode = code.length == 4;
    final matchedTeam = _findTeamByCode(code);
    final canSubmit = hasFullCode;
    final disableMotion = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableMotion ? Duration.zero : const Duration(milliseconds: 180);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 24,
      ),
      child: UnfocusOnTap(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 360 : 440),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: verticalPad,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(context),
                  SizedBox(height: sectionGap),
                  _buildCodeBoxes(context),
                  AnimatedSize(
                    duration: animDuration,
                    curve: Curves.easeOutCubic,
                    child: hasFullCode
                        ? Padding(
                            padding: EdgeInsets.only(top: sectionGap),
                            child: _buildTeamLookupBanner(
                              context,
                              code: code,
                              matchedTeam: matchedTeam,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: sectionGap),
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 44 : 46,
                    child: ElevatedButton(
                      key: const ValueKey('join_team_submit_button'),
                      onPressed: canSubmit ? _handleJoin : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.35),
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            Colors.white.withValues(alpha: 0.55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Join Workspace Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(14, min: 13.5, max: 15),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
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
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Join Team',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.rFont(20, min: 18, max: 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: const ValueKey('close_join_team_button'),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeBoxes(BuildContext context) {
    final code = _codeController.text.trim().toUpperCase();
    final isFocused = _focusNode.hasFocus;
    final isMobile = context.isMobile;
    final boxGap = isMobile ? 8.0 : 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBox = isMobile ? 54.0 : 62.0;
        final boxSize =
            ((constraints.maxWidth - (boxGap * 3)) / 4).clamp(44.0, maxBox);
        final totalWidth = (boxSize * 4) + (boxGap * 3);

        return Center(
          child: SizedBox(
            width: totalWidth,
            height: boxSize,
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(4, (index) {
                      final char = index < code.length ? code[index] : '';
                      final isActive = isFocused &&
                          (index == code.length ||
                              (code.length == 4 && index == 3));
                      final hasChar = char.isNotEmpty;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == 3 ? 0 : boxGap,
                        ),
                        child: Container(
                          width: boxSize,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (hasChar || isActive)
                                  ? AppColors.primary
                                  : AppColors.borderSubtle,
                              width: (hasChar || isActive) ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            char,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rFont(22, min: 19, max: 24),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        key: const ValueKey('join_team_code_input'),
                        controller: _codeController,
                        focusNode: _focusNode,
                        maxLength: 4,
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        enableSuggestions: false,
                        buildCounter: (
                          context, {
                          required currentLength,
                          required isFocused,
                          required maxLength,
                        }) =>
                            null,
                        onSubmitted: (_) => _handleJoin(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamLookupBanner(
    BuildContext context, {
    required String code,
    required DesktopTeamCardData? matchedTeam,
  }) {
    final isFound = matchedTeam != null;
    final accentColor = isFound ? const Color(0xFF10B981) : AppColors.primaryAccent;

    return Container(
      key: ValueKey(
        isFound ? 'join_team_found_banner' : 'join_team_not_found_banner',
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFound ? Icons.check_rounded : Icons.vpn_key_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  isFound ? 'TEAM FOUND' : 'TEAM INVITE CODE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFound
                ? '${matchedTeam.name} (${matchedTeam.badgeLabel} • ${matchedTeam.members.length} Members)'
                : 'Invite code "$code" ready. Tap Join Study Team to connect.',
            style: TextStyle(
              color: isFound ? Colors.white : AppColors.textMuted,
              fontSize: context.rFont(13, min: 12, max: 14),
              fontFamily: 'Inter',
              fontWeight: isFound ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
