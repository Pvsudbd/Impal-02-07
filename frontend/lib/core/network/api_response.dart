/// Standard Dart Frog Envelope Wrapper:
/// ```json
/// {
///   "success": true,
///   "message": "Pesan deskriptif",
///   "data": { ... },
///   "error": null
/// }
/// ```
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T? value)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null ? toJsonT(data) : data,
      'error': error,
    };
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data, error: $error)';
}

