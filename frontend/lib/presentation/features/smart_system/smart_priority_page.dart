import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_context.dart';
import 'detail_card_smart_priority.dart';
import 'models/smart_priority_model.dart';
import 'models/smart_priority_repository.dart';
import 'widgets/smart_engine_status_card.dart';
import 'widgets/smart_priority_task_card.dart';

typedef AiSmartPriority = SmartPriorityPage;

class SmartPriorityPage extends StatefulWidget {
  final String userName;
  final VoidCallback? onBack;

  const SmartPriorityPage({
    super.key,
    this.userName = 'Yoga Perkasa Didik',
    this.onBack,
  });

  @override
  State<SmartPriorityPage> createState() => _SmartPriorityPageState();
}

class _SmartPriorityPageState extends State<SmartPriorityPage> {
  final SmartPriorityRepository _repo = SmartPriorityRepository.instance;
  SmartPriorityLevel? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredItems = _repo.getFiltered(_selectedFilter);
    final initials = widget.userName.length >= 2
        ? widget.userName.substring(0, 2).toUpperCase()
        : 'YP';

    final filterOptions = [
      (null, 'All Priorities', _repo.getCount(null)),
      (SmartPriorityLevel.high, 'High', _repo.getCount(SmartPriorityLevel.high)),
      (
        SmartPriorityLevel.medium,
        'Medium',
        _repo.getCount(SmartPriorityLevel.medium)
      ),
      (SmartPriorityLevel.low, 'Low', _repo.getCount(SmartPriorityLevel.low)),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rSpacing(16),
                vertical: context.rSpacing(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: widget.onBack ?? () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rSpacing(12)),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI Smart Priority',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.rFont(19, min: 17, max: 22),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: context.rSpacing(2)),
                        Text(
                          'Mamdani Fuzzy Logic Inference',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryAccent,
                            fontSize: context.rFont(11.5, min: 10, max: 13),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: context.rSpacing(8)),

                  // User Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Scrollable Area
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: context.rSpacing(16)),
                children: [
                  // Engine Status Card
                  const SmartEngineStatusCard(),
                  SizedBox(height: context.rSpacing(16)),

                  // Filter Chips Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: filterOptions.map((opt) {
                        final level = opt.$1;
                        final label = opt.$2;
                        final count = opt.$3;
                        final isSelected = _selectedFilter == level;

                        return Padding(
                          padding: EdgeInsets.only(right: context.rSpacing(8)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                setState(() => _selectedFilter = level);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.rSpacing(13),
                                  vertical: context.rSpacing(7),
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$label ($count)',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize:
                                        context.rFont(12, min: 10.5, max: 13.5),
                                    fontFamily: 'Inter',
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: context.rSpacing(16)),

                  // Ranked Task Cards List
                  if (filteredItems.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: context.rSpacing(36),
                      ),
                      child: Center(
                        child: Text(
                          'No tasks in this priority category.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: context.rFont(13, min: 11.5, max: 15),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredItems.map(
                      (item) => SmartPriorityTaskCard(
                        key: ValueKey(item.id),
                        item: item,
                        onTap: () {
                          DetailCardSmartPriority.show(context, item: item);
                        },
                      ),
                    ),

                  SizedBox(height: context.rSpacing(24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
