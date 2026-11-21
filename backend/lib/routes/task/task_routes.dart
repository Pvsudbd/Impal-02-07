import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/task/task_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class TaskRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── TASK ENDPOINTS (/api/task) ──────────────────────────────────────────
    // GET    /api/task                 → Ambil daftar task milik user
    // POST   /api/task                 → Buat task baru
    // GET    /api/task/<idTask>        → Ambil detail task
    // PUT    /api/task/<idTask>        → Update task
    // PUT    /api/task/<idTask>/toggle → Toggle status selesai (is_completed)
    // DELETE /api/task/<idTask>        → Hapus task

    router.get(
      '/',
      authPipeline.addHandler(TaskController.getTasks),
    );

    router.post(
      '/',
      authPipeline.addHandler(TaskController.createTask),
    );

    router.get(
      '/<idTask>',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.getTaskById(r, idTask),
      )(req),
    );

    router.put(
      '/<idTask>',
      (Request req, String idTask) => authPipeline.addHandler(
        (Request r) => TaskController.updateTask(r, idTask),
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

