import 'package:flutter/material.dart';
import 'pop_up_pemberitahuan.dart';

export 'pop_up_pemberitahuan.dart';

/// Top pop-up notification confirming schedule was updated successfully.
class PopUpScheduleUpdated {
  static void show(BuildContext context) {
    PopUpPemberitahuan.scheduleUpdated(context);
  }
}
