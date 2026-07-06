import 'package:collection/collection.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
import 'package:fladder/models/items/media_streams_model.dart';

/// Maktep-only pure track-selection engine.
///
/// Post-processes the indices produced by the upstream
/// `selectAudioStream`/`selectSubStream` helpers. Callers only invoke it on
/// fresh playback (no remembered/previous stream), so manual picks always win.
/// Spec: docs/superpowers/specs/2026-07-04-preferred-track-language-design.md

/// Fresh-playback gate for the preferred-track engine: preferences apply only
/// when starting a new playback session — a previous session's (possibly
/// manual) selection always wins — and never for Live TV.
bool shouldApplyTrackPreferences({required bool isFreshPlayback, bool isLiveTv = false}) {
  return isFreshPlayback && !isLiveTv;
}

enum PreferredAudioMode { any, originalVersion, language }

class TrackPreferences {
  final PreferredAudioMode audioMode;

  /// Expanded language codes for [PreferredAudioMode.language], e.g. {en, eng}.
  final Set<String> audioLanguageCodes;

  /// Expanded codes of the user's subtitle language preference, e.g.
  /// {fr, fra, fre}. Empty when the user has no subtitle language preference.
  final Set<String> subtitleLanguageCodes;

  final SubtitlePlaybackMode? subtitleMode;

  const TrackPreferences({
    this.audioMode = PreferredAudioMode.any,
    this.audioLanguageCodes = const {},
    this.subtitleLanguageCodes = const {},
    this.subtitleMode,
  });
}

/// ISO-639 alias groups for languages whose ISO-639-2 bibliographic (B) and
/// terminological (T) codes differ. Media containers may carry either code
/// (e.g. MKV "fre" vs "fra" for French) while the stored preference uses
/// whichever the server's culture list returned. Expanding statically keeps
/// matching correct even before the culture list has loaded (cold start) or
/// when it can never load (offline playback).
const List<Set<String>> isoLanguageAliasGroups = [
  {'sq', 'sqi', 'alb'}, // Albanian
  {'hy', 'hye', 'arm'}, // Armenian
  {'eu', 'eus', 'baq'}, // Basque
  {'my', 'mya', 'bur'}, // Burmese
  {'zh', 'zho', 'chi'}, // Chinese
  {'cs', 'ces', 'cze'}, // Czech
  {'nl', 'nld', 'dut'}, // Dutch
  {'fr', 'fra', 'fre'}, // French
  {'ka', 'kat', 'geo'}, // Georgian
  {'de', 'deu', 'ger'}, // German
  {'el', 'ell', 'gre'}, // Greek
  {'is', 'isl', 'ice'}, // Icelandic
  {'mk', 'mkd', 'mac'}, // Macedonian
  {'mi', 'mri', 'mao'}, // Maori
  {'ms', 'msa', 'may'}, // Malay
  {'fa', 'fas', 'per'}, // Persian
  {'ro', 'ron', 'rum'}, // Romanian
  {'sk', 'slk', 'slo'}, // Slovak
  {'bo', 'bod', 'tib'}, // Tibetan
  {'cy', 'cym', 'wel'}, // Welsh
];

/// Statically expands [code] with its known ISO-639 aliases. Pure fallback
/// used when the server culture list is unavailable; callers may union the
/// result with culture-derived codes.
Set<String> expandLanguageCodeAliases(String? code) {
  final normalized = code?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return const {};
  }
  final group = isoLanguageAliasGroups.firstWhereOrNull((g) => g.contains(normalized));
  return {normalized, ...?group};
}

const _voTokens = {'vo', 'v.o', 'vost', 'vostfr', 'vosta', 'vostf', 'original'};
const _voPhrase = 'version originale';

/// French dub tokens, used only when a track's language metadata is unknown.
const _dubTokens = {'vf', 'vff', 'vfq', 'vfi', 'vf2'};

bool _hasKnownLanguage(String language) {
  final lower = language.toLowerCase();
  return lower.isNotEmpty && lower != 'und' && lower != 'unknown';
}

