import 'package:dio/dio.dart';

import '../config.dart';
import '../storage/token_store.dart';
import 'api_exception.dart';

/// Thin HTTP layer over the courier API: token, language, and one error type.
class ApiClient {
  ApiClient(this._tokens, {Dio? dio, String? baseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl ?? AppConfig.apiRoot,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await _tokens.read();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      options.headers['Accept-Language'] = locale;
      handler.next(options);
    }));
  }

  final TokenStore _tokens;
  final Dio _dio;

  /// Language for server messages and status names; set from the app's locale.
  String locale = 'az';

  /// Called when the server says the token is no longer valid.
  void Function()? onUnauthenticated;

  Future<Map<String, dynamic>> get(String path) => _send(() => _dio.get(path));

  Future<Map<String, dynamic>> post(String path, {Object? body, String? actionId}) => _send(() => _dio.post(
        path,
        data: body,
        options: Options(headers: {'X-Action-Id': ?actionId}),
      ));

  Future<Map<String, dynamic>> patch(String path, {Object? body}) => _send(() => _dio.patch(path, data: body));

  Future<Map<String, dynamic>> upload(String path, FormData form, {String? actionId}) => _send(() => _dio.post(
        path,
        data: form,
        options: Options(headers: {'X-Action-Id': ?actionId}),
      ));

  Future<Map<String, dynamic>> _send(Future<Response<dynamic>> Function() call) async {
    try {
      final res = await call();
      final data = res.data;
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final res = e.response;
    if (res == null) {
      return ApiException.network(e.message ?? 'Network error');
    }

    final body = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : <String, dynamic>{};
    if (res.statusCode == 401) onUnauthenticated?.call();

    final errors = <String, List<String>>{};
    final raw = body['errors'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) errors['$key'] = value.map((v) => '$v').toList();
      });
    }

    return ApiException(
      (body['message'] as String?) ?? res.statusMessage ?? 'Error ${res.statusCode}',
      status: res.statusCode,
      code: body['code'] as String?,
      fieldErrors: errors,
      body: body,
    );
  }
}
