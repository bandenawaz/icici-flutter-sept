import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/core/network/error_mapper.dart';
import 'package:bankease/features/transfer/domain/transfer_draft.dart';

class TransferRepository {
  const TransferRepository(this._dio);
  final Dio _dio;

  /// The key makes a retry safe: the server processes one key only once.
  static String newIdempotencyKey() {
    final random = Random();
    final part = List.generate(16, (_) => random.nextInt(16).toRadixString(16)).join();
    return '${DateTime.now().millisecondsSinceEpoch}-$part';
  }

  Future<TransferReceipt> transfer({
    required TransferDraft draft,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/transfers',
        data: {
          'fromAccountId': draft.from.id,
          'beneficiaryId': draft.to.id,
          'amountPaise': draft.amountPaise,
          'remarks': draft.remarks,
        },
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      return TransferReceipt.fromJson(response.data!, draft);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}

final transferRepositoryProvider =
    Provider<TransferRepository>((ref) => TransferRepository(ref.watch(dioProvider)));
