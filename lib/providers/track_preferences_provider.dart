import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/providers/cultures_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/util/jellyfin_extension.dart';
import 'package:fladder/util/track_preferences.dart';

part 'track_preferences_provider.g.dart';

/// Expands a stored language code (e.g. "fre") to every code that denotes the
/// same culture (e.g. {fr, fra, fre}) so track matching survives the
/// bibliographic/terminological ISO-639-2 split. Starts from the static
/// [expandLanguageCodeAliases] table so expansion works before the culture
/// list has loaded (cold start) or when it never loads (offline), then unions
/// whatever the server's culture list adds.
Set<String> expandLanguageCodes(String? code, List<CultureDto> cultures) {
  final normalized = code?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return const {};
  }
  final expanded = {...expandLanguageCodeAliases(normalized)};
  final culture = cultures.where((c) => c.matchesLanguageCode(normalized)).firstOrNull;
  if (culture != null) {
    expanded.addAll({
      if (culture.twoLetterISOLanguageName != null) culture.twoLetterISOLanguageName!.toLowerCase(),
      if (culture.threeLetterISOLanguageName != null) culture.threeLetterISOLanguageName!.toLowerCase(),
      ...?culture.threeLetterISOLanguageNames?.map((v) => v.toLowerCase()),
    });
  }
  return expanded;
}

// Deliberately autoDispose: consumers only ever `ref.read` this at action
// time, and keeping it alive would permanently pin the autoDispose
// culturesProvider (blocking its dispose-and-refetch self-healing after a
// failed fetch, e.g. app started offline).
@riverpod
TrackPreferences trackPreferences(Ref ref) {
  final user = ref.watch(userProvider);
  final cultures = ref.watch(culturesProvider);

  final preferOriginal = user?.userSettings?.preferOriginalAudio ?? false;
  final audioLanguage = user?.userConfiguration?.audioLanguagePreference;
  final subtitleLanguage = user?.userConfiguration?.subtitleLanguagePreference;

  final audioMode = preferOriginal
      ? PreferredAudioMode.originalVersion
      : (audioLanguage?.trim().isNotEmpty ?? false)
          ? PreferredAudioMode.language
          : PreferredAudioMode.any;

  return TrackPreferences(
    audioMode: audioMode,
    audioLanguageCodes: expandLanguageCodes(audioLanguage, cultures),
    subtitleLanguageCodes: expandLanguageCodes(subtitleLanguage, cultures),
    subtitleMode: user?.userConfiguration?.subtitleMode,
  );
}

/// True once the user manually picked a subtitle track for the currently
/// playing item; smart re-evaluation must not override a manual choice.
/// Reset when a different item starts playing.
@Riverpod(keepAlive: true)
class ManualSubtitleOverride extends _$ManualSubtitleOverride {
  @override
  bool build() => false;

  void markManualSubtitle() => state = true;

  void reset() => state = false;
}
