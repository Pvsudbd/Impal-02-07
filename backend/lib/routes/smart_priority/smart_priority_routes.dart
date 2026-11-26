import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/smart_priority/smart_priority_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class SmartPriorityRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    router.get(
      '/',
      authPipeline.addHandler(SmartPriorityController.getSmartPriority),
    );

    router.post(
      '/evaluate',
      authPipeline.addHandler(SmartPriorityController.evaluatePreview),
    );

    router.post(
      '/recalculate',
      authPipeline.addHandler(SmartPriorityController.recalculateAll),
    );

    return router;
  }
}
