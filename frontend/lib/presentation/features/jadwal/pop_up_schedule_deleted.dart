import 'package:flutter/material.dart';
import 'pop_up_pemberitahuan.dart';

export 'pop_up_pemberitahuan.dart';

/// Top pop-up notification confirming schedule was deleted successfully.
class PopUpScheduleDeleted {
  static void show(BuildContext context) {
    PopUpPemberitahuan.scheduleDeleted(context);
  }
}
