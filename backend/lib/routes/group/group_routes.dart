import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/group/group_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class GroupRoutes {
  Handler get router {
    final router = Router();
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── GROUPS & MEMBERS ───────────────────────────────────────────────────
    router.get('/', authPipeline.addHandler(GroupController.listGroups));
    router.post('/', authPipeline.addHandler(GroupController.createGroup));
    router.post('/join', authPipeline.addHandler(GroupController.joinGroup));

    router.get(
      '/<idGroup>',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.getGroupDetail(r, idGroup),
      )(req),
    );
    router.put(
      '/<idGroup>',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.updateGroup(r, idGroup),
      )(req),
    );
    router.delete(
      '/<idGroup>/leave',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.leaveGroup(r, idGroup),
      )(req),
    );
    router.delete(
      '/<idGroup>',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.disbandGroup(r, idGroup),
      )(req),
    );

    // ─── MILESTONES ─────────────────────────────────────────────────────────
    router.get(
      '/<idGroup>/milestones',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.listMilestones(r, idGroup),
      )(req),
    );
    router.post(
      '/<idGroup>/milestones',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.createMilestone(r, idGroup),
      )(req),
    );
    router.put(
      '/<idGroup>/milestones/<idMilestone>',
      (Request req, String idGroup, String idMilestone) =>
          authPipeline.addHandler(
        (Request r) =>
            GroupController.updateMilestone(r, idGroup, idMilestone),
      )(req),
    );
    router.delete(
      '/<idGroup>/milestones/<idMilestone>',
      (Request req, String idGroup, String idMilestone) =>
          authPipeline.addHandler(
        (Request r) =>
            GroupController.deleteMilestone(r, idGroup, idMilestone),
      )(req),
    );

    // ─── GROUP TASKS ────────────────────────────────────────────────────────
    router.get(
      '/<idGroup>/tasks',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.listGroupTasks(r, idGroup),
      )(req),
    );
    router.post(
      '/<idGroup>/tasks',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.createGroupTask(r, idGroup),
      )(req),
    );
    router.put(
      '/<idGroup>/tasks/<idGroupTask>',
      (Request req, String idGroup, String idGroupTask) =>
          authPipeline.addHandler(
        (Request r) =>
            GroupController.updateGroupTask(r, idGroup, idGroupTask),
      )(req),
    );
    router.patch(
      '/<idGroup>/tasks/<idGroupTask>/complete',
      (Request req, String idGroup, String idGroupTask) =>
          authPipeline.addHandler(
        (Request r) =>
            GroupController.toggleGroupTaskComplete(r, idGroup, idGroupTask),
      )(req),
    );
    router.delete(
      '/<idGroup>/tasks/<idGroupTask>',
      (Request req, String idGroup, String idGroupTask) =>
          authPipeline.addHandler(
        (Request r) =>
            GroupController.deleteGroupTask(r, idGroup, idGroupTask),
      )(req),
    );

    // ─── SUBTASKS ───────────────────────────────────────────────────────────
    router.get(
      '/<idGroup>/tasks/<idGroupTask>/subtasks',
      (Request req, String idGroup, String idGroupTask) =>
          authPipeline.addHandler(
        (Request r) => GroupController.listSubTasks(r, idGroup, idGroupTask),
      )(req),
    );
    router.post(
      '/<idGroup>/tasks/<idGroupTask>/subtasks',
      (Request req, String idGroup, String idGroupTask) =>
          authPipeline.addHandler(
        (Request r) => GroupController.createSubTask(r, idGroup, idGroupTask),
      )(req),
    );
    router.patch(
      '/<idGroup>/tasks/<idGroupTask>/subtasks/<idSubTask>/complete',
      (Request req, String idGroup, String idGroupTask, String idSubTask) =>
          authPipeline.addHandler(
        (Request r) => GroupController.toggleSubTaskComplete(
          r,
          idGroup,
          idGroupTask,
          idSubTask,
        ),
      )(req),
    );
    router.delete(
      '/<idGroup>/tasks/<idGroupTask>/subtasks/<idSubTask>',
      (Request req, String idGroup, String idGroupTask, String idSubTask) =>
          authPipeline.addHandler(
        (Request r) => GroupController.deleteSubTask(
          r,
          idGroup,
          idGroupTask,
          idSubTask,
        ),
      )(req),
    );

    // ─── MEETINGS ───────────────────────────────────────────────────────────
    router.get(
      '/<idGroup>/meetings',
      (Request req, String idGroup) => authPipeline.addHandler(
        (Request r) => GroupController.listMeetings(r, idGroup),
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
      (Request req, String idGroup, String idMeeting) =>
          authPipeline.addHandler(
        (Request r) => GroupController.updateMeeting(r, idGroup, idMeeting),
      )(req),
    );
    router.delete(
      '/<idGroup>/meetings/<idMeeting>',
      (Request req, String idGroup, String idMeeting) =>
          authPipeline.addHandler(
        (Request r) => GroupController.deleteMeeting(r, idGroup, idMeeting),
      )(req),
    );

    return router;
  }
}
