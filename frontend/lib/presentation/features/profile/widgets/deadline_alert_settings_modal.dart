import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../models/user_profile_model.dart';

/// Interactive modal bottom sheet for customizing:
/// 1. Category alert timings (Days, Hours, Minutes, or Custom)
/// 2. Sound & Vibration mode (Sound & Vibrate, Sound Only, Vibration Only, or Silent)
class DeadlineAlertSettingsModal extends StatefulWidget {
  final UserProfileModel profile;
  final AlertCategoryType category;
  final void Function({
    required bool enabled,
    required List<String> timings,
    required AlertSoundVibrationMode mode,
  }) onSave;

  const DeadlineAlertSettingsModal({
    super.key,
    required this.profile,
    this.category = AlertCategoryType.taskDeadline,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    AlertCategoryType category = AlertCategoryType.taskDeadline,
    required void Function({
      required bool enabled,
      required List<String> timings,
      required AlertSoundVibrationMode mode,
    }) onSave,
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

class _DeadlineAlertSettingsModalState
    extends State<DeadlineAlertSettingsModal> {
  late bool _enabled;
  late Set<String> _selectedTimings;
  late AlertSoundVibrationMode _selectedMode;

  final TextEditingController _customNumberController =
      TextEditingController(text: '2');
  String _customUnit = 'Hours';

  List<String> get _defaultPresets {
    switch (widget.category) {
      case AlertCategoryType.classSchedule:
        return const [
          '1 Hour',
          '45 Minutes',
          '30 Minutes',
          '15 Minutes',
          '10 Minutes',
          '5 Minutes',
        ];
      case AlertCategoryType.teamMeeting:
        return const [
          '1 Day',
          '3 Hours',
          '1 Hour',
          '30 Minutes',
          '15 Minutes',
          '5 Minutes',
        ];
      case AlertCategoryType.taskDeadline:
        return const [
          'H-3 (3 Days)',
          'H-1 (24 Hours)',
          '6 Hours',
          '3 Hours',
          '1 Hour',
          '30 Minutes',
          '15 Minutes',
        ];
    }
  }

  late List<String> _availablePresets;

  @override
  void initState() {
    super.initState();
    final config = widget.profile.configFor(widget.category);
    _enabled = config.enabled;
    _selectedTimings = Set<String>.from(config.timings);
    _selectedMode = config.soundMode;

    _availablePresets = List<String>.from(_defaultPresets);
    for (final t in _selectedTimings) {
      if (!_availablePresets.contains(t)) {
        _availablePresets.add(t);
      }
    }
  }

  @override
  void dispose() {
    _customNumberController.dispose();
    super.dispose();
  }

  void _addCustomTiming() {
    final numText = _customNumberController.text.trim();
    final numVal = int.tryParse(numText);
    if (numVal == null || numVal <= 0) {
      PopUpPemberitahuan.show(
        context,
        title: 'Invalid Number',
        message: 'Please enter a valid number greater than 0.',
        icon: Icons.error_outline_rounded,
        iconBgColor: PopUpPemberitahuan.negativeColor,
      );
      return;
    }

    final customLabel = '$numVal $_customUnit';
    setState(() {
      if (!_availablePresets.contains(customLabel)) {
        _availablePresets.add(customLabel);
      }
      _selectedTimings.add(customLabel);
    });
  }

  void _save() {
    if (_selectedTimings.isEmpty && _enabled) {
      _selectedTimings.add(
        _defaultPresets.isNotEmpty ? _defaultPresets.first : 'H-1 (24 Hours)',
      );
    }

    widget.onSave(
      enabled: _enabled,
      timings: _selectedTimings.toList(),
      mode: _selectedMode,
    );

    Navigator.of(context).pop();

    PopUpPemberitahuan.show(
      context,
      title: 'Alert Preferences Saved',
      message: _enabled
          ? '${widget.category.label} alerts updated to ${_selectedTimings.map((t) => t.split(' ')[0]).join(', ')} • ${_selectedMode.shortLabel}.'
          : '${widget.category.label} alerts have been turned off.',
      icon: Icons.check_circle_outline_rounded,
      iconBgColor: PopUpPemberitahuan.positiveColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Notch
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
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
                        '${widget.category.label} Alert Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(18, min: 16, max: 22),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customize reminder lead times and delivery style for ${widget.category.label.toLowerCase()}',
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

          const Divider(height: 1, color: Color(0xFF333A48)),

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
                  // Master Switch for Category
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(14),
                      vertical: context.rSpacing(10),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _enabled
                                ? widget.category.accentColor
                                    .withValues(alpha: 0.18)
                                : const Color(0xFF475569)
                                    .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _enabled
                                ? widget.category.icon
                                : Icons.notifications_off_outlined,
                            size: 19,
                            color: _enabled
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
                                'Enable ${widget.category.label} Alerts',
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
                                _enabled
                                    ? 'System sends timely reminders'
                                    : 'All alerts for this category are muted',
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
                          value: _enabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF10B981),
                          inactiveThumbColor: Colors.white70,
                          inactiveTrackColor: const Color(0xFF434A59),
                          onChanged: (val) => setState(() => _enabled = val),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: context.rSpacing(20)),

                  // Section 1: Remind Me Before (Timings)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1. REMIND ME BEFORE',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: context.rFont(11.5, min: 10, max: 13),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      if (_availablePresets.length < _defaultPresets.length)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              for (final p in _defaultPresets) {
                                if (!_availablePresets.contains(p)) {
                                  _availablePresets.add(p);
                                }
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
                        ),
                    ],
                  ),
                  SizedBox(height: context.rSpacing(4)),
                  Text(
                    'Tap chip to select/deselect • Tap ✕ to remove interval:',
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
                    children: _availablePresets.map((timing) {
                      return _buildTimingChip(timing);
                    }).toList(),
                  ),

