import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

/// Routes for User Profile and Student Class Diagram operations.
class ProfileRoutes {
  Handler get router {
    final router = Router();

    // Semua rute profil dilindungi autentikasi JWT
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── PROFILE CRUD & AUTH ──────────────────────────────────────────────────
    // GET  /api/profile           → Ambil profil pengguna beserta statistik
    // PUT  /api/profile           → Update data profil (nama, email)
    // PUT  /api/profile/password  → Ubah password pengguna

    router.get(
      '/',
      authPipeline.addHandler(ProfileController.getProfile),
    );

    router.put(
      '/',
      authPipeline.addHandler(ProfileController.updateProfile),
    );

    router.put(
      '/password',
      authPipeline.addHandler(ProfileController.changePassword),
    );

    // ─── CLASS DIAGRAM STUDENT METHODS ────────────────────────────────────────
    // GET  /api/profile/daily-agenda     → +viewDailyAgenda(date: Date)
    // GET  /api/profile/course-schedules → +viewCourseSchedule()
    // GET  /api/profile/remaining-tasks  → +viewRemainingTasks()
    // POST /api/profile/join-group       → +joinGroup(inviteCode: String)

    router.get(
      '/daily-agenda',
      authPipeline.addHandler(ProfileController.viewDailyAgenda),
    );

    router.get(
      '/course-schedules',
      authPipeline.addHandler(ProfileController.viewCourseSchedule),
    );

    router.get(
      '/remaining-tasks',
      authPipeline.addHandler(ProfileController.viewRemainingTasks),
    );

    router.post(
      '/join-group',
      authPipeline.addHandler(ProfileController.joinGroup),
    );

    return router;
  }
}

