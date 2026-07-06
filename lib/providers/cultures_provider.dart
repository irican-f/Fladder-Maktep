import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/providers/api_provider.dart';

part 'cultures_provider.g.dart';

@riverpod
class Cultures extends _$Cultures {
  @override
  List<CultureDto> build() {
    // Consumers only ever `ref.read` this momentarily at playback time, so
    // without a keepAlive link the provider disposes before the fetch lands
    // and every playback fires a wasted request. Pin while the fetch is in
    // flight and keep a successful result for the app's lifetime; release on
    // failure so the next read retries (dispose-and-refetch self-healing).
    final link = ref.keepAlive();
    _fetch(link);
    return const [];
  }

  Future<void> _fetch(KeepAliveLink link) async {
    try {
      final api = ref.read(jellyApiProvider);
      final response = await api.localizationCulturesGet();
      final cultures = response.body;
      if (cultures != null && cultures.isNotEmpty) {
        state = cultures;
      } else {
        link.close();
      }
    } catch (e) {
      // Offline or unreachable server: keep the empty list and let the
      // provider dispose, so the next read retries the fetch.
      log('Failed to fetch cultures: $e');
      link.close();
    }
  }
}
