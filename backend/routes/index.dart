import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'success',
      'framework': 'Dart Frog',
      'version': '1.2.6',
      'message': 'Backend Impal-02-07 (Dart Frog REST API) berjalan dengan sukses!',
      'endpoints': {
        'root': '/',
        'testDb': '/test-db',
        'tables': '/tables',
        'auth': '/api/auth',
        'agenda': '/api/agenda',
        'profile': '/api/profile',
      },
    },
  );
}