List<String> _tokens(AudioAndSubStreamModel stream) {
  final haystack = '${stream.name} ${stream.displayTitle}'.toLowerCase();
  return haystack
      .split(RegExp(r'[^a-z0-9.]+'))
      .map((t) => t.replaceAll(RegExp(r'\.+$'), ''))
      .where((t) => t.isNotEmpty)
      .toList();
}

bool _matchesOriginalLabel(AudioAndSubStreamModel stream) {
  final haystack = '${stream.name} ${stream.displayTitle}'.toLowerCase();
  if (haystack.contains(_voPhrase)) {
    return true;
  }
  return _tokens(stream).any(_voTokens.contains);
}

bool _matchesDubLabel(AudioAndSubStreamModel stream) {
  return _tokens(stream).any(_dubTokens.contains);
}

bool _languageMatches(AudioAndSubStreamModel stream, Set<String> codes) {
  return codes.contains(stream.language.toLowerCase());
}

/// Among equally acceptable tracks, prefer the container's default-flagged
/// one (avoids picking commentary/SDH tracks that happen to come first).
T? _preferDefault<T extends AudioAndSubStreamModel>(Iterable<T> streams) {
  final list = streams.toList();
  return list.where((s) => s.isDefault).firstOrNull ?? list.firstOrNull;
}

int? selectPreferredAudioIndex({
  required List<AudioStreamModel> audioStreams,
  required int? fallbackIndex,
  required TrackPreferences prefs,
}) {
  final candidates = audioStreams.where((s) => s.index >= 0).toList();
  if (candidates.isEmpty) {
    return fallbackIndex;
  }

  switch (prefs.audioMode) {
    case PreferredAudioMode.any:
      return fallbackIndex;
    case PreferredAudioMode.language:
      final matches = candidates.where((s) => _languageMatches(s, prefs.audioLanguageCodes));
      return _preferDefault(matches)?.index ?? fallbackIndex;
    case PreferredAudioMode.originalVersion:
      for (final stream in candidates) {
        if (_matchesOriginalLabel(stream)) {
          return stream.index;
        }
      }
      // Anti-dub heuristic: drop tracks in the user's own language (dubs) and
      // pick the default/first of what remains. Only meaningful when it
      // actually excluded something.
      final remaining = candidates.where((s) {
        if (_hasKnownLanguage(s.language)) {
          return !_languageMatches(s, prefs.subtitleLanguageCodes);
        }
        return !_matchesDubLabel(s);
      }).toList();
      if (remaining.isEmpty || remaining.length == candidates.length) {
        return fallbackIndex;
      }
      return _preferDefault(remaining)!.index;
  }
}

bool _isForcedSub(SubStreamModel stream) {
  return stream.isForced || stream.displayTitle.toLowerCase().contains('forced');
}

int? selectPreferredSubtitleIndex({
  required AudioStreamModel? selectedAudio,
  required List<SubStreamModel> subStreams,
  required int? fallbackIndex,
  required TrackPreferences prefs,
}) {
  if (prefs.subtitleLanguageCodes.isEmpty) {
    return fallbackIndex;
  }

  final candidates = subStreams.where((s) => s.index >= 0).toList();
  final preferred = candidates.where((s) => _languageMatches(s, prefs.subtitleLanguageCodes)).toList();
  final nonForced = _preferDefault(preferred.where((s) => !_isForcedSub(s)));
  final forced = _preferDefault(preferred.where(_isForcedSub));

  final audioMatchesPreferred = selectedAudio != null && _languageMatches(selectedAudio, prefs.subtitleLanguageCodes);

  switch (prefs.subtitleMode) {
    case SubtitlePlaybackMode.smart:
      if (audioMatchesPreferred) {
        return forced?.index ?? -1;
      }
      return nonForced?.index ?? forced?.index ?? fallbackIndex;
    case SubtitlePlaybackMode.always:
      return nonForced?.index ?? forced?.index ?? fallbackIndex;
    case SubtitlePlaybackMode.onlyforced:
      return forced?.index ?? -1;
    case SubtitlePlaybackMode.none:
      return -1;
    case SubtitlePlaybackMode.$default:
    case SubtitlePlaybackMode.swaggerGeneratedUnknown:
    case null:
      return fallbackIndex;
  }
}
