import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/tags/tag_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class TagRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    router.get('/', authPipeline.addHandler(TagController.getTags));
    router.post('/', authPipeline.addHandler(TagController.createTag));
    router.delete(
      '/<idTag>',
      (Request req, String idTag) => authPipeline.addHandler(
        (Request r) => TagController.deleteTag(r, idTag),
      )(req),
    );

    return router;
  }
}

