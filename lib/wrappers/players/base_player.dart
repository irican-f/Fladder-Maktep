import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/models/settings/subtitle_settings_model.dart';
import 'package:fladder/models/settings/video_player_settings.dart';
import 'package:fladder/wrappers/players/player_states.dart';

const libassFallbackFont = "assets/mp-font.ttf";

abstract class BasePlayer {
  Stream<PlayerState> get stateStream;
  PlayerState lastState = PlayerState();

  Future<void> init(VideoPlayerSettingsModel settings);
  Widget? videoWidget(Key key, BoxFit fit);
  Widget? subtitles(bool showOverlay, {GlobalKey? controlsKey});
  Future<void> dispose();
  Future<void> open(BuildContext context);
  Future<void> loadVideo(String url, bool play, {Duration startPosition = Duration.zero, bool isLiveStream = false});
  Future<void> seek(Duration position);
  Future<void> play();
  Future<void> setVolume(double volume);
  Future<void> setSpeed(double speed);
  Future<void> pause();
  Future<void> stop();
  Future<void> playOrPause();
  Future<void> loop(bool loop);
  Future<void> skipToNext() async {}
  Future<void> skipToPrevious() async {}
  Future<void> addToPlaylist(String url) async {}
  Future<void> removeFromPlaylist(int index) async {}
  Future<void> playerNext() async {}
  Future<void> playerPrevious() async {}
  Stream<int> get playlistIndexStream => const Stream<int>.empty();
  Future<Uint8List?> takeScreenshot();
  Future<int> setSubtitleTrack(SubStreamModel? model, PlaybackModel playbackModel);
  Future<int> setAudioTrack(AudioStreamModel? model, PlaybackModel playbackModel);

  /// Whether this backend can report the tracks it is actually using
  /// ([appliedAudioStreamIndex]/[appliedSubStreamIndex]) — lets callers skip
  /// post-load verification entirely on backends that never can.
  bool get supportsTrackVerification => false;

  /// Jellyfin stream index of the audio track the player is *actually*
  /// using, or null when the backend can't tell (then nothing is verified).
  Future<int?> appliedAudioStreamIndex(PlaybackModel playbackModel) async => null;

  /// Jellyfin stream index of the subtitle track the player is *actually*
  /// using, or null when the backend can't tell (then nothing is verified).
  Future<int?> appliedSubStreamIndex(PlaybackModel playbackModel) async => null;

  Future<void> resetTracksToAuto() async {}
  void applySubtitleSettings(SubtitleSettingsModel settings) {}

  Uri? isValidUrl(String input) {
    try {
      final uri = Uri.tryParse(input);
      if (uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return uri;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
