import 'package:flutter/material.dart';
import 'models/task_item_model.dart';
import 'widgets/task_expandable_card.dart';

export 'models/task_item_model.dart';
export 'widgets/task_expandable_card.dart';

/// Backward compatibility alias matching Figma raw export class name
typedef CardTaskDashboard = TaskExpandableCard;

/// Backward compatibility standalone preview widget for the detail task card.
class DetailCardTaskPreview extends StatelessWidget {
  final TaskItemModel? task;
  final VoidCallback? onEdit;

  const DetailCardTaskPreview({
    super.key,
    this.task,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return TaskExpandableCard(
      task: task ?? TaskItemModel.defaultTasks.first,
      isInitiallyExpanded: true,
      onEdit: onEdit,
    );
  }
}
