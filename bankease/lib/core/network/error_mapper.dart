import 'package:bankease/core/errors/bank_error.dart';
import 'package:dio/dio.dart';

BankError mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.badResponse:
      return _fromResponse(e.response!);

    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkError('Request cancelled');
    case DioExceptionType.cancel:
      return const NetworkError('Request cancelled');

    case DioExceptionType.badCertificate:
      return const ServerError(
          495, 'Could not verify the server\'s certificate');
    default:
      return const NetworkError('Something went wrong');
  }
}

BankError _fromResponse(Response<dynamic> response) {
  final status = response.statusCode ?? 0;

  // Our API always answers with { "error": { code, message, details } }
  final body = response.data;
  final error = body is Map<String, dynamic> ? body['error'] : null;
  final code = error is Map<String, dynamic> ? error['code'] as String? : null;
  final message =
      error is Map<String, dynamic> ? error['message'] as String? : null;
  final details = error is Map<String, dynamic>
      ? (error['details'] as Map<String, dynamic>? ?? const {})
      : const <String, dynamic>{};

  if (status == 401) return SessionExpired(message ?? 'Please log in again.');
  if (status == 400) {
    return ValidationError(
      message ?? 'Please check the details',
      details.map((key, value) => MapEntry(key, value.toString())),
    );
  }
  if (status == 409 || status == 422) {
    return BusinessError(
        code ?? 'RULE_BROKEN', message ?? 'That is not allowed', details);
  }
  return ServerError(
      status, message ?? 'Service unavailable. Please try again.');
}
