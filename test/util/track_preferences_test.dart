import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
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

    test('matches VO token with trailing dot', () {
      final streams = [
        audio(index: 1, language: 'fre', name: 'VF', isDefault: true),
        audio(index: 2, language: 'eng', name: 'English VO.'),
      ];
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

    test('"Unknown" language default (fromMediaStream) with VF token is excluded', () {
      final streams = [
        audio(index: 1, language: 'Unknown', name: 'VFF', isDefault: true),
        audio(index: 2, language: 'jpn', name: 'Japonais'),
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

    test('prefers default-flagged track over earlier commentary in same language', () {
      final streams = [
        audio(index: 1, language: 'eng', name: 'Commentary'),
        audio(index: 2, language: 'eng', name: 'Main', isDefault: true),
      ];
      expect(selectPreferredAudioIndex(audioStreams: streams, fallbackIndex: 3, prefs: prefs), 2);
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

    test('no selected audio (server gave no default) -> treated as foreign, subs on', () {
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: null,
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 11);
    });

    test('off entry (index -1) in the sub list is ignored as a candidate', () {
      final subs = [
        SubStreamModel.no(),
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

    test('prefers default-flagged subtitle over earlier SDH in same language', () {
      final subs = [
        sub(index: 10, language: 'fre', name: 'French SDH'),
        sub(index: 11, language: 'fre', name: 'French', isDefault: true),
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

  group('expandLanguageCodeAliases', () {
    test('expands ISO-639-2 B/T split languages', () {
      expect(expandLanguageCodeAliases('fre'), {'fr', 'fra', 'fre'});
      expect(expandLanguageCodeAliases('fra'), {'fr', 'fra', 'fre'});
      expect(expandLanguageCodeAliases('GER'), {'de', 'deu', 'ger'});
    });

    test('non-split codes pass through unchanged', () {
      expect(expandLanguageCodeAliases('eng'), {'eng'});
      expect(expandLanguageCodeAliases('jpn'), {'jpn'});
    });

    test('null/empty input -> empty set', () {
      expect(expandLanguageCodeAliases(null), isEmpty);
      expect(expandLanguageCodeAliases('  '), isEmpty);
    });

    test('smart matching works with unexpanded stored code vs B-coded track', () {
      // Cold start / offline: stored pref "fra", MKV track "fre".
      final prefs = TrackPreferences(
        subtitleLanguageCodes: expandLanguageCodeAliases('fra'),
        subtitleMode: SubtitlePlaybackMode.smart,
      );
      final subs = [sub(index: 11, language: 'fre')];
      final result = selectPreferredSubtitleIndex(
        selectedAudio: audio(index: 2, language: 'eng'),
        subStreams: subs,
        fallbackIndex: -1,
        prefs: prefs,
      );
      expect(result, 11);
    });
  });

  group('shouldApplyTrackPreferences', () {
    test('applies on fresh playback', () {
      expect(shouldApplyTrackPreferences(isFreshPlayback: true), isTrue);
    });

    test('previous session selection wins over preferences', () {
      expect(shouldApplyTrackPreferences(isFreshPlayback: false), isFalse);
    });

    test('never applies for Live TV, even on fresh playback', () {
      expect(shouldApplyTrackPreferences(isFreshPlayback: true, isLiveTv: true), isFalse);
      expect(shouldApplyTrackPreferences(isFreshPlayback: false, isLiveTv: true), isFalse);
    });
  });
}
