import 'team_task_model.dart';

/// Data model representing a high-level project Milestone grouping multiple team tasks
/// with an overarching general deadline (e.g., 'Responsi 1', 'Sprint 1', 'Tubes Tahap 1').
class TeamMilestoneModel {
  final String id;
  final String teamCode;
  final String title;
  final String? description;
  final DateTime deadline;
  final String? formattedDeadline;
  final String? dueBadge;
  final List<String> taskIds;
  final DateTime dateCreated;

  const TeamMilestoneModel({
    required this.id,
    required this.teamCode,
    required this.title,
    this.description,
    required this.deadline,
    this.formattedDeadline,
    this.dueBadge,
    this.taskIds = const [],
    required this.dateCreated,
  });

  /// Formatted deadline string with fallback.
  String get effectiveFormattedDeadline {
    if (formattedDeadline != null && formattedDeadline!.trim().isNotEmpty) {
      return formattedDeadline!;
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[deadline.weekday - 1];
    final monthName = months[deadline.month - 1];
    final hourStr = deadline.hour.toString().padLeft(2, '0');
    final minStr = deadline.minute.toString().padLeft(2, '0');
    return '$dayName ${deadline.day} $monthName ${deadline.year}, $hourStr:$minStr WIB';
  }

  /// Calculates dynamic due badge (e.g., '6d', '18h', 'Overdue').
  String get effectiveDueBadge {
    if (dueBadge != null && dueBadge!.trim().isNotEmpty) {
      return dueBadge!.trim();
    }
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (difference.isNegative) {
      return 'Overdue';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours}h';
    }
    return '<1h';
  }

  /// Returns whether this milestone is urgent or overdue.
  bool get isUrgent {
    final badge = effectiveDueBadge.toLowerCase();
    if (badge == 'overdue') return true;
    if (badge.endsWith('h')) {
      final h = int.tryParse(badge.replaceAll('h', '')) ?? 24;
      return h <= 24;
    }
    return false;
  }

  /// Returns tasks belonging to this milestone from a list of all team tasks.
  List<TeamTaskModel> getMemberTasks(List<TeamTaskModel> allTasks) {
    return allTasks.where((t) => taskIds.contains(t.id)).toList();
  }

  /// Calculates number of completed tasks under this milestone.
  int getCompletedCount(List<TeamTaskModel> allTasks) {
    final members = getMemberTasks(allTasks);
    return members.where((t) => t.isDone).length;
  }

  /// Calculates total tasks registered under this milestone.
  int getTotalCount(List<TeamTaskModel> allTasks) {
    return getMemberTasks(allTasks).length;
  }

  /// Returns completion fraction from 0.0 to 1.0.
  double getProgressFraction(List<TeamTaskModel> allTasks) {
    final total = getTotalCount(allTasks);
    if (total == 0) return 0.0;
    return (getCompletedCount(allTasks) / total).clamp(0.0, 1.0);
  }

  /// Returns completion percentage (0 - 100).
  int getProgressPercent(List<TeamTaskModel> allTasks) {
    return (getProgressFraction(allTasks) * 100).round();
  }

  /// Checks if all tasks under this milestone are completed.
  bool isAllCompleted(List<TeamTaskModel> allTasks) {
    final members = getMemberTasks(allTasks);
    if (members.isEmpty) return false;
    return members.every((t) => t.isDone);
  }

  TeamMilestoneModel copyWith({
    String? id,
    String? teamCode,
    String? title,
    String? description,
    DateTime? deadline,
    String? formattedDeadline,
    String? dueBadge,
    List<String>? taskIds,
    DateTime? dateCreated,
  }) {
    return TeamMilestoneModel(
      id: id ?? this.id,
      teamCode: teamCode ?? this.teamCode,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      formattedDeadline: formattedDeadline ?? this.formattedDeadline,
      dueBadge: dueBadge ?? this.dueBadge,
      taskIds: taskIds ?? this.taskIds,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }
}
