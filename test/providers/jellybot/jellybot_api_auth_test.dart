import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/shared_provider.dart';
import 'package:fladder/util/fladder_config.dart';

void main() {
  late HttpServer server;
  // Sentinel distinguishes "no request received" from "request without header".
  Map<String, String?> receivedHeaders = const {};

  setUp(() async {
    receivedHeaders = const {'sentinel': 'no-request-received'};
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) {
      receivedHeaders = {
        'P-Access-Token-Id': request.headers.value('P-Access-Token-Id'),
        'P-Access-Token': request.headers.value('P-Access-Token'),
      };
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.json
        ..write('"ok"');
      request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
    FladderConfig.fromJson(const {});
  });

  Future<ProviderContainer> createContainer() async {
    SharedPreferences.setMockInitialValues({'jellybotBaseUrl': 'http://127.0.0.1:${server.port}'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('requests carry the Pangolin access-token headers when config has credentials', () async {
    FladderConfig.fromJson(const {
      'jellybotAccessTokenId': 'token-id',
      'jellybotAccessToken': 'token-secret',
    });
    final container = await createContainer();

    await container.read(jellybotApiProvider).apiLogsGet();

    expect(receivedHeaders, {
      'P-Access-Token-Id': 'token-id',
      'P-Access-Token': 'token-secret',
    });
  });

  test('requests carry no access-token headers when config has no credentials', () async {
    FladderConfig.fromJson(const {});
    final container = await createContainer();

    await container.read(jellybotApiProvider).apiLogsGet();

    expect(receivedHeaders, {
      'P-Access-Token-Id': null,
      'P-Access-Token': null,
    });
  });

  test('requests carry no access-token headers when only one credential is set', () async {
    FladderConfig.fromJson(const {'jellybotAccessTokenId': 'token-id'});
    final container = await createContainer();

    await container.read(jellybotApiProvider).apiLogsGet();

    expect(receivedHeaders, {
      'P-Access-Token-Id': null,
      'P-Access-Token': null,
    });
  });

  test('empty-string credentials are treated as absent', () async {
    FladderConfig.fromJson(const {
      'jellybotAccessTokenId': '',
      'jellybotAccessToken': '',
    });
    final container = await createContainer();

    await container.read(jellybotApiProvider).apiLogsGet();

    expect(receivedHeaders, {
      'P-Access-Token-Id': null,
      'P-Access-Token': null,
    });
  });

  test('credentials loaded after the client was built apply even when the provider is pinned alive', () async {
    // Non-web platforms load config.json in a post-frame callback
    // (base_app_wrapper.dart), so the client can be built before credentials
    // exist — and keepAlive watchers (e.g. addedCrawlLinkUrlsProvider) can pin
    // it alive forever, so the headers must be read per request, not at build.
    FladderConfig.fromJson(const {});
    final container = await createContainer();
    final subscription = container.listen(jellybotApiProvider, (_, __) {});
    addTearDown(subscription.close);

    final client = container.read(jellybotApiProvider);
    await client.apiLogsGet();
    expect(receivedHeaders['P-Access-Token'], isNull);

    FladderConfig.fromJson(const {
      'jellybotAccessTokenId': 'token-id',
      'jellybotAccessToken': 'token-secret',
    });
    // Same client instance, no rebuild — the interceptor must see the new config.
    await client.apiLogsGet();

    expect(receivedHeaders, {
      'P-Access-Token-Id': 'token-id',
      'P-Access-Token': 'token-secret',
    });
  });
}
