import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/util/mpv_track_mapping.dart';

AudioStreamModel audioStream(int index, {bool isExternal = false}) => AudioStreamModel(
      displayTitle: 'Audio $index',
      name: 'Audio $index',
      codec: 'aac',
      isDefault: false,
      isExternal: isExternal,
      index: index,
      language: 'und',
      channelLayout: 'stereo',
      sampleRate: null,
      channels: null,
      bitRate: null,
      bitDepth: null,
      profile: null,
      spatialFormat: null,
    );

SubStreamModel subStream(int index, {bool isExternal = false}) => SubStreamModel(
      name: 'Sub $index',
      id: 'sub-$index',
      title: 'Sub $index',
      displayTitle: 'Sub $index',
      language: 'und',
      codec: 'subrip',
      isDefault: false,
      isExternal: isExternal,
      index: index,
    );

void main() {
  group('mapMpvAudioIdToStreamIndex', () {
    // Typical file: video at Jellyfin index 0, audio tracks at 1 and 2.
    final streams = [audioStream(1), audioStream(2)];

    test('null property value cannot be attributed', () {
      expect(mapMpvAudioIdToStreamIndex(null, streams), isNull);
    });

    test("'no' maps to the disabled-track index", () {
      expect(mapMpvAudioIdToStreamIndex('no', streams), AudioStreamModel.no().index);
      expect(mapMpvAudioIdToStreamIndex('no', []), AudioStreamModel.no().index);
    });

    test("'auto' (selection not resolved yet) cannot be attributed", () {
      expect(mapMpvAudioIdToStreamIndex('auto', streams), isNull);
    });

    test('unparsable value cannot be attributed', () {
      expect(mapMpvAudioIdToStreamIndex('1abc', streams), isNull);
    });

    test('mpv ids are 1-based positions into the Jellyfin audio stream list', () {
      expect(mapMpvAudioIdToStreamIndex('1', streams), 1);
      expect(mapMpvAudioIdToStreamIndex('2', streams), 2);
    });

    test('out-of-range id cannot be attributed', () {
      expect(mapMpvAudioIdToStreamIndex('3', streams), isNull);
      expect(mapMpvAudioIdToStreamIndex('0', streams), isNull);
    });

    test('external audio streams are excluded from positional mapping', () {
      final withExternal = [audioStream(1), audioStream(2, isExternal: true), audioStream(3)];
      expect(mapMpvAudioIdToStreamIndex('1', withExternal), 1);
      expect(mapMpvAudioIdToStreamIndex('2', withExternal), 3);
      expect(mapMpvAudioIdToStreamIndex('3', withExternal), isNull);
    });
  });

  group('mapMpvSubIdToStreamIndex', () {
    test("'no' maps to the disabled-track index", () {
      expect(mapMpvSubIdToStreamIndex('no', [subStream(3)]), SubStreamModel.no().index);
    });

    test("'auto' and null cannot be attributed", () {
      expect(mapMpvSubIdToStreamIndex('auto', [subStream(3)]), isNull);
      expect(mapMpvSubIdToStreamIndex(null, [subStream(3)]), isNull);
    });

    test('mpv ids are 1-based positions among embedded subtitles only', () {
      // Jellyfin lists an external sub between embedded ones; mpv only
      // numbers the embedded tracks from the file itself.
      final streams = [
        subStream(3, isExternal: true),
        subStream(4),
        subStream(5),
      ];
      expect(mapMpvSubIdToStreamIndex('1', streams), 4);
      expect(mapMpvSubIdToStreamIndex('2', streams), 5);
    });

    test('ids beyond the embedded range (externally added tracks) cannot be attributed', () {
      final streams = [subStream(3), subStream(4, isExternal: true)];
      expect(mapMpvSubIdToStreamIndex('2', streams), isNull);
    });
  });
}
