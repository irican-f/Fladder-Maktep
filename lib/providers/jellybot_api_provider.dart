import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/shared_provider.dart';
import 'package:fladder/util/fladder_config.dart';

part 'jellybot_api_provider.g.dart';

const String _jellybotBaseUrlKey = 'jellybotBaseUrl';

/// Returns the default Jellybot URL from config.json
String get _defaultJellybotUrl => FladderConfig.jellybotBaseUrl ?? 'http://localhost:8888';

/// Provider for the Jellybot base URL.
/// Reads from SharedPreferences if set, otherwise falls back to config.json default.
final jellybotBaseUrlProvider = StateNotifierProvider<JellybotBaseUrlNotifier, String>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return JellybotBaseUrlNotifier(sharedPrefs);
});

class JellybotBaseUrlNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  JellybotBaseUrlNotifier(this._prefs) : super(_loadUrl(_prefs));

  static String _loadUrl(SharedPreferences prefs) {
    return prefs.getString(_jellybotBaseUrlKey) ?? _defaultJellybotUrl;
  }

  Future<void> setUrl(String url) async {
    await _prefs.setString(_jellybotBaseUrlKey, url);
    state = url;
  }

  Future<void> resetToDefault() async {
    await _prefs.remove(_jellybotBaseUrlKey);
    state = _defaultJellybotUrl;
  }

  bool get isUsingDefault => state == _defaultJellybotUrl;
}

@riverpod
class JellybotApi extends _$JellybotApi {
  @override
  Jellybot build() {
    final baseUrl = ref.watch(jellybotBaseUrlProvider);
    return Jellybot.create(
      baseUrl: Uri.parse(baseUrl),
      httpClient: _createHttpClient(),
      interceptors: [
        const _AccessTokenInterceptor(),
        // Level.headers would log the access tokens — keep at basic.
        HttpLoggingInterceptor(level: Level.basic),
      ],
    );
  }
}

/// Adds the Pangolin access-token headers from config.json to every request.
///
/// Reads [FladderConfig] per request rather than at client build time: config.json
/// loads in a post-frame callback on non-web platforms, and keepAlive watchers
/// (e.g. addedCrawlLinkUrlsProvider) can pin this client alive from before that
/// load until process exit.
class _AccessTokenInterceptor implements Interceptor {
  const _AccessTokenInterceptor();

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) {
    final tokenId = FladderConfig.jellybotAccessTokenId;
    final token = FladderConfig.jellybotAccessToken;
    if (tokenId == null || token == null) {
      return chain.proceed(chain.request);
    }
    return chain.proceed(
      applyHeaders(chain.request, {
        'P-Access-Token-Id': tokenId,
        'P-Access-Token': token,
      }),
    );
  }
}

/// Creates an HTTP client that handles SSL certificates properly on non-web platforms
http.Client? _createHttpClient() {
  if (kIsWeb) return null;

  final httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  return IOClient(httpClient);
}
