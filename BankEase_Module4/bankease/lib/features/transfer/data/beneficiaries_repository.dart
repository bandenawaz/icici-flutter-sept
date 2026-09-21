import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/core/network/error_mapper.dart';
import 'package:bankease/features/transfer/domain/beneficiary.dart';

class BeneficiariesRepository {
  const BeneficiariesRepository(this._dio);
  final Dio _dio;

  Future<List<Beneficiary>> fetchAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/beneficiaries');
      final items = response.data!['items'] as List<dynamic>;
      return items
          .map((e) => Beneficiary.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Beneficiary> add({
    required String name,
    required String accountNumber,
    required String ifsc,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/beneficiaries',
        data: {'name': name, 'accountNumber': accountNumber, 'ifsc': ifsc},
      );
      return Beneficiary.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final beneficiariesRepositoryProvider = Provider<BeneficiariesRepository>(
  (ref) => BeneficiariesRepository(ref.watch(dioProvider)),
);
