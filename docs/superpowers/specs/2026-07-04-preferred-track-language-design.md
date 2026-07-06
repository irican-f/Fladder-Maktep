# Preferred Audio Track ("Original Version") & Smart Subtitle Selection — Design

**Date:** 2026-07-04
**Branch:** maktep
**Status:** Approved design, pending implementation plan

## Context

Users report that the subtitle mode preference ("Sous-titres : Intelligent / Forcés / Toujours actifs")
does not behave as expected: with *Intelligent* (Smart) selected, playing or switching to an audio
track that is not in their language does **not** enable subtitles in their language.

Root cause: the Smart logic runs **on the Jellyfin server**, and only against the server's *default*
audio pick. Fladder selects audio client-side (remembered selections, etc.) and sends explicit track
indices to `PlaybackInfo`, so the subtitle decision is never re-evaluated against the audio track
actually playing. Additionally, Fladder never exposes the server's `audioLanguagePreference`, and
"Original Version" (VO) does not exist as a server concept.

History note: this fork (Cine Maktep) shipped a first version of this feature in commit `338eea43`
(client-side `preferredAudioLanguage`/`preferredSubtitleLanguage` + VO matching). Because it lived as
scattered edits inside upstream-owned files, a later upstream sync silently dropped the settings
fields, UI, and wiring — only dead helper params in `lib/util/streams_selection.dart` and l10n keys
survived. This design explicitly optimizes for **merge-conflict isolation**: new Maktep-only files
carry the logic; upstream files receive only small additive hooks.

## Goals

- With *Preferred audio = Original Version* and *Preferred subtitle language = French*:
  - English movie → English audio + French subtitles.
  - Japanese anime (jpn + VF tracks) → Japanese audio + French subtitles.
  - French film (French audio only) → French audio, no subtitles (Smart).
- Smart subtitle logic re-runs when the user manually switches audio mid-playback.
- Manual track picks always win over preferences (remembered selections keep working).
- Monthly upstream syncs must not silently break the feature again.

## Decisions (user-approved)

1. **Storage:** server profile + client VO (hybrid).
2. **Precedence:** manual pick / remembered selection wins; preferences apply only on fresh playback.
3. **VO fallback:** anti-dub heuristic when no track label matches VO variants.
4. **Smart scope:** re-evaluate subtitles on mid-playback audio switches too (unless the user
   manually picked a subtitle this session).
5. **Approach:** pure track-selection engine in a new file (approach B).
6. **`streams_selection.dart`:** restore to pristine upstream state; the fork's dead
   `preferredLanguage` additions are deleted (superseded by the new engine).

## Section 1 — Storage & Settings UI

| Preference | Storage | Notes |
|---|---|---|
| Preferred audio language (concrete language) | Server: `userConfiguration.audioLanguagePreference` | Field already exists in the Jellyfin API; Fladder never exposed it. Syncs across devices and improves other Jellyfin clients. |
| "Original Version" audio mode | Server-synced Fladder custom config (`UserSettings` via DisplayPreferences, same mechanism as skip durations): new bool `preferOriginalAudio` | Per-account and cross-device without abusing the server language field. |
| Subtitle language + subtitle mode | Already exists (profile settings page, `userConfiguration.subtitleLanguagePreference` / `subtitleMode`) | Reused as-is; nothing new added. |

**UI:** one new dropdown **"Preferred audio track"** with entries:
*Any (server default)* / *Original Version (VO)* / *[language list from `culturesProvider`]*.

- Built as a new Maktep-only widget file: `lib/screens/settings/widgets/preferred_audio_track_setting.dart`.
- Inserted into `lib/screens/settings/profile_settings_page.dart` with a **single added line**
  next to the existing subtitle tiles.
- Selecting *Original Version* → `preferOriginalAudio = true`, `audioLanguagePreference = null`.
- Selecting a language → `preferOriginalAudio = false`, `audioLanguagePreference = <code>`.
- Selecting *Any* → both cleared.

**Upstream-file touches (all additive):**
- `lib/providers/user_provider.dart`: new `updateAudioLanguagePreference(String?)`, mirroring
  `updateSubtitleLanguagePreference`.
