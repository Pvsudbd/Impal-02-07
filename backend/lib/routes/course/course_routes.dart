import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/course/course_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class CourseRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    router.get(
      '/',
      authPipeline.addHandler(CourseController.listCourses),
    );

    router.post(
      '/',
      authPipeline.addHandler(CourseController.createCourse),
    );

    router.put(
      '/<idCourse>',
      (Request req, String idCourse) => authPipeline.addHandler(
        (Request r) => CourseController.updateCourse(r, idCourse),
      )(req),
    );

    router.delete(
      '/<idCourse>',
      (Request req, String idCourse) => authPipeline.addHandler(
        (Request r) => CourseController.deleteCourse(r, idCourse),
      )(req),
    );

    return router;
  }
}
