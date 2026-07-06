# Preferred Audio Track ("Original Version") & Smart Subtitle Selection — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let users prefer "Original Version" (VO) or a specific language for audio, and make the existing Smart/Always/Forced subtitle modes work client-side against the audio track actually chosen — including mid-playback audio switches.

**Architecture:** A pure track-selection engine in a new Maktep-only file post-processes the indices produced by upstream `selectAudioStream`/`selectSubStream` on fresh playback only (manual picks/remembered selections always win). Preferences are stored server-side (`userConfiguration.audioLanguagePreference`) plus a `preferOriginalAudio` bool in Fladder's server-synced custom config (`UserSettings`). Upstream files receive only small additive hooks so monthly upstream syncs can't silently drop the feature.

**Tech Stack:** Flutter/Dart (SDK pinned in `.fvmrc`), Riverpod generated providers, Freezed, Jellyfin swagger client (generated, do not edit), `flutter_test` (no new deps).

**Spec:** `docs/superpowers/specs/2026-07-04-preferred-track-language-design.md`

## Global Constraints

- **NO GIT COMMITS.** The user commits manually after verifying. Where a normal plan would say "Commit", instead run `git status` to confirm only intended files changed, then mark the task complete.
- Line length **120**; format changed files with `dart format --line-length 120 <files>`.
- `flutter analyze` must stay clean **including infos** (CI runs `--fatal-infos`).
- Always use `package:fladder/...` imports inside `lib/`.
- Always use braces for `if`/`else`, even single-line.
- Riverpod **generated** providers only (`@riverpod` / `@Riverpod(keepAlive: true)`); never `StateProvider`/`StateNotifierProvider`.
- Never edit generated files (`*.g.dart`, `*.freezed.dart`, `lib/jellyfin/**`, `lib/l10n/generated/**`). After editing annotated files run: `flutter pub run build_runner build --delete-conflicting-outputs`. After editing `.arb` files run: `flutter gen-l10n`.
- New localization strings go to `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb` only (Weblate handles the rest).
- No new dev/test dependencies (no mocktail/mockito). Tests are pure-logic tests.
- `lib/util/streams_selection.dart` must end up **byte-identical to `upstream/develop`** (Task 2 restores it).

---

### Task 1: Add `isForced` to `SubStreamModel`

The engine needs reliable forced-subtitle detection. The Jellyfin DTO exposes `MediaStream.isForced`; `SubStreamModel` currently drops it (existing code falls back to fragile `displayTitle.contains('forced')`).

**Files:**
- Modify: `lib/models/items/media_streams_model.dart` (class `SubStreamModel`, ~lines 360–500)

**Interfaces:**
- Consumes: `dto.MediaStream.isForced` (generated swagger model, already available).
- Produces: `SubStreamModel.isForced` (`bool`, default `false`) — used by Task 3's engine and preserved through `copyWith`/`toMap`/`fromMap`.

- [ ] **Step 1: Add the field and thread it through all constructors/serializers**

In `lib/models/items/media_streams_model.dart`, class `SubStreamModel`:

```dart
class SubStreamModel extends AudioAndSubStreamModel {
  String id;
  String title;
  String? url;
  bool supportsExternalStream;
  final bool isForced;
  SubStreamModel({
    required super.name,
    required this.id,
    required this.title,
    required super.displayTitle,
    required super.language,
    this.url,
    required super.codec,
    required super.isDefault,
    required super.isExternal,
    required super.index,
    this.supportsExternalStream = false,
    this.isForced = false,
  });
```

In `SubStreamModel.no(...)` add:

```dart
    this.isForced = false,
```

In `factory SubStreamModel.fromMediaStream(...)` add to the returned constructor call:

```dart
      isForced: stream.isForced ?? false,
```

In `copyWith(...)` add parameter `bool? isForced,` and to the returned constructor:

```dart
      isForced: isForced ?? this.isForced,
```

In `toMap()` add:

```dart
      'isForced': isForced,
```

In `factory SubStreamModel.fromMap(...)` add:

```dart
      isForced: map['isForced'] ?? false,
```

- [ ] **Step 2: Verify analyzer is clean**

Run: `flutter analyze lib/models/items/media_streams_model.dart`
Expected: `No issues found!`

- [ ] **Step 3: Format and check status**

Run: `dart format --line-length 120 lib/models/items/media_streams_model.dart && git status --short`
Expected: only `lib/models/items/media_streams_model.dart` newly modified (plus the pre-existing dirty generated files on this branch).

---

### Task 2: Track-selection engine — types + preferred audio selection (TDD)

**Files:**
- Create: `lib/util/track_preferences.dart`
- Restore: `lib/util/streams_selection.dart` (back to upstream)
- Test: `test/util/track_preferences_test.dart`

**Interfaces:**
- Consumes: `AudioStreamModel`, `SubStreamModel` from `package:fladder/models/items/media_streams_model.dart`; `SubtitlePlaybackMode` from `package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart`.
- Produces (used by Tasks 3, 5, 7, 8):
  - `enum PreferredAudioMode { any, originalVersion, language }`
  - `class TrackPreferences { final PreferredAudioMode audioMode; final Set<String> audioLanguageCodes; final Set<String> subtitleLanguageCodes; final SubtitlePlaybackMode? subtitleMode; }` (const constructor, all named params, defaults: `audioMode = PreferredAudioMode.any`, empty sets, `subtitleMode = null`)
  - `int? selectPreferredAudioIndex({required List<AudioStreamModel> audioStreams, required int? fallbackIndex, required TrackPreferences prefs})`

