import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/kelompok/group_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class GroupRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── KELOMPOK / TIM ENDPOINTS (/api/groups) ──────────────────────────────
    // GET  /api/groups               → Ambil semua kelompok yang diikuti user
    // POST /api/groups               → Buat kelompok baru (Create Team)
    // POST /api/groups/join          → Gabung kelompok dengan kode (Join Team)
    // GET  /api/groups/<idGroup>     → Detail kelompok, anggota, rapat, & tugas

    router.get(
      '/',
      authPipeline.addHandler(GroupController.getUserGroups),
    );

    router.post(
      '/',
      authPipeline.addHandler(GroupController.createGroup),
    );

    router.post(
      '/join',
      authPipeline.addHandler(GroupController.joinGroup),
    );

    router.get(
      '/<idGroup>',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.getGroupDetails(r, idGroup),
      )(req),
    );

    // ─── RAPAT KELOMPOK (/api/groups/<idGroup>/meetings) ─────────────────────
    router.get(
      '/<idGroup>/meetings',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.getGroupMeetings(r, idGroup),
      )(req),
    );

    router.post(
      '/<idGroup>/meetings',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.createMeeting(r, idGroup),
      )(req),
    );

    // ─── TUGAS KELOMPOK (/api/groups/<idGroup>/tasks) ────────────────────────
    router.get(
      '/<idGroup>/tasks',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.getGroupTasks(r, idGroup),
      )(req),
    );

    router.post(
      '/<idGroup>/tasks',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.createGroupTask(r, idGroup),
      )(req),
    );

    return router;
  }
}
