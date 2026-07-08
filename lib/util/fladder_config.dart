import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

class FladderConfig {
  static FladderConfig _instance = FladderConfig._();
  FladderConfig._();

  static String? get baseUrl => _instance._baseUrl;
  static set baseUrl(String? value) => _instance._baseUrl = value;
  String? _baseUrl;

  static String? get jellybotBaseUrl => _instance._jellybotBaseUrl;
  static set jellybotBaseUrl(String? value) => _instance._jellybotBaseUrl = value;
  String? _jellybotBaseUrl;

  static String? get jellybotAccessTokenId => _instance._jellybotAccessTokenId;
  static set jellybotAccessTokenId(String? value) => _instance._jellybotAccessTokenId = value;
  String? _jellybotAccessTokenId;

  static String? get jellybotAccessToken => _instance._jellybotAccessToken;
  static set jellybotAccessToken(String? value) => _instance._jellybotAccessToken = value;
  String? _jellybotAccessToken;

  static String? get seerrBaseUrl => _instance._seerrBaseUrl;
  static set seerrBaseUrl(String? value) => _instance._seerrBaseUrl = value;
  String? _seerrBaseUrl;

  static void fromJson(Map<String, dynamic> json) => _instance = FladderConfig._fromJson(json);

  /// Loads [config/config.json] from the asset bundle (all platforms), overlaid
  /// with the git-ignored [config/config.local.json] holding private values
  /// (e.g. the Jellybot access tokens) that must stay out of the repository.
  static Future<void> loadBundledConfig() async {
    final base = await _loadJsonAsset('config/config.json', logFailure: true);
    final local = await _loadJsonAsset('config/config.local.json');
    if (base != null || local != null) {
      fromJson({...?base, ...?local});
    }
  }

  static Future<Map<String, dynamic>?> _loadJsonAsset(String path, {bool logFailure = false}) async {
    try {
      return jsonDecode(await rootBundle.loadString(path)) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      if (logFailure) {
        developer.log('Failed to load $path', error: e, stackTrace: stackTrace);
      }
      return null;
    }
  }

  factory FladderConfig._fromJson(Map<String, dynamic> json) {
    final config = FladderConfig._();
    final newUrl = json['baseUrl'] as String?;
    final newSeerrUrl = json['seerrBaseUrl'] as String?;

    config._baseUrl = newUrl?.isEmpty == true ? null : newUrl;
    config._seerrBaseUrl = newSeerrUrl?.isEmpty == true ? null : newSeerrUrl;
    final jellybotUrl = json['jellybotBaseUrl'] as String?;
    config._jellybotBaseUrl = jellybotUrl?.isEmpty == true ? null : jellybotUrl;
    final jellybotAccessTokenId = json['jellybotAccessTokenId'] as String?;
    config._jellybotAccessTokenId = jellybotAccessTokenId?.isEmpty == true ? null : jellybotAccessTokenId;
    final jellybotAccessToken = json['jellybotAccessToken'] as String?;
    config._jellybotAccessToken = jellybotAccessToken?.isEmpty == true ? null : jellybotAccessToken;
    return config;
  }
}
