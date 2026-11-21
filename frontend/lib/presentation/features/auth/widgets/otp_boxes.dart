import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/top_toast.dart';

/// 6-digit OTP Input field row with automatic focus shifting, paste handling, and error states.
class OtpBoxes extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String? errorMessage;
  final VoidCallback? onCompleted;

  const OtpBoxes({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.errorMessage,
    this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 348),
        child: Row(
          children: [
            for (int index = 0; index < 6; index++) ...[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (errorMessage != null && errorMessage!.isNotEmpty)
                            ? const Color(0xFFEF4444)
                            : focusNodes[index].hasFocus
                                ? AppColors.primary
                                : AppColors.borderSubtle,
                        width: (focusNodes[index].hasFocus ||
                                (errorMessage != null &&
                                    errorMessage!.isNotEmpty))
                            ? 1.5
                            : 1.0,
                      ),
                      boxShadow: focusNodes[index].hasFocus
                          ? const [
                              BoxShadow(
                                color: Color(0x33EF4444),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      onTap: TopToast.dismiss,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      cursorColor: AppColors.primary,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        if (value.length > 1) {
                          final digits = value.replaceAll(RegExp(r'\D'), '');
                          for (int i = 0;
                              i < digits.length && (index + i) < 6;
                              i++) {
                            controllers[index + i].text = digits[i];
                          }
                          final nextIdx =
                              (index + digits.length).clamp(0, 5);
                          focusNodes[nextIdx].requestFocus();
                          _checkComplete();
                          return;
                        }
                        if (value.isNotEmpty && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                        _checkComplete();
                      },
                    ),
                  ),
                ),
              ),
              if (index < 5) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  void _checkComplete() {
    final fullOtp = controllers.map((c) => c.text.trim()).join();
    if (fullOtp.length == 6 && onCompleted != null) {
      onCompleted!();
    }
  }
}

