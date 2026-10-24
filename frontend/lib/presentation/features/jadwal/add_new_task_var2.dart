import 'package:flutter/material.dart';
import 'add_new_task_var1.dart';

/// Add new task screen (Variation 2 - Lecture by default)
class AddNewTaskVar2 extends StatelessWidget {
  const AddNewTaskVar2({super.key});

  @override
  Widget build(BuildContext context) {
    return const AddNewTaskPage(initialType: 'Lecture');
  }
}