- [ ] **Step 1: Restore `streams_selection.dart` to upstream**

Run: `git checkout upstream/develop -- lib/util/streams_selection.dart`
Then: `git diff upstream/develop -- lib/util/streams_selection.dart`
Expected: empty output (no diff). Note: callers in `playback_model.dart` never passed `preferredLanguage`, so nothing breaks.

- [ ] **Step 2: Write the failing tests**

Create `test/util/track_preferences_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/util/track_preferences.dart';

AudioStreamModel audio({
  required int index,
  String language = 'und',
  String name = '',
  String displayTitle = '',
  bool isDefault = false,
}) =>
    AudioStreamModel(
      displayTitle: displayTitle,
      name: name,
      codec: 'aac',
      isDefault: isDefault,
      isExternal: false,
      index: index,
      language: language,
      channelLayout: '5.1',
      sampleRate: null,
      channels: null,
      bitRate: null,
      bitDepth: null,
      profile: null,
      spatialFormat: null,
    );

const frCodes = {'fr', 'fra', 'fre'};

void main() {
  group('selectPreferredAudioIndex - originalVersion label match', () {
    const prefs = TrackPreferences(
      audioMode: PreferredAudioMode.originalVersion,
      subtitleLanguageCodes: frCodes,
    );

    test('matches VO token in stream name', () {
      final streams = [
        audio(index: 1, language: 'fre', name: 'VF', isDefault: true),
        audio(index: 2, language: 'eng', name: 'VO'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);
    });

    test('matches VOSTFR and version originale variants', () {
      final streams = [
        audio(index: 1, language: 'fre', name: 'VFF 5.1', isDefault: true),
        audio(index: 2, language: 'eng', name: 'English VOSTFR'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);

      final streams2 = [
        audio(index: 1, language: 'fre', name: 'Français', isDefault: true),
        audio(index: 2, language: 'spa', name: 'Version Originale'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams2, fallbackIndex: 1, prefs: prefs), 2);
    });

    test('does not false-match "voice" or "originale" fragments', () {
      final streams = [
        audio(index: 1, language: 'fre', name: 'Dolby Voice', isDefault: true),
        audio(index: 2, language: 'eng', name: 'Commentary'),
      ];
      // No VO label; anti-dub kicks in: excludes fre -> picks eng track.
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);
    });
  });

  group('selectPreferredAudioIndex - anti-dub heuristic', () {
    const prefs = TrackPreferences(
      audioMode: PreferredAudioMode.originalVersion,
      subtitleLanguageCodes: frCodes,
    );

    test('anime: jpn + VF(default) -> picks jpn', () {
      final streams = [
        audio(index: 1, language: 'fre', displayTitle: 'VF - AAC - 5.1 - Default', isDefault: true),
        audio(index: 2, language: 'jpn', displayTitle: 'Japonais - AAC - Stereo'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);
    });

    test('french-only film: nothing to exclude everything -> fallback', () {
      final streams = [audio(index: 1, language: 'fre', isDefault: true)];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 1);
    });

    test('no french track at all: nothing excluded -> fallback untouched', () {
      final streams = [
        audio(index: 1, language: 'eng', isDefault: true),
        audio(index: 2, language: 'spa'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 1);
    });

    test('unknown-language track with VF title token is excluded', () {
      final streams = [
        audio(index: 1, language: 'und', name: 'VFQ', isDefault: true),
        audio(index: 2, language: 'jpn', name: 'Japanese'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);
    });

    test('prefers isDefault among remaining tracks', () {
      final streams = [
        audio(index: 1, language: 'fre', isDefault: false),
        audio(index: 2, language: 'eng', isDefault: false),
        audio(index: 3, language: 'eng', isDefault: true),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 3);
    });
  });

  group('selectPreferredAudioIndex - language mode', () {
    const prefs = TrackPreferences(
      audioMode: PreferredAudioMode.language,
      audioLanguageCodes: {'en', 'eng'},
    );

    test('picks track matching expanded code set', () {
      final streams = [
        audio(index: 1, language: 'fre', isDefault: true),
        audio(index: 2, language: 'eng'),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 2);
    });

    test('no match -> fallback', () {
      final streams = [audio(index: 1, language: 'fre', isDefault: true)];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 1);
    });
  });

  group('selectPreferredAudioIndex - any mode / empty input', () {
    test('any mode is a no-op', () {
      const prefs = TrackPreferences();
      final streams = [audio(index: 1, language: 'fre'), audio(index: 2, language: 'eng')];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 1, prefs: prefs), 1);
    });

    test('empty stream list -> fallback', () {
      const prefs = TrackPreferences(
        audioMode: PreferredAudioMode.originalVersion,
        subtitleLanguageCodes: frCodes,
      );
      expect(selectPreferredAudioIndex(audioStreams: [], fallbackIndex: null, prefs: prefs), null);
    });
  });
}
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/util/track_preferences_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package ... track_preferences.dart` (file doesn't exist yet).

- [ ] **Step 4: Implement the engine (audio part)**

Create `lib/util/track_preferences.dart`:

```dart
import 'package:collection/collection.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
import 'package:fladder/models/items/media_streams_model.dart';

/// Maktep-only pure track-selection engine.
///
/// Post-processes the indices produced by the upstream
/// `selectAudioStream`/`selectSubStream` helpers. Callers only invoke it on
/// fresh playback (no remembered/previous stream), so manual picks always win.
/// Spec: docs/superpowers/specs/2026-07-04-preferred-track-language-design.md

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

const _voTokens = {'vo', 'v.o', 'v.o.', 'vost', 'vostfr', 'vosta', 'vostf', 'original'};
const _voPhrase = 'version originale';

/// French dub tokens, used only when a track's language metadata is unknown.
const _dubTokens = {'vf', 'vff', 'vfq', 'vfi', 'vf2'};

bool _hasKnownLanguage(String language) {
  final lower = language.toLowerCase();
  return lower.isNotEmpty && lower != 'und' && lower != 'unknown';
}

List<String> _tokens(AudioAndSubStreamModel stream) {
  final haystack = '${stream.name} ${stream.displayTitle}'.toLowerCase();
  return haystack.split(RegExp(r'[^a-z0-9.]+')).where((t) => t.isNotEmpty).toList();
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
      for (final stream in candidates) {
        if (_languageMatches(stream, prefs.audioLanguageCodes)) {
          return stream.index;
        }
      }
      return fallbackIndex;
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
      final defaultTrack = remaining.where((s) => s.isDefault).firstOrNull;
      return (defaultTrack ?? remaining.first).index;
  }
}
```

(`firstOrNull` comes from `package:collection`'s `IterableExtension`, already a project dependency.)

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/util/track_preferences_test.dart`
Expected: all tests PASS.

- [ ] **Step 6: Analyze, format, status check**

Run: `flutter analyze lib/util/track_preferences.dart test/util/track_preferences_test.dart && dart format --line-length 120 lib/util/track_preferences.dart test/util/track_preferences_test.dart && git status --short`
Expected: `No issues found!`; only the intended files changed.

---

### Task 3: Engine — preferred subtitle selection (TDD)

**Files:**
- Modify: `lib/util/track_preferences.dart`
- Test: `test/util/track_preferences_test.dart` (append)

**Interfaces:**
- Consumes: Task 2's types; `SubStreamModel.isForced` from Task 1.
- Produces (used by Tasks 7, 8):
  - `int? selectPreferredSubtitleIndex({required AudioStreamModel? selectedAudio, required List<SubStreamModel> subStreams, required int? fallbackIndex, required TrackPreferences prefs})`
  - Returns `-1` for "subtitles off", `null`/`fallbackIndex` passthrough when the engine has no opinion.

- [ ] **Step 1: Append the failing tests**

Append to `test/util/track_preferences_test.dart` (inside `main()`), plus a `sub` helper next to the `audio` helper at top level:

```dart
SubStreamModel sub({
  required int index,
  String language = 'und',
  String name = '',
  String displayTitle = '',
  bool isDefault = false,
  bool isForced = false,
}) =>
    SubStreamModel(
      name: name,
      id: '$index',
      title: name,
      displayTitle: displayTitle,
      language: language,
      codec: 'srt',
      isDefault: isDefault,
      isExternal: false,
      index: index,
      isForced: isForced,
    );
```

```dart
  group('selectPreferredSubtitleIndex - smart mode', () {
    const prefs = TrackPreferences(
      subtitleLanguageCodes: frCodes,
      subtitleMode: SubtitlePlaybackMode.smart,
    );

    test('foreign audio -> non-forced french subtitle', () {
      final subs = [
        sub(index: 10, language: 'fre', isForced: true),
        sub(index: 11, language: 'fre'),
        sub(index: 12, language: 'eng'),
      ];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 11);
    });

    test('foreign audio, only forced french exists -> forced french', () {
      final subs = [sub(index: 10, language: 'fre', isForced: true)];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'jpn'),
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 10);
    });

    test('foreign audio, no french subs -> fallback', () {
      final subs = [sub(index: 12, language: 'eng')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: 12,
        prefs: prefs,
      );
      expect(result, 12);
    });

    test('french audio -> forced french if present, else off', () {
      final subsWithForced = [
        sub(index: 10, language: 'fre', isForced: true),
        sub(index: 11, language: 'fre'),
      ];
      expect(
        selectPreferredSubtitleIndex(
          selectedAudio: audio(index: 1, language: 'fre'),
          subStreams: subsWithForced,
          fallbackIndex: 11,
          prefs: prefs,
        ),
        10,
      );

      final subsNoForced = [sub(index: 11, language: 'fre')];
      expect(
        selectPreferredSubtitleIndex(
          selectedAudio: audio(index: 1, language: 'fra'),
          subStreams: subsNoForced,
          fallbackIndex: 11,
          prefs: prefs,
        ),
        -1,
      );
    });

    test('forced detected via display title when flag missing', () {
      final subs = [
        sub(index: 10, language: 'fre', displayTitle: 'French (Forced)'),
        sub(index: 11, language: 'fre'),
      ];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 11);
    });
  });

  group('selectPreferredSubtitleIndex - other modes', () {
    test('always -> french subtitle regardless of audio', () {
      const prefs = TrackPreferences(
        subtitleLanguageCodes: frCodes,
        subtitleMode: SubtitlePlaybackMode.always,
      );
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 1, language: 'fre'),
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 11);
    });

    test('onlyforced -> forced french else off', () {
      const prefs = TrackPreferences(
        subtitleLanguageCodes: frCodes,
        subtitleMode: SubtitlePlaybackMode.onlyforced,
      );
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: 11,
        prefs: prefs,
      );
      expect(result, -1);
    });

    test('none -> off', () {
      const prefs = TrackPreferences(
        subtitleLanguageCodes: frCodes,
        subtitleMode: SubtitlePlaybackMode.none,
      );
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: 11,
        prefs: prefs,
      );
      expect(result, -1);
    });

    test('default mode -> fallback untouched', () {
      const prefs = TrackPreferences(
        subtitleLanguageCodes: frCodes,
        subtitleMode: SubtitlePlaybackMode.$default,
      );
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: 5,
        prefs: prefs,
      );
      expect(result, 5);
    });

    test('no subtitle language preference -> engine is a no-op', () {
      const prefs = TrackPreferences(subtitleMode: SubtitlePlaybackMode.smart);
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: 5,
        prefs: prefs,
      );
      expect(result, 5);
    });
  });
