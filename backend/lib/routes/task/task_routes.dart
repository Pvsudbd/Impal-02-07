import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/task/task_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class TaskRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    router.get(
      '/',
      authPipeline.addHandler(TaskController.listTasks),
    );

    router.get(
      '/<idTask>',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.getTask(r, idTask),
      )(req),
    );

    router.post(
      '/',
      authPipeline.addHandler(TaskController.createTask),
    );

    router.put(
      '/<idTask>',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.updateTask(r, idTask),
      )(req),
    );

    router.patch(
      '/<idTask>/complete',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.toggleComplete(r, idTask),
      )(req),
    );

    router.put(
      '/<idTask>/toggle',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.toggleComplete(r, idTask),
      )(req),
    );

    router.delete(
      '/<idTask>',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.deleteTask(r, idTask),
      )(req),
    );

    return router;
  }
}
