import 'package:collection/collection.dart';

import 'package:fladder/models/items/media_streams_model.dart';

/// Maps mpv's `aid` property value back to the Jellyfin stream index of the
/// audio track mpv is actually using.
///
/// mpv numbers embedded tracks 1..N per type in file order, which matches the
/// order of non-external streams Jellyfin reports for the version being
/// played. Returns null when the value can't be attributed ('auto',
/// unparsable, out of range) — callers treat null as "nothing to verify".
///
/// Note: the set side (LibMPVPlayer.setAudioTrack, inherited from upstream)
/// maps positionally over the full stream list *including* external entries.
/// An item carrying an external audio stream ordered before embedded ones
/// would make set and verify disagree — Jellyfin doesn't normally produce
/// such items, so the asymmetry is documented here rather than fixed by
/// diverging further from upstream.
int? mapMpvAudioIdToStreamIndex(String? aid, List<AudioStreamModel> audioStreams) {
  if (aid == null) {
    return null;
  }
  if (aid == 'no') {
    return AudioStreamModel.no().index;
  }
  final id = int.tryParse(aid);
  // mpv ids are 1-based; elementAtOrNull throws on negative indexes.
  if (id == null || id < 1) {
    return null;
  }
  final embedded = audioStreams.where((audio) => !audio.isExternal).toList();
  return embedded.elementAtOrNull(id - 1)?.index;
}

/// Maps mpv's `sid` property value back to the Jellyfin stream index of the
/// subtitle track mpv is actually using.
///
/// Only embedded subtitles are mpv-numbered in file order; ids beyond that
/// range belong to externally added (sub-add) tracks which can't be
/// attributed positionally — those return null.
int? mapMpvSubIdToStreamIndex(String? sid, List<SubStreamModel> subStreams) {
  if (sid == null) {
    return null;
  }
  if (sid == 'no') {
    return SubStreamModel.no().index;
  }
  final id = int.tryParse(sid);
  // mpv ids are 1-based; elementAtOrNull throws on negative indexes.
  if (id == null || id < 1) {
    return null;
  }
  final embedded = subStreams.where((sub) => !sub.isExternal).toList();
  return embedded.elementAtOrNull(id - 1)?.index;
}
