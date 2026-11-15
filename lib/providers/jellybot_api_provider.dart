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
import 'package:flutter_riverpod/legacy.dart';

part 'jellybot_api_provider.g.dart';

const String _jellybotBaseUrlKey = 'jellybotBaseUrl';

/// The JellyBot URL set by the user or the bundled config, or null when neither set one.
///
/// Usable from the background isolate: it only needs [SharedPreferences] and a loaded [FladderConfig].
String? configuredJellybotBaseUrl(SharedPreferences prefs) {
  final url = prefs.getString(_jellybotBaseUrlKey) ?? FladderConfig.jellybotBaseUrl;
  return url == null || url.isEmpty ? null : url;
}

/// Builds a JellyBot client that sends the Pangolin access-token headers. Also used by the background worker.
Jellybot createJellybotClient(String baseUrl) => Jellybot.create(
  baseUrl: Uri.parse(baseUrl),
  httpClient: _createHttpClient(),
  interceptors: [
    const _AccessTokenInterceptor(),
    // Level.headers would log the access tokens — keep at basic.
    HttpLoggingInterceptor(level: Level.basic),
  ],
);

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
    return createJellybotClient(ref.watch(jellybotBaseUrlProvider));
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
    final request = chain.request.copyWith(headers: jellyfinTokenAsAuthorization(chain.request.headers));
    final tokenId = FladderConfig.jellybotAccessTokenId;
    final token = FladderConfig.jellybotAccessToken;
    if (tokenId == null || token == null) {
      return chain.proceed(request);
    }
    return chain.proceed(applyHeaders(request, {'P-Access-Token-Id': tokenId, 'P-Access-Token': token}));
  }
}

/// Moves the user's Jellyfin token from the generated client's `X-Jellyfin-Token` header into
/// `Authorization: MediaBrowser Token="…"`: Pangolin answers the browser's CORS preflight with a fixed header list
/// that allows Authorization but not custom headers, so on web the custom header would block every call.
@visibleForTesting
Map<String, String> jellyfinTokenAsAuthorization(Map<String, String> headers) {
  final token = headers['X-Jellyfin-Token'];
  if (token == null) {
    return headers;
  }
  return {
    for (final entry in headers.entries)
      if (entry.key != 'X-Jellyfin-Token') entry.key: entry.value,
    'Authorization': 'MediaBrowser Token="$token"',
  };
}

/// Creates an HTTP client that handles SSL certificates properly on non-web platforms
http.Client? _createHttpClient() {
  if (kIsWeb) return null;

  final httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  return IOClient(httpClient);
}
