import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// Middleware CORS standar untuk Dart Frog API.
/// Mengizinkan komunikasi dari frontend Flutter Web, Chrome Dev, Android, dan Isar DB client.
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (RequestContext context) async {
      final corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept',
      };

      // Respon langsung untuk Preflight OPTIONS request
      if (context.request.method == HttpMethod.options) {
        return Response(statusCode: HttpStatus.ok, headers: corsHeaders);
      }

      final response = await innerHandler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          ...corsHeaders,
        },
      );
    };
  };
}

