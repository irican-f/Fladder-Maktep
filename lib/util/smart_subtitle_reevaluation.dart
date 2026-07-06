import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fladder/jellyfin/jellyfin_open_api.enums.swagger.dart';
import 'package:fladder/models/items/media_streams_model.dart';
import 'package:fladder/models/playback/playback_model.dart';
import 'package:fladder/providers/track_preferences_provider.dart';
import 'package:fladder/util/track_preferences.dart';
import 'package:fladder/wrappers/media_control_wrapper.dart';

/// Maktep: after a manual audio switch, re-evaluate the Smart subtitle rule
/// against the audio track now playing. Manual subtitle picks (session
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

  // The player may have kept the previous audio track when the requested one
  // couldn't be applied (see LibMPVPlayer.setAudioTrack) — [model] carries the
  // effective index, so re-evaluate against the track that is actually
  // playing, not the one that was requested.
  final effectiveAudio = model.mediaStreams?.currentAudioStream ?? selectedAudio;

  final currentSubIndex = model.mediaStreams?.defaultSubStreamIndex;
  final newSubIndex = selectPreferredSubtitleIndex(
    selectedAudio: effectiveAudio,
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