```

Add the enums import at the top of the test file:

```dart
import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
```

- [ ] **Step 2: Run tests to verify the new ones fail**

Run: `flutter test test/util/track_preferences_test.dart`
Expected: FAIL — `selectPreferredSubtitleIndex` not defined. Task 2 groups still pass.

- [ ] **Step 3: Implement subtitle selection**

Append to `lib/util/track_preferences.dart`:

```dart
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
  final nonForced = preferred.where((s) => !_isForcedSub(s)).firstOrNull;
  final forced = preferred.where(_isForcedSub).firstOrNull;

  final audioMatchesPreferred =
      selectedAudio != null && _languageMatches(selectedAudio, prefs.subtitleLanguageCodes);

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
```

(`SubtitlePlaybackMode` members verified in `lib/jellyfin/jellyfin_open_api.enums.swagger.dart:1996`: `swaggerGeneratedUnknown`, `$default`, `always`, `onlyforced`, `none`, `smart` — the switch above is exhaustive.)

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/util/track_preferences_test.dart`
Expected: all tests PASS.

- [ ] **Step 5: Analyze, format, status check**

Run: `flutter analyze lib/util/track_preferences.dart test/util/track_preferences_test.dart && dart format --line-length 120 lib/util/track_preferences.dart test/util/track_preferences_test.dart && git status --short`
Expected: clean analyze; only intended files changed.

