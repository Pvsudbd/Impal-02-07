import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive_context.dart';
import '../../../../../core/widgets/unfocus_on_tap.dart';
import '../../../../common_widgets/pop_up_pemberitahuan.dart';
import '../../models/user_profile_model.dart';

/// Centered Desktop Pop-Up Modal for configuring Alert Preferences across
/// Task Deadlines, Schedule Alerts (Lecture / External), and Team Alerts (Tasks / Meetings).
///
/// Mirrors FigCraft `Modal - Task Deadlines Settings (Pop-Up)` (`node 7732`),
/// `Modal - Schedule Alerts Settings (Pop-Up)` (`node 7823`), and
/// `Modal - Team Alerts Settings (Pop-Up)` (`node 7916`) with full parity to
/// [DeadlineAlertSettingsModal].
class DesktopAlertSettingsModal extends StatefulWidget {
  final UserProfileModel profile;
  final AlertCategoryType category;
  final bool embeddedPanel;
  final VoidCallback? onClose;
  final void Function({
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  })? onSave;

  const DesktopAlertSettingsModal({
    super.key,
    required this.profile,
    this.category = AlertCategoryType.taskDeadline,
    this.embeddedPanel = false,
    this.onClose,
    this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    AlertCategoryType category = AlertCategoryType.taskDeadline,
    void Function({
      required bool enabled,
      required List<String> timings,
      required AlertSoundVibrationMode mode,
    })? onSave,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => DesktopAlertSettingsModal(
        profile: profile,
        category: category,
        onSave: onSave,
      ),
    );
  }

  @override
  State<DesktopAlertSettingsModal> createState() =>
      _DesktopAlertSettingsModalState();
}

class _DesktopSubAlertState {
  bool enabled;
  List<String> availablePresets;
  Set<String> selectedTimings;
  AlertSoundVibrationMode selectedMode;

  _DesktopSubAlertState({
    required this.enabled,
    required List<String> presets,
    required List<String> selected,
    required this.selectedMode,
  })  : availablePresets = List.from(presets),
        selectedTimings = Set.from(selected);

  CategoryAlertConfig toConfig() => CategoryAlertConfig(
        enabled: enabled,
        timings: selectedTimings.toList(),
        soundMode: selectedMode,
      );
}

class _DesktopAlertSettingsModalState extends State<DesktopAlertSettingsModal> {
  int _activeTabIndex = 0;

  final TextEditingController _customNumberController =
      TextEditingController(text: '2');
  String _customUnit = 'Hours';

  late _DesktopSubAlertState _taskDeadlineState;
  late _DesktopSubAlertState _lectureScheduleState;
  late _DesktopSubAlertState _externalScheduleState;
  late _DesktopSubAlertState _teamTaskState;
  late _DesktopSubAlertState _teamMeetingState;

  static const List<String> _taskPresets = [
    'H-3 (3 Days)',
    'H-1 (24 Hours)',
    '6 Hours',
    '3 Hours',
    '1 Hour',
    '30 Minutes',
    '15 Minutes',
  ];

  static const List<String> _lecturePresets = [
    '1 Hour',
    '45 Minutes',
    '30 Minutes',
    '15 Minutes',
    '10 Minutes',
    '5 Minutes',
  ];

  static const List<String> _externalPresets = [
    'H-1 (24 Hours)',
    '6 Hours',
    '3 Hours',
    '1 Hour',
    '30 Minutes',
    '15 Minutes',
  ];

  static const List<String> _teamTaskPresets = [
    'H-3 (3 Days)',
    'H-1 (24 Hours)',
    '6 Hours',
    '3 Hours',
    '1 Hour',
    '30 Minutes',
  ];

