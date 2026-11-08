import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../../controllers/agenda/agenda_controller.dart';
import '../../middleware/auth/auth_middleware.dart';

class AgendaRoutes {
  Handler get router {
    final router = Router();

    // Semua endpoint agenda dilindungi JWT Middleware
    final authPipeline = const Pipeline().addMiddleware(checkAuthMiddleware());

    // ─── UNIFIED ENDPOINTS (/api/agenda) ──────────────────────────────────────
    // GET    /api/agenda             → Ambil seluruh jadwal (Course + Personal)
    // POST   /api/agenda             → Buat jadwal (otomatis mendeteksi tipe)
    // DELETE /api/agenda/<idAgenda>  → Hapus jadwal (otomatis mendeteksi tipe)

    router.get(
      '/',
      authPipeline.addHandler(AgendaController.getAllSchedules),
    );

    router.post(
      '/',
      authPipeline.addHandler(AgendaController.createAgenda),
    );

    router.put(
      '/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.updateAgenda(r, idAgenda),
      )(req),
    );

    router.delete(
      '/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.deleteAgenda(r, idAgenda),
      )(req),
    );

    // ─── COURSE SCHEDULE ENDPOINTS (/api/agenda/course) ───────────────────────
    // GET    /api/agenda/course             → Ambil semua jadwal kuliah
    // POST   /api/agenda/course             → Buat jadwal kuliah baru
    // PUT    /api/agenda/course/<idAgenda>  → Update jadwal kuliah
    // DELETE /api/agenda/course/<idAgenda>  → Hapus jadwal kuliah

    router.get(
      '/course',
      authPipeline.addHandler(AgendaController.getCourseSchedules),
    );

    router.post(
      '/course',
      authPipeline.addHandler(AgendaController.createCourseSchedule),
    );

    router.put(
      '/course/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.updateCourseSchedule(r, idAgenda),
      )(req),
    );

    router.delete(
      '/course/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.deleteCourseSchedule(r, idAgenda),
      )(req),
    );

    // ─── PERSONAL SCHEDULE ENDPOINTS (/api/agenda/personal) ───────────────────
    // GET    /api/agenda/personal             → Ambil semua jadwal personal
    // POST   /api/agenda/personal             → Buat jadwal personal baru
    // PUT    /api/agenda/personal/<idAgenda>  → Update jadwal personal
    // DELETE /api/agenda/personal/<idAgenda>  → Hapus jadwal personal

    router.get(
      '/personal',
      authPipeline.addHandler(AgendaController.getPersonalSchedules),
    );

    router.post(
      '/personal',
      authPipeline.addHandler(AgendaController.createPersonalSchedule),
    );

    router.put(
      '/personal/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.updatePersonalSchedule(r, idAgenda),
      )(req),
    );

    router.delete(
      '/personal/<idAgenda>',
      (Request req, String idAgenda) => authPipeline.addHandler(
        (Request r) => AgendaController.deletePersonalSchedule(r, idAgenda),
      )(req),
    );

    return router;
  }
}