---

### Task 4: Persist preferences — `UserSettings.preferOriginalAudio` + user_provider updaters

**Files:**
- Modify: `lib/models/account_model.dart` (class `UserSettings`, ~line 84)
- Modify: `lib/providers/user_provider.dart` (append two methods after `updateSubtitleMode`, ~line 113)
- Generated: rerun build_runner (`account_model.freezed.dart` / `account_model.g.dart` update)

**Interfaces:**
- Consumes: existing `updateCustomConfig(UserSettings)` (user_provider.dart:129), existing `copyWithWrapped` on the generated `UserConfiguration`, `Wrapped` from the swagger client (already imported in user_provider.dart).
- Produces (used by Tasks 5, 6):
  - `UserSettings.preferOriginalAudio` (`bool`, default `false`, server-synced via DisplayPreferences custom config)
  - `UserNotifier.updateAudioLanguagePreference(String? language)` — writes `userConfiguration.audioLanguagePreference`
  - `UserNotifier.setPreferOriginalAudio(bool value)` — writes the custom config flag

- [ ] **Step 1: Add the field to `UserSettings`**

In `lib/models/account_model.dart`:

```dart
@Freezed(copyWith: true)
abstract class UserSettings with _$UserSettings {
  factory UserSettings({
    @Default(Duration(seconds: 30)) Duration skipForwardDuration,
    @Default(Duration(seconds: 10)) Duration skipBackDuration,
    @Default(false) bool preferOriginalAudio,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
}
```

(Older stored configs lack the key; `@Default(false)` + the `parseValues()` string→bool conversion in `service_provider.dart:1759` handle both directions.)

- [ ] **Step 2: Add the updater methods to `UserNotifier`**

In `lib/providers/user_provider.dart`, directly after `updateSubtitleMode` (mirror `updateSubtitleLanguagePreference` at line 89):

```dart
  void updateAudioLanguagePreference(String? language) async {
    final currentUserConfiguration = state?.userConfiguration;
    if (currentUserConfiguration == null) return;

    final normalizedLanguage = language?.trim().toLowerCase();
    final updated = currentUserConfiguration.copyWithWrapped(
      audioLanguagePreference:
          Wrapped<String?>.value((normalizedLanguage?.isEmpty ?? true) ? null : normalizedLanguage),
    );
    final newUserConfiguration = await api.updateUserConfiguration(updated);
    if (newUserConfiguration != null) {
      userState = state?.copyWith(userConfiguration: newUserConfiguration);
    }
  }

  void setPreferOriginalAudio(bool value) {
    final userSettings = state?.userSettings?.copyWith(preferOriginalAudio: value);
    if (userSettings != null) {
      updateCustomConfig(userSettings);
    }
  }
```

- [ ] **Step 3: Regenerate**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: exits 0; `account_model.freezed.dart` / `account_model.g.dart` regenerated.

