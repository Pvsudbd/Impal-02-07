import 'package:flutter/material.dart';
import 'edit_task_var1.dart';
import 'models/schedule_model.dart';

/// Edit task screen (Variation 2)
class EditTaskVar2 extends StatelessWidget {
  final ScheduleModel? schedule;

  const EditTaskVar2({
    super.key,
    this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return EditTaskPage(schedule: schedule);
  }
}