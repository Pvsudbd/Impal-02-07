import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../models/user_profile_model.dart';

/// Interactive modal bottom sheet for customizing:
/// 1. Category alert timings (Days, Hours, Minutes, or Custom)
/// 2. Segmented sub-tabs for Schedule (Lecture vs External) & Team (Tasks vs Meetings)
/// 3. Harmonized color palette matching ProfilePage background (#282D37) and cards (#323846)
class DeadlineAlertSettingsModal extends StatefulWidget {
  final UserProfileModel profile;
  final AlertCategoryType category;
  final void Function({
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  })? onSave;

  const DeadlineAlertSettingsModal({
    super.key,
    required this.profile,
    this.category = AlertCategoryType.taskDeadline,
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
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DeadlineAlertSettingsModal(
        profile: profile,
        category: category,
        onSave: onSave,
      ),
    );
  }

  @override
  State<DeadlineAlertSettingsModal> createState() =>
      _DeadlineAlertSettingsModalState();
}

class _SubAlertState {
  bool enabled;
  List<String> availablePresets;
  Set<String> selectedTimings;
  AlertSoundVibrationMode selectedMode;

  _SubAlertState({
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

class _DeadlineAlertSettingsModalState
    extends State<DeadlineAlertSettingsModal> {
  int _activeTabIndex = 0;

  final TextEditingController _customNumberController =
      TextEditingController(text: '2');
  String _customUnit = 'Hours';

  // Sub-category states
  late _SubAlertState _taskDeadlineState;
  late _SubAlertState _lectureScheduleState;
  late _SubAlertState _externalScheduleState;
  late _SubAlertState _teamTaskState;
  late _SubAlertState _teamMeetingState;

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

    _taskDeadlineState = _SubAlertState(
      enabled: p.taskDeadlineAlerts.enabled,
      presets: _taskPresets,
      selected: p.taskDeadlineAlerts.timings,
      selectedMode: p.taskDeadlineAlerts.soundMode,
    );

    _lectureScheduleState = _SubAlertState(
      enabled: p.lectureScheduleAlerts.enabled,
      presets: _lecturePresets,
      selected: p.lectureScheduleAlerts.timings,
      selectedMode: p.lectureScheduleAlerts.soundMode,
    );

    _externalScheduleState = _SubAlertState(
      enabled: p.externalScheduleAlerts.enabled,
      presets: _externalPresets,
      selected: p.externalScheduleAlerts.timings,
      selectedMode: p.externalScheduleAlerts.soundMode,
    );

    _teamTaskState = _SubAlertState(
      enabled: p.teamTaskAlerts.enabled,
      presets: _teamTaskPresets,
      selected: p.teamTaskAlerts.timings,
      selectedMode: p.teamTaskAlerts.soundMode,
    );

    _teamMeetingState = _SubAlertState(
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

  _SubAlertState get _currentState {
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

  void _addCustomTiming() {
    final rawNumber = _customNumberController.text.trim();
    final number = int.tryParse(rawNumber);
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

    if (widget.onSave != null) {
      final cur = _currentState;
      widget.onSave!(
        enabled: cur.enabled,
        timings: cur.selectedTimings.toList(),
        mode: cur.selectedMode,
      );
    }

    Navigator.of(context).pop();

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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      // Background matched identically to ProfilePage background (#282D37)
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF434A59),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rSpacing(20),
              vertical: context.rSpacing(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.category.label} Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(18, min: 16, max: 22),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customize reminder lead times and delivery style',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(12, min: 10.5, max: 13.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Segmented Pill Tab Switcher (For Schedule & Team)
          if (_hasSubTabs) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(20),
                vertical: context.rSpacing(6),
              ),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF434A59).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSubTab(
                      index: 0,
                      title: widget.category == AlertCategoryType.schedule
                          ? 'Lecture Schedule'
                          : 'Team Tasks',
                      icon: widget.category == AlertCategoryType.schedule
                          ? Icons.school_outlined
                          : Icons.assignment_turned_in_outlined,
                    ),
                    const SizedBox(width: 4),
                    _buildSubTab(
                      index: 1,
                      title: widget.category == AlertCategoryType.schedule
                          ? 'External Schedule'
                          : 'Team Meetings',
                      icon: widget.category == AlertCategoryType.schedule
                          ? Icons.event_note_outlined
                          : Icons.groups_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ],

          Divider(
            height: 1,
            color: const Color(0xFF434A59).withValues(alpha: 0.35),
          ),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(20),
                vertical: context.rSpacing(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Master Switch Card (Color matched to ProfilePage AppColors.bgCard)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(14),
                      vertical: context.rSpacing(10),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF434A59).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Squared container (kotak rounded 10dp)
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: current.enabled
                                ? widget.category.accentColor
                                    .withValues(alpha: 0.18)
                                : const Color(0xFF475569)
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            current.enabled
                                ? widget.category.icon
                                : Icons.notifications_off_outlined,
                            size: 20,
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
                                  fontSize:
                                      context.rFont(14, min: 12.5, max: 16),
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
                                  fontSize:
                                      context.rFont(11.5, min: 10, max: 13),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: current.enabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF10B981),
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: const Color(0xFF434A59),
                          onChanged: (val) =>
                              setState(() => current.enabled = val),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.rSpacing(20)),

                  // Section: Remind Me Before (Timings)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'REMIND ME BEFORE',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(11.5, min: 10, max: 13),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final isModified = current.availablePresets.length !=
                                  _currentDefaultPresets.length ||
                              !current.availablePresets
                                  .every(_currentDefaultPresets.contains);
                          if (!isModified) return const SizedBox.shrink();

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                current.availablePresets
                                  ..clear()
                                  ..addAll(_currentDefaultPresets);
                                if (current.selectedTimings.isEmpty &&
                                    current.availablePresets.isNotEmpty) {
                                  current.selectedTimings
                                      .add(current.availablePresets.first);
                                }
                              });
                            },
                            child: const Text(
                              'Reset Defaults',
                              style: TextStyle(
                                color: Color(0xFF5B93FF),
                                fontSize: 11.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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

                  // Preset Chips Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: current.availablePresets.map((timing) {
                      return _buildTimingChip(timing, current);
                    }).toList(),
                  ),

                  SizedBox(height: context.rSpacing(14)),

                  // Custom Timing Input Row (Matched to AppColors.bgCard)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF434A59).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Number input (Indented container matching AppColors.bgPrimary, 44dp height)
                        Container(
                          width: 58,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF434A59).withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _customNumberController,
                            keyboardType: TextInputType.number,
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
                        // 2. Unit dropdown (Indented container matching AppColors.bgPrimary, exact 44dp height)
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgPrimary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF434A59).withValues(alpha: 0.6),
                                width: 1,
                              ),
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
                        // 3. Add button (Exact same 44dp height and 10dp radius)
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            key: const ValueKey('add_custom_timing_button'),
                            onPressed:
                                current.enabled ? _addCustomTiming : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF434A59),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                  ),

                  SizedBox(height: context.rSpacing(24)),

                  // Section: Sound & Vibration Mode
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
                  SizedBox(height: context.rSpacing(6)),
                  Text(
                    'Select how you want alerts delivered to your device:',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.rSpacing(10)),

                  // 4 Mode Options (Color matched to Profile cards, All logos orange when selected)
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.soundAndVibrate,
                    state: current,
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.soundOnly,
                    state: current,
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.vibrationOnly,
                    state: current,
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.silent,
                    state: current,
                  ),

                  SizedBox(height: context.rSpacing(26)),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Alert Preferences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(14.5, min: 13, max: 16),
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
        ],
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
      child: GestureDetector(
        onTap: () => setState(() => _activeTabIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFFFA6144).withValues(alpha: 0.7),
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
                    ? const Color(0xFFFF7D65)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimingChip(String timing, _SubAlertState state) {
    final isSelected = state.selectedTimings.contains(timing);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFA6144).withValues(alpha: 0.22)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFA6144)
                : const Color(0xFF434A59),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left selection tap area
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
                        color: Color(0xFFFA6144),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      timing,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFFFF7D65)
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
            // Right dedicated delete tap area with clear hit target
            InkWell(
              key: ValueKey('delete_timing_$timing'),
              onTap: state.enabled
                  ? () {
                      setState(() {
                        state.availablePresets.remove(timing);
                        state.selectedTimings.remove(timing);
                        if (state.selectedTimings.isEmpty &&
                            state.availablePresets.isNotEmpty) {
                          state.selectedTimings
                              .add(state.availablePresets.first);
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
                        ? const Color(0xFFFA6144).withValues(alpha: 0.35)
                        : const Color(0xFF64748B).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: isSelected
                        ? const Color(0xFFFF7D65)
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

  Widget _buildModeCard({
    required AlertSoundVibrationMode mode,
    required _SubAlertState state,
  }) {
    final isSelected = state.selectedMode == mode;
    const orangeColor = Color(0xFFFF7D65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state.enabled ? () => setState(() => state.selectedMode = mode) : null,
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
                  : const Color(0xFF434A59).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Squared container with rounded corners (10dp)
              // ALL logos are orange (#FF7D65) when selected!
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
                  size: 20,
                  color: isSelected ? orangeColor : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              // Clean Title without explanatory sub-text
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
              // Concentric Radio Indicator
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
