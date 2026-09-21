import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/network/api_config.dart';
import 'package:bankease/features/auth/state/session_provider.dart';

/// One Dio instance for the whole app, with two interceptors:
/// 1. attach the bearer token to every request
/// 2. log requests in debug builds
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
      // We handle every status ourselves in the error mapper.
      validateStatus: (status) => status != null && status < 400,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionProvider)?.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // A 401 means the session is gone: clear it, and the router
        // guard from Module 3 sends the user to the login screen.
        if (error.response?.statusCode == 401) {
          ref.read(sessionProvider.notifier).clear();
        }
        handler.next(error);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: false));
  }

  return dio;
});
