// Unified Task Form architecture: Create and Edit tasks are now consolidated
// into a single cohesive, high-performance page implementation in create_task.dart.
// This file serves as a clean, backward-compatible export and type alias module.

import 'create_task.dart';

export 'create_task.dart';
export 'models/task_item_model.dart';

typedef EditTaskPage = CreateTaskPage;
typedef EditTask = CreateTaskPage;