- `UserSettings` model: new `preferOriginalAudio` field (custom config, follows the
  `skipForwardDuration` pattern).
- `lib/l10n/app_en.arb` + `app_fr.arb`: additive keys. Existing fork keys
  (`preferredAudioLanguage`, `playbackTrackSelection`, …) are reused where they fit; new keys for
  the "Original Version" option label/description.

## Section 2 — Track selection engine

New pure-Dart file: `lib/util/track_preferences.dart`. No provider imports; fully unit-testable.

`lib/util/streams_selection.dart` is restored to the upstream version (dead `preferredLanguage`
params and `_findStreamByPreferredLanguage` removed). Upstream's remembered-selection logic keeps
running untouched; the engine runs **after** it as an additive post-processing step.

### Inputs

- Audio/sub stream lists (`AudioStreamModel` / `SubStreamModel`), server default indices,
  the indices produced by upstream `selectAudioStream`/`selectSubStream`, and whether a previous
  (remembered) stream existed for each track type.
- Preferences object: audio mode (`any` / `originalVersion` / `language(code)`), preferred subtitle
  language, subtitle mode (`smart` / `always` / `onlyforced` / `none` / `default`).
- Expanded language-code sets (e.g. French → {`fr`, `fra`, `fre`}) computed by the caller via
  `CultureDto.matchesLanguageCode` / `threeLetterISOLanguageNames`, so the engine stays pure.

### Audio decision

Preferences apply **only when no remembered/previous stream existed** (fresh playback) — this makes
"manual pick wins" fall out naturally:

1. **Original Version mode:**
   a. Word-boundary label match on the track title/display title: `VO`, `V.O.`, `VOST`, `VOSTFR`,
      `VOSTA`, `version originale`, `original` (case-insensitive; no false hits on e.g. "voice").
   b. No label match → **anti-dub heuristic:** exclude audio tracks whose language matches the
      preferred subtitle language (language-code match; French dub title tokens `VF`, `VFF`, `VFQ`,
      `VFI` used only as a fallback when the track language is unknown/`und`). Pick the default
      (`isDefault`) or first remaining track. If nothing remains → server default.
2. **Language mode:** language-code match (expanded set), preferring the default-flagged track
   among matches (avoids commentary tracks) → server default when no match.
3. **Any mode:** server default (engine is a no-op for audio).

### Subtitle decision (evaluated against the audio track actually chosen — this is the Smart fix)

At playback start, applied only when no remembered/previous subtitle existed. The subtitle
decision is exposed as its own function so the mid-playback audio-switch hook (Section 3) can call
it directly — there, the `userPickedSubtitleManually` session flag replaces the remembered-stream
check. `preferred` = subtitle language preference; if unset, the engine leaves the server's index
untouched (mode logic needs a language).

- `smart`: chosen-audio language ≠ preferred → pick non-forced subtitle in preferred language
  (preferring the default-flagged one among candidates, avoiding SDH/commentary subs);
  if only a forced one exists in that language, use it; else fall back to the server default index.
  Chosen-audio language = preferred → forced subtitle in that language if present, else off (−1).
- `always`: non-forced subtitle in preferred language; if only a forced one exists in that
  language, use it (intentionally better than nothing); else fall back to the server default.
- `onlyforced`: forced subtitle in preferred language, else off.
- `none`: off (−1).
- `default`: server index untouched.

Selecting the audio "Off" pseudo-track (index −1, empty language) counts as *not matching* the
preferred language, so `smart` enables subtitles — intentional: watching without audio warrants
subtitles.

Forced detection uses the DTO's `isForced` flag — added as a new field on `SubStreamModel`
(additive, from `MediaStream.isForced`) — replacing the fragile `displayTitle.contains('forced')`.

## Section 3 — Integration points

- **`lib/models/playback/playback_model.dart`** (`_createServerPlaybackModel` only): after the
  existing `selectAudioStream`/`selectSubStream` calls, one small **added** block invoking the
  engine, gated on `oldModel == null` (fresh playback — the precedence rule). `shouldReload` is
  deliberately **not** hooked: it always runs with a current stream present (it reloads active
  playback, e.g. right after a manual track switch), so applying preferences there would clobber
  the user's manual pick.