- [ ] **Step 4: Analyze, format, status check**

Run: `flutter analyze lib/models/account_model.dart lib/providers/user_provider.dart && dart format --line-length 120 lib/models/account_model.dart lib/providers/user_provider.dart && git status --short`
Expected: clean; changed files are the two sources + their generated counterparts.

---

### Task 5: Preferences providers — assembly + per-session manual-subtitle flag

**Files:**
- Create: `lib/providers/track_preferences_provider.dart`
- Generated: `lib/providers/track_preferences_provider.g.dart` via build_runner

**Interfaces:**
- Consumes: `userProvider` (`AccountModel?` with `userConfiguration`, `userSettings`), `culturesProvider` (`List<CultureDto>`), `CultureDtoExtension.matchesLanguageCode` (`lib/util/jellyfin_extension.dart`), Task 2's `TrackPreferences`/`PreferredAudioMode`.
- Produces (used by Tasks 6, 7, 8):
  - `trackPreferencesProvider` → `TrackPreferences` (keepAlive, watch-based)
  - `manualSubtitleOverrideProvider` → `bool`, with notifier methods `markManualSubtitle()` and `reset()`

- [ ] **Step 1: Create the provider file**

```dart
import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart';
import 'package:fladder/providers/cultures_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/util/jellyfin_extension.dart';
import 'package:fladder/util/track_preferences.dart';

part 'track_preferences_provider.g.dart';

/// Expands a stored language code (e.g. "fre") to every code that denotes the
/// same culture (e.g. {fr, fra, fre}) so track matching survives the
/// bibliographic/terminological ISO-639-2 split.
Set<String> expandLanguageCodes(String? code, List<CultureDto> cultures) {
  final normalized = code?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return const {};
  }
  final culture = cultures.where((c) => c.matchesLanguageCode(normalized)).firstOrNull;
  if (culture == null) {
    return {normalized};
  }
  return {
    normalized,
    if (culture.twoLetterISOLanguageName != null) culture.twoLetterISOLanguageName!.toLowerCase(),
    if (culture.threeLetterISOLanguageName != null) culture.threeLetterISOLanguageName!.toLowerCase(),
    ...?culture.threeLetterISOLanguageNames?.map((v) => v.toLowerCase()),
  };
}

@Riverpod(keepAlive: true)
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
```

