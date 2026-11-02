import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';
import 'models/schedule_model.dart';

/// Modal dialog warning users of an overlapping time conflict with an existing schedule.
/// Offers "Adjust Time" (to cancel save and change hours) or "Save Anyway" (to override and proceed).
class PopUpScheduleConflictDialog extends StatelessWidget {
  final List<ScheduleModel> conflicts;
  final VoidCallback? onAdjustTime;
  final VoidCallback? onSaveAnyway;

  const PopUpScheduleConflictDialog({
    super.key,
    required this.conflicts,
    this.onAdjustTime,
    this.onSaveAnyway,
  });

  static Future<bool?> show(
    BuildContext context, {
    required List<ScheduleModel> conflicts,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpScheduleConflictDialog(
        conflicts: conflicts,
        onAdjustTime: () => Navigator.of(ctx).pop(false),
        onSaveAnyway: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryConflict = conflicts.isNotEmpty ? conflicts.first : null;
    final conflictTitle = primaryConflict?.title ?? 'Existing Schedule';
    final conflictTime = primaryConflict != null
        ? '${primaryConflict.timeStart} - ${primaryConflict.timeEnd} ${primaryConflict.timeZone}'
        : '';
    final hasMultiple = conflicts.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 340,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF323846),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 1,
            color: const Color(0xFF3B4150),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 35,
              offset: Offset(0, 20),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Warning Icon Badge (Warm Amber)
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF1E222B),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              'Schedule Conflict Detected',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(17, min: 15, max: 19),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Conflict details box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF282D37),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B4150),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overlaps with:',
                    style: TextStyle(
                      color: const Color(0xFFFBBF24),
                      fontSize: context.rFont(11, min: 10, max: 12),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conflictTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.rFont(13, min: 12, max: 14),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (conflictTime.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      conflictTime,
                      style: TextStyle(
                        color: const Color(0xFF8E95A5),
                        fontSize: context.rFont(11.5, min: 10.5, max: 12.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (hasMultiple) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+ ${conflicts.length - 1} other overlapping event',
                      style: TextStyle(
                        color: const Color(0xFF8E95A5),
                        fontSize: context.rFont(10.5, min: 9.5, max: 11.5),
                        fontFamily: 'Inter',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Message explanation
            Text(
              'Do you want to adjust the hours or proceed and save anyway?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF8E95A5),
                fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            // Actions Row
            Row(
              children: [
                // "Adjust Time" Button (Dismiss modal, stays on form)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onAdjustTime,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF434A59), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Adjust Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(13, min: 12, max: 14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // "Save Anyway" Button (Saves despite conflict)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onSaveAnyway,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Save Anyway',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(13, min: 12, max: 14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

