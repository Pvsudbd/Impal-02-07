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

    router.put(
      '/<idGroup>/meetings/<idMeeting>',
      (Request req, String idGroup, String idMeeting) => authPipeline.addHandler(
        (Request r) => GroupController.updateMeeting(r, idGroup, idMeeting),
      )(req),
    );

    router.delete(
      '/<idGroup>/meetings/<idMeeting>',
      (Request req, String idGroup, String idMeeting) => authPipeline.addHandler(
        (Request r) => GroupController.deleteMeeting(r, idGroup, idMeeting),
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

    router.put(
      '/<idGroup>/tasks/<idTask>',
      (Request req, String idGroup, String idTask) => authPipeline.addHandler(
        (Request r) => GroupController.updateGroupTask(r, idGroup, idTask),
      )(req),
    );

    router.delete(
      '/<idGroup>/tasks/<idTask>',
      (Request req, String idGroup, String idTask) => authPipeline.addHandler(
        (Request r) => GroupController.deleteGroupTask(r, idGroup, idTask),
      )(req),
    );

    router.patch(
      '/<idGroup>/tasks/<idTask>/toggle',
      (Request req, String idGroup, String idTask) => authPipeline.addHandler(
        (Request r) => GroupController.toggleGroupTask(r, idGroup, idTask),
      )(req),
    );

    // ─── MILESTONE KELOMPOK (/api/groups/<idGroup>/milestones) ───────────────
    router.get(
      '/<idGroup>/milestones',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.getGroupMilestones(r, idGroup),
      )(req),
    );

    router.post(
      '/<idGroup>/milestones',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.createGroupMilestone(r, idGroup),
      )(req),
    );

    router.put(
      '/<idGroup>/milestones/<idMilestone>',
      (Request req, String idGroup, String idMilestone) => authPipeline.addHandler(
        (Request r) => GroupController.updateGroupMilestone(r, idGroup, idMilestone),
      )(req),
    );

    router.delete(
      '/<idGroup>/milestones/<idMilestone>',
      (Request req, String idGroup, String idMilestone) => authPipeline.addHandler(
        (Request r) => GroupController.deleteGroupMilestone(r, idGroup, idMilestone),
      )(req),
    );

    return router;
  }
}
