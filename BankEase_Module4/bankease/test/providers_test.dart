import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bankease/core/errors/bank_error.dart';
import 'package:bankease/core/network/api_client.dart';
import 'package:bankease/features/accounts/state/accounts_provider.dart';

/// A fake HTTP layer: Dio talks to this instead of the network, so the
/// tests are fast and work with no server running.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
          Future<void>? cancelFuture) async =>
      ResponseBody.fromString(body, statusCode,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});

  @override
  void close({bool force = false}) {}
}

ProviderContainer containerWith(int status, String body) {
  final dio = Dio()..httpClientAdapter = _FakeAdapter(status, body);
  return ProviderContainer(overrides: [dioProvider.overrideWithValue(dio)]);
}

void main() {
  test('accounts are parsed from the API response', () async {
    final container = containerWith(200, '''
      { "items": [ { "id": "BE1001", "type": "SAVINGS", "holderName": "Asha Rao",
        "number": "501000123451001", "ifsc": "BKEN0001234",
        "branch": "Bijapur Main", "balancePaise": 498050 } ] }
    ''');
    addTearDown(container.dispose);

    final accounts = await container.read(accountsProvider.future);

    expect(accounts, hasLength(1));
    expect(accounts.first.balancePaise, 498050);
    expect(accounts.first.maskedNumber, 'XXXX1001');
  });

  test('a 401 becomes SessionExpired', () async {
    final container = containerWith(401,
        '{ "error": { "code": "UNAUTHORIZED", "message": "Session expired" } }');
    addTearDown(container.dispose);

    await expectLater(
      container.read(accountsProvider.future),
      throwsA(isA<SessionExpired>()),
    );
  });

  test('a 422 becomes BusinessError with its code', () async {
    final container = containerWith(422,
        '{ "error": { "code": "INSUFFICIENT_FUNDS", "message": "Insufficient funds" } }');
    addTearDown(container.dispose);

    await expectLater(
      container.read(accountsProvider.future),
      throwsA(isA<BusinessError>()
          .having((e) => e.code, 'code', 'INSUFFICIENT_FUNDS')),
    );
  });
}
