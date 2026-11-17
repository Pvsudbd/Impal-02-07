import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/todo/todo_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class TodoRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── TO-DO ITEM ENDPOINTS (/api/todo) ────────────────────────────────────
    // GET    /api/todo               → Ambil daftar to-do item milik user
    // POST   /api/todo               → Buat to-do item baru
    // PUT    /api/todo/<idItem>/toggle → Toggle status selesai (is_done)
    // DELETE /api/todo/<idItem>      → Hapus to-do item

    router.get(
      '/',
      authPipeline.addHandler(TodoController.getTodos),
    );

    router.post(
      '/',
      authPipeline.addHandler(TodoController.createTodo),
    );

    router.put(
      '/<idItem>/toggle',
      (Request req, String idItem) => authPipeline.addHandler(
        (Request r) => TodoController.toggleTodo(r, idItem),
      )(req),
    );

    router.delete(
      '/<idItem>',
      (Request req, String idItem) => authPipeline.addHandler(
        (Request r) => TodoController.deleteTodo(r, idItem),
      )(req),
    );

    return router;
  }
}