- **Preferences assembly + session state:** new Maktep provider file
  `lib/providers/track_preferences_provider.dart` (generated Riverpod):
  - assembles the engine's preferences object from `userProvider` (userConfiguration +
    userSettings) and `culturesProvider` (expanded code sets);
  - holds a per-playback-session `userPickedSubtitleManually` flag, reset when a new item loads
    (`loadPlaybackItem`).
- **Mid-playback audio switch:** in `lib/screens/video_player/components/video_player_options_sheet.dart`,
  one added call after `setAudio(...)`: if subtitle mode is `smart` and `userPickedSubtitleManually`
  is false, re-evaluate the subtitle via the engine and apply with `setSubtitle(...)`. Manual
  subtitle taps set the flag. The change rides the existing
  `shouldReload(isLocalTrackSwitch: true)` flow, so SyncPlay needs nothing new.
- **Offline playback:** `_createOfflinePlaybackModel` gets the same additive engine hook over the
  synced item's streams (no server involved).
- **Untouched:** Live TV path (`TvPlaybackModel`), native player (indices already flow through
  `mediaStreams`), transcode burn-in logic.

**Known limitations (accepted):**
- Native-player (Android TV) mid-playback audio switches do **not** re-run the smart subtitle
  rule — only the in-app options sheet does. Manual subtitle picks from the native UI *do* set the
  manual-override flag (`MediaControlsWrapper.swapSubtitleTrack`). Initial track selection covers
  the native player since indices flow through `mediaStreams`.
- With "remember audio/subtitle selections" **disabled**, next-episode transitions
  (`oldModel != null`) fall back to server defaults — neither remembered nor preferred tracks.
  This follows the fresh-playback gate; preferences then apply only to the first item of a
  playback session.

## Section 4 — Edge cases

- Language code variants: `fre` vs `fra` vs `fr` all match via expanded culture code sets.
- Tracks with unknown/`und` language: excluded from language matching; French dub title tokens used
  as fallback only in the anti-dub exclusion.
- No subtitle available in preferred language: `smart`/`always` fall back to the server default
  index; `onlyforced` falls back to off.
- Audio "Off" pseudo-track (index −1) and subtitle "Off" entries: ignored by the engine; −1
  semantics preserved.
- `subtitleLanguagePreference` unset: subtitle engine is a no-op (server behavior unchanged).
- Anti-dub misfire risk (foreign-original film that also carries dubs but no VO label and no
  language metadata): accepted; falls back to default/first remaining track.

## Section 5 — Testing

New `test/util/track_preferences_test.dart` — pure-logic tests, **no new dev dependencies**:

- VO label variants match; word-boundary negatives ("voice", "Provo") don't.
- Anime anti-dub: jpn + fre(default, "VF") → jpn audio; with sub pref fr + smart → fr subtitles.
- French-only film, sub pref fr, smart → fr audio, no subtitles.
- English film, VO mode, sub pref fr, smart → en audio + non-forced fr subtitles.
- Audio = preferred sub language + smart → forced-only subtitle, else off.
- Manual pick wins: previous stream present → engine no-op.
- Each subtitle mode (`always`, `onlyforced`, `none`, `default`).
- `fre`/`fra` normalization; `isForced` flag handling; empty stream lists.

Manual smoke tests (real player, per project convention): fresh playback of an English movie and a
jpn+VF anime with VO+fr prefs; mid-playback audio switch toggling smart subs on/off; manual subtitle
pick then audio switch (no override); next-episode transition keeping a manual audio pick.

## Merge-conflict budget

- New files: `lib/util/track_preferences.dart`, `lib/providers/track_preferences_provider.dart`,
  `lib/screens/settings/widgets/preferred_audio_track_setting.dart`,
  `test/util/track_preferences_test.dart` (~90% of the code).
- Additive-only edits: `playback_model.dart` (2 hook blocks), `video_player_options_sheet.dart`
  (1 hook + flag set), `user_provider.dart` (1 method), `UserSettings` model (1 field),
  `media_streams_model.dart` (`isForced` field), `profile_settings_page.dart` (1 line),
  `app_en.arb`/`app_fr.arb` (keys).
- Diff-reducing edit: `streams_selection.dart` restored to upstream pristine state.
