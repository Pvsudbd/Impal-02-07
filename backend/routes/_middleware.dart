import 'package:dart_frog/dart_frog.dart';
import '../lib/middleware/cors_middleware.dart';
import '../lib/middleware/database_provider.dart';

Handler middleware(Handler handler) {
  return handler
      .use(corsMiddleware())
      .use(requestLogger())
      .use(databaseProvider());
}