(The plain `Ref ref` parameter matches this repo's convention — see e.g. `lib/providers/syncplay/syncplay_provider.dart:186`.)

- [ ] **Step 2: Regenerate**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: exits 0; `track_preferences_provider.g.dart` created.

- [ ] **Step 3: Analyze, format, status check**

Run: `flutter analyze lib/providers/track_preferences_provider.dart && dart format --line-length 120 lib/providers/track_preferences_provider.dart && git status --short`
Expected: clean.

---

### Task 6: Settings UI — "Preferred audio track" dropdown + localization

**Files:**
- Create: `lib/screens/settings/widgets/preferred_audio_track_setting.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb` (additive keys)
- Modify: `lib/screens/settings/profile_settings_page.dart` (one import + one inserted group)
- Generated: `flutter gen-l10n`

**Interfaces:**
- Consumes: `userProvider` + Task 4's `updateAudioLanguagePreference`/`setPreferOriginalAudio`, `culturesProvider`, `SettingsListTileEnum` + `ItemActionButton` (same widgets the subtitle tile uses in `profile_settings_page.dart:181-220`), existing l10n keys `preferredAudioLanguage`, `anyLanguage`, `unknown`, `audio`.
- Produces: `PreferredAudioTrackSetting` (a `ConsumerWidget` usable as a settings tile) and l10n keys `originalVersionAudio`, `originalVersionAudioDesc`.

- [ ] **Step 1: Add localization keys**

In `lib/l10n/app_en.arb`, after the existing `preferredAudioLanguageDesc` entry (~line 1637):

```json
  "originalVersionAudio": "Original version (VO)",
  "@originalVersionAudio": {},
  "originalVersionAudioDesc": "Prefer the original audio track, detected from VO labels or by skipping dubbed tracks",
  "@originalVersionAudioDesc": {},
```

In `lib/l10n/app_fr.arb`, in the corresponding section:

```json
  "originalVersionAudio": "Version originale (VO)",
  "@originalVersionAudio": {},
  "originalVersionAudioDesc": "Préférer la piste audio originale, détectée via les libellés VO ou en ignorant les pistes doublées",
  "@originalVersionAudioDesc": {},
```

Run: `flutter gen-l10n`
Expected: exits 0, no untranslated-key errors for en/fr.

- [ ] **Step 2: Create the settings widget**

Create `lib/screens/settings/widgets/preferred_audio_track_setting.dart` (mirrors the subtitle-language tile in `profile_settings_page.dart`):

```dart
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/providers/cultures_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/settings/settings_list_tile.dart';
import 'package:fladder/util/jellyfin_extension.dart';
import 'package:fladder/util/localization_helper.dart';
import 'package:fladder/widgets/shared/item_actions.dart';

/// Maktep-only: "Preferred audio track" selector (Any / Original version / language).
/// A concrete language is stored server-side (userConfiguration.audioLanguagePreference);
/// "Original version" lives in Fladder's server-synced custom config.
class PreferredAudioTrackSetting extends ConsumerWidget {
  const PreferredAudioTrackSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final cultures = ref.watch(culturesProvider);

    final preferOriginal = user?.userSettings?.preferOriginalAudio ?? false;
    final audioLanguagePreference = user?.userConfiguration?.audioLanguagePreference?.trim().toLowerCase();
    final hasLanguagePreference = !preferOriginal && (audioLanguagePreference?.isNotEmpty == true);

    final currentCulture = cultures.firstWhereOrNull(
      (e) => e.matchesLanguageCode(audioLanguagePreference),
    );

    final currentLabel = preferOriginal
        ? context.localized.originalVersionAudio
        : hasLanguagePreference
            ? currentCulture?.displayName ?? context.localized.unknown
            : context.localized.anyLanguage;

    return SettingsListTileEnum(
      label: Text(context.localized.preferredAudioLanguage),
      subLabel: Text(context.localized.originalVersionAudioDesc),
      current: currentLabel,
      itemBuilder: (context) => [
        ItemActionButton(
          selected: !preferOriginal && !hasLanguagePreference,
          label: Text(context.localized.anyLanguage),
          action: () {
            ref.read(userProvider.notifier).setPreferOriginalAudio(false);
            ref.read(userProvider.notifier).updateAudioLanguagePreference(null);
          },
        ),
        ItemActionButton(
          selected: preferOriginal,
          label: Text(context.localized.originalVersionAudio),
          action: () {
            ref.read(userProvider.notifier).updateAudioLanguagePreference(null);
            ref.read(userProvider.notifier).setPreferOriginalAudio(true);
          },
        ),
        ...cultures.map(
          (e) => ItemActionButton(
            selected: !preferOriginal && e.matchesLanguageCode(audioLanguagePreference),
            label: Text(e.displayName ?? e.name ?? context.localized.unknown),
            action: () {
              ref.read(userProvider.notifier).setPreferOriginalAudio(false);
              ref.read(userProvider.notifier).updateAudioLanguagePreference(
                  e.threeLetterISOLanguageName?.toLowerCase() ?? e.twoLetterISOLanguageName?.toLowerCase());
            },
          ),
        ),
      ],
    );
  }
}
```

(`SettingsListTileEnum` constructor verified in `lib/screens/settings/settings_list_tile.dart:54` — it accepts `label`, `subLabel`, `current`, and `itemBuilder`.)

- [ ] **Step 3: Insert into the profile settings page**

In `lib/screens/settings/profile_settings_page.dart`:

Add import (alphabetical among the `screens/settings/widgets/` imports):

```dart
import 'package:fladder/screens/settings/widgets/preferred_audio_track_setting.dart';
```

Directly **before** the subtitles group (`...settingsListGroup(context, SettingsLabelDivider(label: context.localized.subtitles), [...])`, ~line 167), insert:

```dart
        ...settingsListGroup(
          context,
          SettingsLabelDivider(label: context.localized.audio(1)),
          [
            const PreferredAudioTrackSetting(),
          ],
        ),
        const SizedBox(height: 16),
```

(`context.localized.audio(1)` is the existing pluralized "Audio" key used by the player options sheet — verify the call shape matches its use in `video_player_options_sheet.dart:465`.)

- [ ] **Step 4: Analyze, format, status check**

Run: `flutter analyze lib/screens/settings/widgets/preferred_audio_track_setting.dart lib/screens/settings/profile_settings_page.dart && dart format --line-length 120 lib/screens/settings/widgets/preferred_audio_track_setting.dart lib/screens/settings/profile_settings_page.dart && git status --short`
Expected: clean.

- [ ] **Step 5: Manual smoke check (UI)**

Run the app (`flutter run -d windows`, or `flutter run` on the default device; Android needs `--flavor=development`). Open Settings → Profile. Verify: the "Preferred audio language" tile appears above Subtitles; selecting *Original version (VO)*, a concrete language, and *Any* round-trips correctly after leaving and reopening the page (values persist via the server).

---

### Task 7: Playback integration — fresh-playback hook, offline hook, flag reset

**Files:**
- Modify: `lib/models/playback/playback_model.dart` (`_createServerPlaybackModel` ~line 439-489; `_createOfflinePlaybackModel` ~line 282-309)
- Modify: `lib/providers/video_player_provider.dart` (`loadPlaybackItem`, ~line 328)

**Interfaces:**
- Consumes: `selectPreferredAudioIndex`/`selectPreferredSubtitleIndex` (Tasks 2-3), `trackPreferencesProvider` + `manualSubtitleOverrideProvider` (Task 5).
- Produces: preference-aware initial track indices for server playback (`PlaybackInfoDto.audioStreamIndex/subtitleStreamIndex` + `mediaStreamsWithUrls`) and offline playback; manual-override flag reset when the playing item changes.

- [ ] **Step 1: Hook `_createServerPlaybackModel`**

In `lib/models/playback/playback_model.dart` add imports:

```dart
import 'package:fladder/providers/track_preferences_provider.dart';
import 'package:fladder/util/track_preferences.dart';
```

Directly after the existing `subStreamIndex` assignment (line ~449, keep those lines untouched), insert:

```dart
      // Maktep: apply preferred-track engine on fresh playback only; a
      // previous session's selection (oldModel) always wins.
      final trackPrefs = ref.read(trackPreferencesProvider);
      final preferredAudioIndex = oldModel == null
          ? selectPreferredAudioIndex(
              audioStreams: newStreamModel?.audioStreams ?? [],
              fallbackIndex: audioStreamIndex,
              prefs: trackPrefs,
            )
          : audioStreamIndex;
      final preferredAudioStream =
          newStreamModel?.audioStreams.firstWhereOrNull((s) => s.index == preferredAudioIndex);
      final preferredSubIndex = oldModel == null
          ? selectPreferredSubtitleIndex(
              selectedAudio: preferredAudioStream,
              subStreams: newStreamModel?.subStreams ?? [],
              fallbackIndex: subStreamIndex,
              prefs: trackPrefs,
            )
          : subStreamIndex;
```

Then replace the three later usages in this method (these are the only modified lines):

- `PlaybackInfoDto(... audioStreamIndex: audioStreamIndex, subtitleStreamIndex: subStreamIndex, ...)` → `audioStreamIndex: preferredAudioIndex, subtitleStreamIndex: preferredSubIndex,`
- `mediaStreamsWithUrls = ... .copyWith(defaultAudioStreamIndex: audioStreamIndex, defaultSubStreamIndex: subStreamIndex)` → `.copyWith(defaultAudioStreamIndex: preferredAudioIndex, defaultSubStreamIndex: preferredSubIndex)`

Do **not** touch `shouldReload` — there a current stream always exists, so preferences must not apply (manual pick wins).

- [ ] **Step 2: Hook `_createOfflinePlaybackModel`**

In the same file, in `_createOfflinePlaybackModel`, replace the final `mediaStreams:` argument construction. Before the `return OfflinePlaybackModel(...)` insert:

```dart
    // Maktep: preferred-track engine for offline playback (fresh playback only).
    MediaStreamsModel? offlineStreams = item.streamModel ?? syncedItemModel.streamModel;
    if (oldModel == null && offlineStreams != null) {
      final trackPrefs = ref.read(trackPreferencesProvider);
      final audioIndex = selectPreferredAudioIndex(
        audioStreams: offlineStreams.audioStreams,
        fallbackIndex: offlineStreams.defaultAudioStreamIndex,
        prefs: trackPrefs,
      );
      final audioStream = offlineStreams.audioStreams.firstWhereOrNull((s) => s.index == audioIndex);
      final subIndex = selectPreferredSubtitleIndex(
        selectedAudio: audioStream,
        subStreams: offlineStreams.subStreams,
        fallbackIndex: offlineStreams.defaultSubStreamIndex,
        prefs: trackPrefs,
      );
      offlineStreams = offlineStreams.copyWith(
        defaultAudioStreamIndex: audioIndex,
        defaultSubStreamIndex: subIndex,
      );
    }
```

and change `mediaStreams: item.streamModel ?? syncedItemModel.streamModel,` → `mediaStreams: offlineStreams,`.

- [ ] **Step 3: Reset the manual-override flag on item change**

In `lib/providers/video_player_provider.dart`, inside `loadPlaybackItem` directly after `final oldPlaybackModel = ref.read(playBackModel);` (line ~333), insert:

```dart
    // Maktep: a new item starts a fresh manual-subtitle-override session.
    if (oldPlaybackModel?.item.id != model.item.id) {
      ref.read(manualSubtitleOverrideProvider.notifier).reset();
    }
```

Add import:

```dart
import 'package:fladder/providers/track_preferences_provider.dart';
```

- [ ] **Step 4: Analyze, format, status check**

Run: `flutter analyze lib/models/playback/playback_model.dart lib/providers/video_player_provider.dart && dart format --line-length 120 lib/models/playback/playback_model.dart lib/providers/video_player_provider.dart && git status --short`
Expected: clean.

- [ ] **Step 5: Run the full test suite**

Run: `flutter test test/util/track_preferences_test.dart test/providers test/models`
Expected: PASS (ignore `test/widget_test.dart` — it is the broken starter template).

- [ ] **Step 6: Manual smoke check (initial selection)**

With *Original version (VO)* + subtitle language *French* + subtitle mode *Smart* set: play an English-audio movie → expect English audio, French subtitles on. Play a French-audio item → expect French audio, subtitles off (or forced-only). Play a jpn+VF anime → expect Japanese audio, French subtitles.

---

### Task 8: Mid-playback Smart re-evaluation on audio switch

**Files:**
- Create: `lib/util/smart_subtitle_reevaluation.dart`
- Modify: `lib/screens/video_player/components/video_player_options_sheet.dart` (two dialogs: `showSubSelection` ~line 425, `showAudioSelection` ~line 477)

**Interfaces:**
- Consumes: Task 3's `selectPreferredSubtitleIndex`, Task 5's providers, `PlaybackModel.setSubtitle` (`playback_model.dart:128`), `SubtitlePlaybackMode`.
- Produces: `Future<PlaybackModel?> applySmartSubtitleReevaluation(WidgetRef ref, PlaybackModel? model, AudioStreamModel selectedAudio, MediaControlsWrapper player)` — returns the (possibly) updated model; a no-op unless subtitle mode is Smart and no manual subtitle override is active.

- [ ] **Step 1: Create the helper**

Create `lib/util/smart_subtitle_reevaluation.dart` (separate file to avoid an import cycle between `playback_model.dart` and the provider file):

```dart
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/providers/track_preferences_provider.dart';
import 'package:fladder/util/track_preferences.dart';
import 'package:fladder/wrappers/media_control_wrapper.dart';

/// Maktep: after a manual audio switch, re-evaluate the Smart subtitle rule
/// against the newly selected audio track. Manual subtitle picks (session
/// flag) always win. Returns the updated model, or the input model unchanged.
Future<PlaybackModel?> applySmartSubtitleReevaluation(
  WidgetRef ref,
  PlaybackModel? model,
  AudioStreamModel selectedAudio,
  MediaControlsWrapper player,
) async {
  if (model == null) {
    return model;
  }
  if (ref.read(manualSubtitleOverrideProvider)) {
    return model;
  }
  final prefs = ref.read(trackPreferencesProvider);
  if (prefs.subtitleMode != SubtitlePlaybackMode.smart || prefs.subtitleLanguageCodes.isEmpty) {
    return model;
  }

  final currentSubIndex = model.mediaStreams?.defaultSubStreamIndex;
  final newSubIndex = selectPreferredSubtitleIndex(
    selectedAudio: selectedAudio,
    subStreams: model.mediaStreams?.subStreams ?? [],
    fallbackIndex: currentSubIndex,
    prefs: prefs,
  );
  if (newSubIndex == null || newSubIndex == currentSubIndex) {
    return model;
  }

  final subModel = newSubIndex == -1
      ? SubStreamModel.no()
      : model.mediaStreams?.subStreams.firstWhereOrNull((s) => s.index == newSubIndex);
  if (subModel == null) {
    return model;
  }
  return await model.setSubtitle(subModel, player) ?? model;
}
```

- [ ] **Step 2: Hook the audio dialog**

In `lib/screens/video_player/components/video_player_options_sheet.dart` add import:

```dart
import 'package:fladder/util/smart_subtitle_reevaluation.dart';
```

In `showAudioSelection`'s `doSwitch()` (line ~478), insert the re-evaluation between `setAudio` and the state update:

```dart
                      Future<void> doSwitch() async {
                        final newModel = await playbackModel.setAudio(audioStream, player);
                        // Maktep: smart subtitles follow the audio switch.
                        final modelWithSubs =
                            await applySmartSubtitleReevaluation(ref, newModel, audioStream, player);
                        ref.read(playBackModel.notifier).update((state) => modelWithSubs);
                        if (modelWithSubs != null) {
                          await ref.read(playbackModelHelper).shouldReload(
                                modelWithSubs,
                                isLocalTrackSwitch: true,
                              );
                        }
                      }
```

- [ ] **Step 3: Mark manual subtitle picks**

In `showSubSelection`'s `doSwitch()` (line ~426), insert as the first line:

```dart
                      ref.read(manualSubtitleOverrideProvider.notifier).markManualSubtitle();
```

(Requires the provider import in this file: `import 'package:fladder/providers/track_preferences_provider.dart';`)

- [ ] **Step 4: Analyze, format, status check**

Run: `flutter analyze lib/util/smart_subtitle_reevaluation.dart lib/screens/video_player/components/video_player_options_sheet.dart && dart format --line-length 120 lib/util/smart_subtitle_reevaluation.dart lib/screens/video_player/components/video_player_options_sheet.dart && git status --short`
Expected: clean.

- [ ] **Step 5: Manual smoke check (audio switch)**

With Smart + French configured, during playback of a French-audio item with English/French tracks:
1. Switch audio FR→EN → French subtitles turn on automatically.
2. Switch back EN→FR → subtitles turn off (or forced-only).
3. Manually pick a subtitle track, then switch audio again → subtitles stay as manually picked.
4. Load the next episode → manual-override flag resets (fresh smart behavior), while a manually picked audio/sub track still carries over via remember-selections.

---

### Task 9: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Full analyzer sweep**

Run: `flutter analyze`
Expected: `No issues found!` (CI treats infos as fatal).

- [ ] **Step 2: Formatting sweep**

Run: `dart format --line-length 120 --set-exit-if-changed lib/util/track_preferences.dart lib/util/smart_subtitle_reevaluation.dart lib/providers/track_preferences_provider.dart lib/screens/settings/widgets/preferred_audio_track_setting.dart lib/models/items/media_streams_model.dart lib/models/account_model.dart lib/providers/user_provider.dart lib/models/playback/playback_model.dart lib/providers/video_player_provider.dart lib/screens/video_player/components/video_player_options_sheet.dart lib/screens/settings/profile_settings_page.dart`
Expected: exit 0 (nothing reformatted).

- [ ] **Step 3: Tests**

Run: `flutter test test/util/track_preferences_test.dart test/providers test/models test/tools`
Expected: all PASS.

- [ ] **Step 4: Upstream-diff check**

Run: `git diff upstream/develop --stat -- lib/util/streams_selection.dart`
Expected: empty (file restored to upstream).

- [ ] **Step 5: Full manual smoke pass**

Walk the scenarios from Task 7 Step 6 and Task 8 Step 5 in one session, plus: an offline (downloaded) item honors the preferences on fresh playback; SyncPlay session — switching audio mid-playback still syncs correctly (re-evaluation rides `runLocalOnly` + `shouldReload(isLocalTrackSwitch: true)`).

- [ ] **Step 6: Report**

Summarize results to the user and **wait for their explicit instruction before any `git commit`**.
