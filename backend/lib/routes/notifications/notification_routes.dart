import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/notifications/notification_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

/// Routes untuk modul In-App Notifications & Sync Pengingat (REQ-009).
class NotificationRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    router.get('/', authPipeline.addHandler(NotificationController.getNotifications));
    router.post('/', authPipeline.addHandler(NotificationController.createOrSyncNotifications));
    router.post('/sync', authPipeline.addHandler(NotificationController.createOrSyncNotifications));
    router.patch('/read-all', authPipeline.addHandler(NotificationController.markAllAsRead));
    router.patch(
      '/<id>/read',
      authPipeline.addHandler((Request req) {
        final id = req.params['id'] ?? '';
        return NotificationController.markAsRead(req, id);
      }),
    );

    return router;
  }
}

