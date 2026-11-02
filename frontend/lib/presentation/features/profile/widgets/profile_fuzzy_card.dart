import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_context.dart';

/// Card showing Intelligent System status:
/// 1. AI Fuzzy Mamdani Min-Max (Centroid Defuzzification) [Active badge]
/// 2. Score Explainability (XAI) [Switch toggle]
class ProfileFuzzyCard extends StatelessWidget {
  final bool isActive;
  final bool isScoreExplainabilityActive;
  final ValueChanged<bool>? onToggleScoreExplainability;
  final VoidCallback? onFuzzyModelTap;

  const ProfileFuzzyCard({
    super.key,
    this.isActive = true,
    this.isScoreExplainabilityActive = true,
    this.onToggleScoreExplainability,
    this.onFuzzyModelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'INTELLIGENT SYSTEM (AI FUZZY)',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: context.rFont(11.5, min: 10, max: 13),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: context.rSpacing(10)),

        // Card Container holding both items
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF434A59).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Fuzzy Inference Model
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onFuzzyModelTap,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rSpacing(14),
                      vertical: context.rSpacing(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.psychology_outlined,
                            size: 20,
                            color: Color(0xFFA78BFA),
                          ),
                        ),
                        SizedBox(width: context.rSpacing(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Fuzzy Inference Model',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.rFont(13.5, min: 12, max: 15),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Mamdani Min-Max (Centroid Defuzzification)',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: context.rFont(11, min: 10, max: 12.5),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                                : const Color(0xFF334155).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                  : const Color(0xFF64748B).withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF94A3B8),
                              fontSize: context.rFont(10, min: 9, max: 11.5),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        if (onFuzzyModelTap != null) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Horizontal Divider
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFF434A59).withValues(alpha: 0.35),
              ),

              // Row 2: Score Explainability (XAI)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rSpacing(14),
                  vertical: context.rSpacing(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: Color(0xFF34D399),
                      ),
                    ),
                    SizedBox(width: context.rSpacing(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Score Explainability (XAI)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.rFont(13.5, min: 12, max: 15),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Show mathematical reasons for task rank',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: context.rFont(11, min: 10, max: 12.5),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isScoreExplainabilityActive,
                      onChanged: onToggleScoreExplainability,
                      activeTrackColor: const Color(0xFF10B981),
                      activeThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF333846),
                      inactiveThumbColor: const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
