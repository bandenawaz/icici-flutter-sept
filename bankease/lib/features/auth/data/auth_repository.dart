import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/core/network/error_mapper.dart';
import 'package:bankease/features/auth/domain/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A repository hides HTTP and JSON from the rest of the app
/// Screens and notifiers only see Dart objects and BankError

class AuthRepository {
  const AuthRepository(this._dio);
  final Dio _dio;

  Future<Session> login(
      {required String customerId, required String pin}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'customerId': customerId,
          'pin': pin,
        },
      );
      return Session.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/auth/logout');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));
