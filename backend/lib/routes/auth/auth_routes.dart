import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/auth/auth_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class AuthRoutes {
  Handler get router {
    final router = Router();

    // POST /api/auth/register
    router.post('/register', AuthController.register);

    // POST /api/auth/login
    router.post('/login', AuthController.login);

    // GET /api/auth/me (Protected with JWT middleware)
    final pipeline = const Pipeline()
        .addMiddleware(checkAuthMiddleware())
        .addHandler(AuthController.getMe);

    router.get('/me', pipeline);

    return router;
  }
}
