import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/core/network/error_mapper.dart';
import 'package:bankease/features/accounts/domain/account.dart';

class AccountsRepository {
  const AccountsRepository(this._dio);
  final Dio _dio;

  Future<List<Account>> fetchAccounts() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/accounts');
      final items = response.data!['items'] as List<dynamic>;
      return items
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final accountsRepositoryProvider =
    Provider<AccountsRepository>((ref) => AccountsRepository(ref.watch(dioProvider)));
