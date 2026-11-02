import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/impal_time_picker_dialog.dart';
import '../../../common_widgets/pop_up_pemberitahuan.dart';
import '../models/user_profile_model.dart';

/// Modal bottom sheet for customizing Daily Morning Briefing:
/// 1. Master enable/disable toggle
/// 2. Delivery time picker via [showImpalTimePicker]
/// 3. Granular topic selection (Personal Tasks, Lecture, External, Team Tasks, Meetings)
class DailyBriefingSettingsModal extends StatefulWidget {
  final UserProfileModel profile;
  final VoidCallback? onSaved;

  const DailyBriefingSettingsModal({
    super.key,
    required this.profile,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfileModel profile,
    VoidCallback? onSaved,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DailyBriefingSettingsModal(
        profile: profile,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<DailyBriefingSettingsModal> createState() =>
      _DailyBriefingSettingsModalState();
}

class _DailyBriefingSettingsModalState
    extends State<DailyBriefingSettingsModal> {
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

    if (picked != null) {
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
          // Keep at least one topic
          PopUpPemberitahuan.show(
            context,
            title: 'Topic Required',
            message: 'Please keep at least one agenda topic enabled for briefing.',
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

    if (widget.onSaved != null) {
      widget.onSaved!();
    }

    Navigator.of(context).pop();

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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
                        'Daily Morning Briefing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(18, min: 16, max: 22),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Customize delivery schedule and included agenda topics',
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
                  // Master Switch Card
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
                            size: 20,
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
                                  fontSize:
                                      context.rFont(14, min: 12.5, max: 16),
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

                  // Section: Briefing Time
                  Text(
                    'BRIEFING DELIVERY TIME',
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
                    'Select when the briefing summary should be delivered:',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.rSpacing(10)),

                  // Time Card Tile
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rSpacing(14),
                          vertical: context.rSpacing(12),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                const Color(0xFF434A59).withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 20,
                                color: Color(0xFF38BDF8),
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
                                      fontSize:
                                          context.rFont(13.5, min: 12, max: 15),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _briefingTime,
                                    style: TextStyle(
                                      color: const Color(0xFF38BDF8),
                                      fontSize:
                                          context.rFont(14, min: 12.5, max: 16),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
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
                                  color: _enabled
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: context.rSpacing(24)),

                  // Section: Notification Display Format
                  Text(
                    'NOTIFICATION DISPLAY FORMAT',
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
                    'Choose how the briefing summary is formatted on your lock screen:',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.rSpacing(10)),

                  // Detailed Option Card
                  _buildFormatOption(
                    isCompact: false,
                    title: 'Detailed Agenda (Recommended)',
                    subtitle:
                        'Lists specific agenda titles, times & bullet points directly on lock screen',
                    icon: Icons.format_list_bulleted_rounded,
                  ),
                  SizedBox(height: context.rSpacing(8)),
                  // Compact Option Card
                  _buildFormatOption(
                    isCompact: true,
                    title: 'Compact Summary',
                    subtitle:
                        'Minimal overview with total agenda count only (e.g. "3 agendas scheduled today")',
                    icon: Icons.short_text_rounded,
                  ),

                  SizedBox(height: context.rSpacing(24)),

                  // Section: Included Briefing Topics
                  Text(
                    'INCLUDED BRIEFING TOPICS',
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
                    'Choose which agendas will be summarized in your morning report:',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: context.rFont(12, min: 10.5, max: 13.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: context.rSpacing(10)),

                  // Unified Topics Card with Dividers
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF434A59).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: DailyBriefingTopic.all.asMap().entries.map((e) {
                        final index = e.key;
                        final topic = e.value;
                        final isLast =
                            index == DailyBriefingTopic.all.length - 1;

                        return Column(
                          children: [
                            _buildTopicTile(topic),
                            if (!isLast)
                              Container(
                                width: double.infinity,
                                height: 1,
                                color: const Color(0xFF434A59)
                                    .withValues(alpha: 0.35),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
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
                        'Save Briefing Preferences',
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

  Widget _buildFormatOption({
    required bool isCompact,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _isCompact == isCompact;
    const orangeColor = Color(0xFFFF7D65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                  : const Color(0xFF434A59).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Squared container with rounded corners (10dp)
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
                  size: 20,
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
              // Concentric Radio Indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? orangeColor
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

  Widget _buildTopicTile(String topic) {
    final isSelected = _selectedTopics.contains(topic);
    final topicColor = DailyBriefingTopic.color(topic);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled ? () => _toggleTopic(topic) : null,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rSpacing(14),
            vertical: context.rSpacing(11),
          ),
          child: Row(
            children: [
              // Topic Icon Container (Squared 10dp)
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
                  size: 19,
                  color: isSelected && _enabled
                      ? topicColor
                      : const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(width: context.rSpacing(12)),
              // Topic Label & Description
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
              // Checkmark / Switch Indicator
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

