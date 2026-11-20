import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/user_profile_model.dart';

/// Centered Desktop Pop-Up Modal for configuring Daily Morning Briefing.
///
/// Mirrors FigCraft `Modal - Daily Morning Briefing (Pop-Up)` (node `7570`)
/// with full parity to Mobile [DailyBriefingSettingsModal], adaptive height for
/// `1024x768` viewports, `48x48dp` `[✕]` dismissal, and tabular figures.
class DesktopDailyBriefingModal extends StatefulWidget {
  final UserProfileModel profile;
  final bool embeddedPanel;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  const DesktopDailyBriefingModal({
    super.key,
    required this.profile,
    this.embeddedPanel = false,
    this.onClose,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    VoidCallback? onSaved,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopDailyBriefingModal(
        profile: profile,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DesktopDailyBriefingModal> createState() =>
      _DesktopDailyBriefingModalState();
}

class _DesktopDailyBriefingModalState extends State<DesktopDailyBriefingModal> {
  late bool _enabled;
  late String _briefingTime;
  late Set<String> _selectedTopics;
  late bool _isCompact;

  @override
  void initState() {
    super.initState();
    _enabled = widget.profile.isDailyBriefingEnabled;
    _briefingTime = widget.profile.dailyMorningBriefingTime;
    _selectedTopics = Set.from(widget.profile.dailyBriefingTopics);
    _isCompact = widget.profile.isDailyBriefingCompact;
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.embeddedPanel) {
      widget.onClose?.call();
      return;
    }
    Navigator.of(context).pop();
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(timeStr);
      if (match != null) {
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        return TimeOfDay(hour: h, minute: m);
      }
    } catch (_) {}
    return const TimeOfDay(hour: 7, minute: 0);
  }

  Future<void> _pickTime() async {
    if (!_enabled) return;

    final initial = _parseTime(_briefingTime);
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: initial,
      title: 'Select Morning Briefing Time',
    );

    if (picked != null && mounted) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      setState(() => _briefingTime = '$h:$m WIB');
    }
  }

  void _toggleTopic(String topic) {
    if (!_enabled) return;
    setState(() {
      if (_selectedTopics.contains(topic)) {
        if (_selectedTopics.length > 1) {
          _selectedTopics.remove(topic);
        } else {
          PopUpPemberitahuan.show(
            context,
            title: 'Topic Required',
            message:
                'Please keep at least one agenda topic enabled for briefing.',
            iconBgColor: PopUpPemberitahuan.negativeColor,
            icon: Icons.info_outline_rounded,
          );
        }
      } else {
        _selectedTopics.add(topic);
      }
    });
  }

  void _save() {
    UserProfileRepository().updateDailyBriefingSettings(
      enabled: _enabled,
      time: _briefingTime,
      topics: _selectedTopics.toList(),
      isCompact: _isCompact,
    );

    widget.onSaved?.call();
    _close();

    final formatLabel = _isCompact ? 'Compact' : 'Detailed';
    PopUpPemberitahuan.show(
      context,
      title: 'Briefing Settings Saved',
      message: _enabled
          ? 'Daily morning briefing scheduled at $_briefingTime ($formatLabel) with ${_selectedTopics.length} topics included.'
          : 'Daily morning briefing has been muted.',
      iconBgColor: const Color(0xFF10B981),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = (screenSize.width - 48).clamp(320.0, 470.0);
    final maxModalHeight = (screenSize.height * 0.88).clamp(440.0, 840.0);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    final panelColumn = Column(
      mainAxisSize: widget.embeddedPanel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _buildHeader(context),
        Divider(
          height: 1,
          thickness: 1,
          color: widget.embeddedPanel
              ? AppColors.borderSubtle
              : AppColors.borderSubtle.withValues(alpha: 0.65),
        ),
        Flexible(
          fit: widget.embeddedPanel ? FlexFit.tight : FlexFit.loose,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.rSpacing(22),
              context.rSpacing(16),
              context.rSpacing(22),
              context.rSpacing(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMasterSwitchCard(context),
                SizedBox(height: context.rSpacing(16)),
                _buildSectionHeader(
                  context,
                  title: 'BRIEFING DELIVERY TIME',
                  subtitle:
                      'Select when the briefing summary should be delivered:',
                ),
                SizedBox(height: context.rSpacing(10)),
                _buildDeliveryTimeCard(context),
                SizedBox(height: context.rSpacing(18)),
                _buildSectionHeader(
                  context,
                  title: 'NOTIFICATION DISPLAY FORMAT',
                  subtitle:
                      'Choose how the briefing summary is formatted on your lock screen:',
                ),
                SizedBox(height: context.rSpacing(10)),
                _buildFormatOption(
                  context,
                  fieldKey: const ValueKey(
                    'desktop_briefing_format_detailed',
                  ),
                  isCompact: false,
                  title: 'Detailed Agenda (Recommended)',
                  subtitle:
                      'Lists specific agenda titles, times & bullet points directly on lock screen',
                  icon: Icons.format_list_bulleted_rounded,
                ),
                SizedBox(height: context.rSpacing(8)),
                _buildFormatOption(
                  context,
                  fieldKey: const ValueKey(
                    'desktop_briefing_format_compact',
                  ),
                  isCompact: true,
                  title: 'Compact Summary',
                  subtitle:
                      'Minimal overview with total agenda count only (e.g. "3 agendas scheduled today")',
                  icon: Icons.short_text_rounded,
                ),
                SizedBox(height: context.rSpacing(18)),
                _buildSectionHeader(
                  context,
                  title: 'INCLUDED BRIEFING TOPICS',
                  subtitle:
                      'Choose which agendas will be summarized in your morning report:',
                ),
                SizedBox(height: context.rSpacing(10)),
                _buildTopicsCard(context),
              ],
            ),
          ),
        ),
        if (widget.embeddedPanel)
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderSubtle,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.rSpacing(22),
            context.rSpacing(widget.embeddedPanel ? 14 : 10),
            context.rSpacing(22),
            context.rSpacing(18),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              key: const ValueKey('desktop_briefing_save_btn'),
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Save Briefing Preferences',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.rFont(14.5, min: 13, max: 16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.embeddedPanel) {
      return UnfocusOnTap(
        child: Container(
          key: const ValueKey('desktop_briefing_panel'),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            border: Border(
              left: BorderSide(color: AppColors.borderSubtle, width: 1),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: panelColumn,
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(24),
        vertical: context.rSpacing(24),
      ),
      child: UnfocusOnTap(
        child: TweenAnimationBuilder<double>(
          duration: animDuration,
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.96, end: 1.0),
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: ((scale - 0.96) / 0.04).clamp(0.0, 1.0),
              child: child,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: modalWidth,
              maxHeight: maxModalHeight,
            ),
            child: Container(
              width: modalWidth,
              decoration: BoxDecoration(
                color: AppColors.bgDialog,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x8A000000),
                    blurRadius: 30,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: panelColumn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(22),
        context.rSpacing(18),
        context.rSpacing(10),
        context.rSpacing(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Morning Briefing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(18, min: 16, max: 20),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Customize delivery schedule and included agenda topics',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(12, min: 10.5, max: 13.5),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('desktop_briefing_close_btn'),
              onTap: _close,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF3E4554),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _enabled
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                  : const Color(0xFF475569).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              _enabled
                  ? Icons.wb_sunny_rounded
                  : Icons.notifications_off_outlined,
              size: context.rIcon(20),
              color: _enabled
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(width: context.rSpacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enable Morning Briefing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(14, min: 12.5, max: 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _enabled
                      ? 'Daily overview delivered automatically'
                      : 'Morning briefing is currently muted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(11.5, min: 10, max: 13),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            key: const ValueKey('desktop_briefing_master_switch'),
            value: _enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF10B981),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: const Color(0xFF434A59),
            onChanged: (val) => setState(() => _enabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(11.5, min: 10, max: 13),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(height: context.rSpacing(5)),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: context.rFont(12, min: 10.5, max: 13.5),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeCard(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('desktop_briefing_time_card'),
        onTap: _pickTime,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(12),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF3E4554),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.access_time_filled_rounded,
                  size: context.rIcon(20),
                  color: const Color(0xFF38BDF8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delivery Time',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13.5, min: 12, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _briefingTime,
                      style: TextStyle(
                        color: const Color(0xFF38BDF8),
                        fontSize: context.rFont(14, min: 12.5, max: 16),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _enabled
                      ? const Color(0xFF334155)
                      : const Color(0xFF1E232D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Change Time',
                  style: TextStyle(
                    color: _enabled ? Colors.white : const Color(0xFF64748B),
                    fontSize: context.rFont(12, min: 11, max: 13),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context, {
    required Key fieldKey,
    required bool isCompact,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _isCompact == isCompact;
    const orangeColor = AppColors.primaryAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: fieldKey,
        onTap: _enabled ? () => setState(() => _isCompact = isCompact) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(12),
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B4353) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF525C70)
                  : const Color(0xFF3E4554),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? orangeColor.withValues(alpha: 0.2)
                      : const Color(0xFF334155).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: context.rIcon(20),
                  color: isSelected ? orangeColor : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13.5, min: 12, max: 15),
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11.5, min: 10, max: 13),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? orangeColor : const Color(0xFF64748B),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: orangeColor,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3E4554),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: DailyBriefingTopic.all.asMap().entries.map((entry) {
          final index = entry.key;
          final topic = entry.value;
          final isLast = index == DailyBriefingTopic.all.length - 1;

          return Column(
            children: [
              _buildTopicTile(context, topic),
              if (!isLast)
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFF434A59).withValues(alpha: 0.4),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopicTile(BuildContext context, String topic) {
    final isSelected = _selectedTopics.contains(topic);
    final topicColor = DailyBriefingTopic.color(topic);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('desktop_briefing_topic_$topic'),
        onTap: _enabled ? () => _toggleTopic(topic) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected && _enabled
                      ? topicColor.withValues(alpha: 0.18)
                      : const Color(0xFF334155).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  DailyBriefingTopic.icon(topic),
                  size: context.rIcon(19),
                  color: isSelected && _enabled
                      ? topicColor
                      : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DailyBriefingTopic.label(topic),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.rFont(13.5, min: 12, max: 15),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DailyBriefingTopic.description(topic),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11, min: 10, max: 12.5),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isSelected && _enabled,
                activeThumbColor: Colors.white,
                activeTrackColor: topicColor,
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: const Color(0xFF434A59),
                onChanged: _enabled ? (_) => _toggleTopic(topic) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
