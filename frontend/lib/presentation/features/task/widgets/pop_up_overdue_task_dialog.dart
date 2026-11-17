import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Modal dialog warning users when creating or editing a task with a deadline
/// that has already passed in time.
///
/// Prompts the user to either "Change Date" or "Proceed as Overdue" (which will
/// accept the task, mark its duration badge as 'Overdue', and bypass fuzzy priority).
class PopUpOverdueTaskDialog extends StatelessWidget {
  final String formattedDeadline;
  final VoidCallback? onChangeDate;
  final VoidCallback? onProceed;

  const PopUpOverdueTaskDialog({
    super.key,
    required this.formattedDeadline,
    this.onChangeDate,
    this.onProceed,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String formattedDeadline,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PopUpOverdueTaskDialog(
        formattedDeadline: formattedDeadline,
        onChangeDate: () => Navigator.of(ctx).pop(false),
        onProceed: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Warning Icon Badge (Coral Glow)
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFFA6144),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFA6144).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Modal Title
            Text(
              'Deadline in the Past?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.rFont(18, min: 16, max: 20),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Selected deadline preview badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF282D37),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF434A59), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: Color(0xFFFF7D65),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      formattedDeadline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 11.5,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Explanatory Message
            Text(
              'The deadline date you selected has already passed. The task will still be saved with status Overdue and will not receive intelligent fuzzy priority weighting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),

            // Status notice pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x26FA6144),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x4DFA6144), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFFA6144),
                    size: 15,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Status: Overdue • Fuzzy Weight: Off',
                    style: TextStyle(
                      color: Color(0xFFFA6144),
                      fontSize: 11.5,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions Row
            Row(
              children: [
                // "Change Date" Button (Dismiss modal, stays on form)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onChangeDate,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF434A59), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Change Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // "Proceed as Overdue" Button
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.rFont(12.5, min: 11.5, max: 13.5),
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