  static const List<String> _teamMeetingPresets = [
    '1 Day',
    '3 Hours',
    '1 Hour',
    '30 Minutes',
    '15 Minutes',
    '5 Minutes',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;

    _taskDeadlineState = _DesktopSubAlertState(
      enabled: p.taskDeadlineAlerts.enabled,
      presets: _taskPresets,
      selected: p.taskDeadlineAlerts.timings,
      selectedMode: p.taskDeadlineAlerts.soundMode,
    );

    _lectureScheduleState = _DesktopSubAlertState(
      enabled: p.lectureScheduleAlerts.enabled,
      presets: _lecturePresets,
      selected: p.lectureScheduleAlerts.timings,
      selectedMode: p.lectureScheduleAlerts.soundMode,
    );

    _externalScheduleState = _DesktopSubAlertState(
      enabled: p.externalScheduleAlerts.enabled,
      presets: _externalPresets,
      selected: p.externalScheduleAlerts.timings,
      selectedMode: p.externalScheduleAlerts.soundMode,
    );

    _teamTaskState = _DesktopSubAlertState(
      enabled: p.teamTaskAlerts.enabled,
      presets: _teamTaskPresets,
      selected: p.teamTaskAlerts.timings,
      selectedMode: p.teamTaskAlerts.soundMode,
    );

    _teamMeetingState = _DesktopSubAlertState(
      enabled: p.teamMeetingAlerts.enabled,
      presets: _teamMeetingPresets,
      selected: p.teamMeetingAlerts.timings,
      selectedMode: p.teamMeetingAlerts.soundMode,
    );
  }

  @override
  void dispose() {
    _customNumberController.dispose();
    super.dispose();
  }

  bool get _hasSubTabs =>
      widget.category == AlertCategoryType.schedule ||
      widget.category == AlertCategoryType.team;

  _DesktopSubAlertState get _currentState {
    if (widget.category == AlertCategoryType.schedule) {
      return _activeTabIndex == 0
          ? _lectureScheduleState
          : _externalScheduleState;
    } else if (widget.category == AlertCategoryType.team) {
      return _activeTabIndex == 0 ? _teamTaskState : _teamMeetingState;
    }
    return _taskDeadlineState;
  }

  List<String> get _currentDefaultPresets {
    if (widget.category == AlertCategoryType.schedule) {
      return _activeTabIndex == 0 ? _lecturePresets : _externalPresets;
    } else if (widget.category == AlertCategoryType.team) {
      return _activeTabIndex == 0 ? _teamTaskPresets : _teamMeetingPresets;
    }
    return _taskPresets;
  }