                  SizedBox(height: context.rSpacing(14)),

                  // Custom Timing Input Row (100% Equalized sizing across all 3 controls: 42dp height)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // 1. Number input (Matching 42dp Container with uniform background)
                        Container(
                          width: 56,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E232D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _customNumberController,
                            keyboardType: TextInputType.number,
                            enabled: _enabled,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(8)),
                        // 2. Unit dropdown (42dp height Container)
                        Expanded(
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E232D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _customUnit,
                                dropdownColor: const Color(0xFF1E232D),
                                isExpanded: true,
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
                                onChanged: _enabled
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
                        // 3. Add button (42dp height button)
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            key: const ValueKey('add_custom_timing_button'),
                            onPressed: _enabled ? _addCustomTiming : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '+ Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
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

                  // Section 2: Sound & Vibration Mode
                  Text(
                    '2. SOUND & VIBRATION MODE',
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

                  // 4 Mode Options (Radio Cards with Orange Icon & without orange card border)
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.soundAndVibrate,
                    accentColor: const Color(0xFFFF7D65),
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.soundOnly,
                    accentColor: const Color(0xFFFF7D65),
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.vibrationOnly,
                    accentColor: const Color(0xFF5B93FF),
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  _buildModeCard(
                    mode: AlertSoundVibrationMode.silent,
                    accentColor: const Color(0xFF94A3B8),
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

  Widget _buildTimingChip(String timing) {
    final isSelected = _selectedTimings.contains(timing);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled
            ? () {
                setState(() {
                  if (isSelected) {
                    if (_selectedTimings.length > 1) {
                      _selectedTimings.remove(timing);
                    }
                  } else {
                    _selectedTimings.add(timing);
                  }
                });
              }
            : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.only(
            left: 12,
            right: 6,
            top: 6,
            bottom: 6,
          ),
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
                      : (_enabled ? Colors.white70 : const Color(0xFF64748B)),
                  fontSize: context.rFont(12, min: 10.5, max: 13.5),
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              // Dedicated remove icon on every chip!
              GestureDetector(
                key: ValueKey('delete_timing_$timing'),
                behavior: HitTestBehavior.opaque,
                onTap: _enabled
                    ? () {
                        setState(() {
                          _availablePresets.remove(timing);
                          _selectedTimings.remove(timing);
                          if (_selectedTimings.isEmpty &&
                              _availablePresets.isNotEmpty) {
                            _selectedTimings.add(_availablePresets.first);
                          }
                        });
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFA6144).withValues(alpha: 0.35)
                        : const Color(0xFF64748B).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 11,
                    color: isSelected
                        ? const Color(0xFFFF7D65)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required AlertSoundVibrationMode mode,
    required Color accentColor,
  }) {
    final isSelected = _selectedMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled ? () => setState(() => _selectedMode = mode) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(12),
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF282D37) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF383F4D),
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
                      ? accentColor.withValues(alpha: 0.2)
                      : const Color(0xFF334155).withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  mode.icon,
                  size: 20,
                  color: isSelected ? accentColor : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.label,
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
                      mode.description,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rFont(11, min: 9.5, max: 12.5),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.rSpacing(8)),
              // Radio Indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFF64748B),
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
                          color: AppColors.primary,
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
