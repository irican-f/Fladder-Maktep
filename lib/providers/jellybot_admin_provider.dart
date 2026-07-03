import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';

part 'jellybot_admin_provider.g.dart';

/// Read-side providers for the jellybot admin pages. Mutations live in the
/// pages themselves (existing section convention) and invalidate these.
@riverpod
Future<List<ApiClientDto>> jellybotApiClients(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiApiClientsGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load API clients (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<List<IProvider>> jellybotAllProviders(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiProvidersAllGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load providers (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<LiveTvSourceResult> jellybotLiveTvSource(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiSettingsLiveTvSourceGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load Live TV source (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<List<String>> jellybotLiveTvCountries(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiSettingsLiveTvSourceCountriesGet();
  if (!response.isSuccessful || response.body == null) {
    return const <String>[];
  }
  return response.body!;
}
