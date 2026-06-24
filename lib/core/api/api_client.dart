import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../error/app_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  //static const _baseUrl =
     //'http://192.168.18.246:8000/api/mobile/v1'; //ini untuk laptop maharani aja
  static const _baseUrl = 'https://app-academy.26and2yoga.com//api/mobile/v1';//kantor
  //static conts _baseUrl =    BUATLAH API KALIAN KALAU MAU 192.168.110.246
  // static const _baseUrl = 'http://192.168.110.186:8000/api/mobile/v1'; //kos
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Auth interceptor — inject token otomatis
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(_handleError(error));
        },
      ),
    );

    // Logger (debug only)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    return dio;
  }

  static String? resolveUrl(String? path) {
    if (path == null) return null;
    final value = path.trim();
    if (value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;

    final baseUri = Uri.parse(_baseUrl);
    final origin = Uri(
      scheme: baseUri.scheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
    );

    if (value.startsWith('/')) {
      return origin.resolveUri(Uri.parse(value)).toString();
    }

    return origin.resolve(value).toString();
  }

  static DioException _handleError(DioException error) {
    AppException appException;

    switch (error.response?.statusCode) {
      case 401:
        appException = const UnauthorizedException();
      case 403:
        appException = const ForbiddenException();
      case 404:
        appException = const NotFoundException();
      case 422:
        final data = error.response?.data;
        appException = ValidationException(
          message: data?['message'] ?? 'Validation failed.',
          errors: data?['errors'] ?? {},
        );
      case null:
        appException = const NetworkException();
      default:
        appException = const ServerException();
    }

    return DioException(
      requestOptions: error.requestOptions,
      error: appException,
      response: error.response,
      type: error.type,
    );
  }
}
