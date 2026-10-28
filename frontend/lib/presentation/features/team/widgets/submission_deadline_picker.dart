import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import '../../../common_widgets/impal_date_picker_dialog.dart';
import '../../../common_widgets/impal_time_picker_dialog.dart';

/// Interactive dual-picker widget for selecting task submission date and time.
///
/// Features side-by-side recessed containers with tabular number rendering,
/// complying with AGENTS.md Section 1 & Section 3 requirements.
class SubmissionDeadlinePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const SubmissionDeadlinePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showImpalDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      title: 'Select Submission Date',
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showImpalTimePicker(
      context: context,
      initialTime: selectedTime,
      title: 'Select Submission Time',
    );
    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    // Format: Sat 18 Oct 2026
    return DateFormat('EEE dd MMM yyyy').format(date);
  }

  String _formatTime(TimeOfDay time) {
    // Format: 23:59 WIB
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Submission Deadline',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: context.rFont(14.5, min: 13, max: 17),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: context.rSpacing(8)),
        Row(
          children: [
            // Date Picker Tile
            Expanded(
              child: _PickerTile(
                icon: Icons.calendar_today_outlined,
                text: _formatDate(selectedDate),
                onTap: () => _pickDate(context),
              ),
            ),
            SizedBox(width: context.rSpacing(8)),
            // Time Picker Tile
            Expanded(
              child: _PickerTile(
                icon: Icons.access_time_rounded,
                text: _formatTime(selectedTime),
                onTap: () => _pickTime(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: context.rSpacing(10)),
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.textMuted,
                size: context.rIcon(14),
              ),
              SizedBox(width: context.rSpacing(6)),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: context.rFont(12, min: 11, max: 14),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
