import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/core/network/error_mapper.dart';
import 'package:bankease/features/transactions/domain/txn.dart';

class TransactionsRepository {
  const TransactionsRepository(this._dio);
  final Dio _dio;

  Future<List<Txn>> fetchPage(String accountId, {int page = 0, int size = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/accounts/$accountId/transactions',
        queryParameters: {'page': page, 'size': size},
      );
      final items = response.data!['items'] as List<dynamic>;
      return items.map((e) => Txn.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepository(ref.watch(dioProvider)),
);