  String get _currentSubLabel {
    if (widget.category == AlertCategoryType.schedule) {
      return _activeTabIndex == 0 ? 'Lecture Schedule' : 'External Schedule';
    } else if (widget.category == AlertCategoryType.team) {
      return _activeTabIndex == 0 ? 'Team Tasks' : 'Team Meetings';
    }
    return 'Task Deadlines';
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.embeddedPanel) {
      widget.onClose?.call();
      return;
    }
    Navigator.of(context).pop();
  }

  void _addCustomTiming() {
    final number = int.tryParse(_customNumberController.text.trim());
    if (number == null || number <= 0) return;

    final unitLabel = _customUnit;
    final timingString = number == 1
        ? '1 ${unitLabel.substring(0, unitLabel.length - 1)}'
        : '$number $unitLabel';

    setState(() {
      final state = _currentState;
      if (!state.availablePresets.contains(timingString)) {
        state.availablePresets.add(timingString);
      }
      state.selectedTimings.add(timingString);
    });
  }

  void _save() {
    final repo = UserProfileRepository();

    if (widget.category == AlertCategoryType.schedule) {
      repo.updateScheduleAlertSettings(
        lectureConfig: _lectureScheduleState.toConfig(),
        externalConfig: _externalScheduleState.toConfig(),
      );
    } else if (widget.category == AlertCategoryType.team) {
      repo.updateTeamAlertSettings(
        teamTaskConfig: _teamTaskState.toConfig(),
        teamMeetingConfig: _teamMeetingState.toConfig(),
      );
    } else {
      repo.updateCategoryAlertSettings(
        category: AlertCategoryType.taskDeadline,
        enabled: _taskDeadlineState.enabled,
        timings: _taskDeadlineState.selectedTimings.toList(),
        mode: _taskDeadlineState.selectedMode,
      );
    }

    final cur = _currentState;
    widget.onSave?.call(
      enabled: cur.enabled,
      timings: cur.selectedTimings.toList(),
      mode: cur.selectedMode,
    );

    _close();

    PopUpPemberitahuan.show(
      context,
      title: 'Alert Preferences Saved',
      message:
          'Notification settings for ${widget.category.label} have been updated successfully.',
      iconBgColor: const Color(0xFF10B981),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentState;
    final screenSize = MediaQuery.sizeOf(context);
    final modalWidth = (screenSize.width - 48).clamp(320.0, 480.0);
    final maxModalHeight = (screenSize.height * 0.88).clamp(440.0, 840.0);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animDuration =
        disableAnimations ? Duration.zero : const Duration(milliseconds: 180);

    final panelColumn = Column(
      mainAxisSize: widget.embeddedPanel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _buildHeader(context),
        if (_hasSubTabs) _buildSubTabSwitcher(context),
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
                _buildMasterSwitchCard(context, current),
                SizedBox(height: context.rSpacing(18)),
                _buildRemindBeforeHeader(context, current),
                SizedBox(height: context.rSpacing(4)),
                Text(
                  'Tap chip to toggle alert • Tap ✕ to delete interval:',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: context.rFont(11.5, min: 10, max: 13),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: context.rSpacing(10)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: current.availablePresets
                      .map((t) => _buildTimingChip(t, current))
                      .toList(),
                ),
                SizedBox(height: context.rSpacing(14)),
                _buildCustomTimingRow(context, current),
                SizedBox(height: context.rSpacing(20)),
                Text(
                  'SOUND & VIBRATION MODE',
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
                  'Select how you want alerts delivered to your device:',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: context.rFont(12, min: 10.5, max: 13.5),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: context.rSpacing(10)),
                for (final mode in AlertSoundVibrationMode.values) ...[
                  _buildModeCard(context, mode: mode, state: current),
                  if (mode != AlertSoundVibrationMode.values.last)
                    SizedBox(height: context.rSpacing(8)),
                ],
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
              key: const ValueKey('desktop_alert_save_btn'),
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
                'Save Alert Preferences',
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
          key: ValueKey('desktop_alert_panel_${widget.category.name}'),
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
        context.rSpacing(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.category.label} Settings',
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
                  'Customize reminder lead times and delivery style',
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
              key: const ValueKey('desktop_alert_close_btn'),
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

  Widget _buildSubTabSwitcher(BuildContext context) {
    final isSchedule = widget.category == AlertCategoryType.schedule;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.rSpacing(22),
        context.rSpacing(2),
        context.rSpacing(22),
        context.rSpacing(12),
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3E4554), width: 1),
        ),
        child: Row(
          children: [
            _buildSubTab(
              index: 0,
              title: isSchedule ? 'Lecture Schedule' : 'Team Tasks',
              icon: isSchedule
                  ? Icons.school_outlined
                  : Icons.assignment_turned_in_outlined,
            ),
            const SizedBox(width: 4),
            _buildSubTab(
              index: 1,
              title: isSchedule ? 'External Schedule' : 'Team Meetings',
              icon: isSchedule
                  ? Icons.event_note_outlined
                  : Icons.groups_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _activeTabIndex == index;

    return Expanded(
      child: InkWell(
        key: ValueKey('desktop_alert_subtab_$index'),
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: context.animationsDisabled
              ? Duration.zero
              : const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    width: 1,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primaryAccent
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterSwitchCard(
    BuildContext context,
    _DesktopSubAlertState current,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rSpacing(14),
        vertical: context.rSpacing(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3E4554), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: current.enabled
                  ? widget.category.accentColor.withValues(alpha: 0.18)
                  : const Color(0xFF475569).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              current.enabled
                  ? widget.category.icon
                  : Icons.notifications_off_outlined,
              size: context.rIcon(20),
              color: current.enabled
                  ? widget.category.accentColor
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
                  'Enable $_currentSubLabel Alerts',
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
                  current.enabled
                      ? 'System sends timely reminders'
                      : 'Alerts for this activity are muted',
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
            key: const ValueKey('desktop_alert_master_switch'),
            value: current.enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.statusCompleted,
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: const Color(0xFF434A59),
            onChanged: (val) => setState(() => current.enabled = val),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindBeforeHeader(
    BuildContext context,
    _DesktopSubAlertState current,
  ) {
    final isModified =
        current.availablePresets.length != _currentDefaultPresets.length ||
            !current.availablePresets.every(_currentDefaultPresets.contains);

    return Row(
      children: [
        Expanded(
          child: Text(
            'REMIND ME BEFORE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: context.rFont(11.5, min: 10, max: 13),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (isModified) ...[
          const SizedBox(width: 8),
          InkWell(
            key: const ValueKey('desktop_alert_reset_btn'),
            onTap: () {
              setState(() {
                current.availablePresets
                  ..clear()
                  ..addAll(_currentDefaultPresets);
                if (current.selectedTimings.isEmpty &&
                    current.availablePresets.isNotEmpty) {
                  current.selectedTimings.add(current.availablePresets.first);
                }
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Reset Defaults',
                style: TextStyle(
                  color: Color(0xFF5B93FF),
                  fontSize: 11.5,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimingChip(String timing, _DesktopSubAlertState state) {
    final isSelected = state.selectedTimings.contains(timing);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: context.animationsDisabled
            ? Duration.zero
            : const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.22)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF434A59),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: state.enabled
                  ? () {
                      setState(() {
                        if (isSelected) {
                          if (state.selectedTimings.length > 1) {
                            state.selectedTimings.remove(timing);
                          }
                        } else {
                          state.selectedTimings.add(timing);
                        }
                      });
                    }
                  : null,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 4,
                  top: 7,
                  bottom: 7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      timing,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : (state.enabled
                                ? Colors.white70
                                : const Color(0xFF64748B)),
                        fontSize: context.rFont(12, min: 10.5, max: 13.5),
                        fontFamily: 'Inter',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              key: ValueKey('desktop_delete_timing_$timing'),
              onTap: state.enabled
                  ? () {
                      setState(() {
                        state.availablePresets.remove(timing);
                        state.selectedTimings.remove(timing);
                        if (state.selectedTimings.isEmpty &&
                            state.availablePresets.isNotEmpty) {
                          state.selectedTimings.add(state.availablePresets.first);
                        }
                      });
                    }
                  : null,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 8,
                  top: 6,
                  bottom: 6,
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : const Color(0xFF64748B).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: isSelected
                        ? AppColors.primaryAccent
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTimingRow(
    BuildContext context,
    _DesktopSubAlertState current,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3E4554), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3E4554), width: 1),
            ),
            alignment: Alignment.center,
            child: TextField(
              key: const ValueKey('desktop_alert_custom_number'),
              controller: _customNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 3,
              buildCounter: (_,
                      {required currentLength,
                      required isFocused,
                      required maxLength}) =>
                  null,
              enabled: current.enabled,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(8)),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF3E4554), width: 1),
              ),
              alignment: Alignment.center,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _customUnit,
                  dropdownColor: AppColors.bgCard,
                  isExpanded: true,
                  isDense: true,
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Minutes',
                      child: Text('Minutes before'),
                    ),
                    DropdownMenuItem(
                      value: 'Hours',
                      child: Text('Hours before'),
                    ),
                    DropdownMenuItem(
                      value: 'Days',
                      child: Text('Days before'),
                    ),
                  ],
                  onChanged: current.enabled
                      ? (val) {
                          if (val != null) {
                            setState(() => _customUnit = val);
                          }
                        }
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: context.rSpacing(8)),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              key: const ValueKey('desktop_alert_add_timing_btn'),
              onPressed: current.enabled ? _addCustomTiming : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF434A59),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 44),
                maximumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '+ Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required AlertSoundVibrationMode mode,
    required _DesktopSubAlertState state,
  }) {
    final isSelected = state.selectedMode == mode;
    const orangeColor = AppColors.primaryAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('desktop_alert_mode_${mode.name}'),
        onTap: state.enabled
            ? () => setState(() => state.selectedMode = mode)
            : null,
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
                  mode.icon,
                  size: context.rIcon(20),
                  color: isSelected ? orangeColor : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Text(
                  mode.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.rFont(13.5, min: 12, max: 15),
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
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
                          color: orangeColor,
                          shape: BoxShape.circle,
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
}
