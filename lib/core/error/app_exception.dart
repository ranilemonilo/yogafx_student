class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const AppException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Session expired. Please login again.'});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Access denied.'});
}


class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found.'});
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    required Map<String, dynamic> errors,
  }) : super(errors: errors);
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection. Please try again.'});
}

class ServerException extends AppException {
  const ServerException({super.message = 'Something went wrong. Please try again later.'});
}