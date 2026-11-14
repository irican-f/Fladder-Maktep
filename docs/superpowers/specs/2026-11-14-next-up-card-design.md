# Next-up card (replaces the split-screen next-episode screen)

## Why

The current next-episode screen (`VideoPlayerNextWrapper`) shrinks the video into a
split screen, scatters buttons around it (resume/close above, play/skip below, a timer
in the side card) and shows a long synopsis. It feels unnatural and is hard to use,
especially on touch screens. The user picked direction **A, corner card**
(Netflix / Disney+ style) from the mockups.

## Goals

- The video stays full size; nothing moves or shrinks when next-up appears.
- A compact card fades in at the bottom right: the next item's image, a kicker
  (`Next · S2:E2`), its title, a primary **Play** button and a secondary
  **Watch credits** button.
- The countdown is shown as a fill on the Play button (and a thin bar under the image),
  with the seconds left in the label (`▶ Play · 8`).
- The normal player controls stay usable while the card is shown.

## Non-goals

- The native Android / Android TV player (Kotlin) and the TV guide wrapper
  (`VideoPlayerGuideWrapper`) are untouched.
- No change to *when* next-up appears (smart mode on credits, static mode 32 s before
  the end, off) or to the 30 s autoplay countdown.
- No new settings.

## Anti-goals

- Anything that covers the subtitles or the bottom control bar while it is visible.
- A card that steals taps meant for the video on touch screens.

## Approach (picked: 1)

1. **Rewrite `VideoPlayerNextWrapper` as an overlay** (picked). Keep its trigger logic
   (`determineShow`, `showNextScreen`, `onTimeOut`, `hideNextUp`) and its
   `RestartableTimerController`; replace the split-screen layout with
   `Stack[video, controls, card]`. Most of the file is deleted, the change stays in a
   file maktep hasn't modified, so it merges cleanly and can go upstream as one PR.
2. Put the card inside `video_player_controls.dart` next to `SkipSegmentButton`.
   Rejected: that file conflicts on every upstream merge, and the wrapper's split
   screen would still have to be removed.

## Design

- **Layout:** video and `controlsBuilder(...)` fill the screen as when next-up is hidden.
  The card is `Align(bottomRight)` with padding from `MediaQuery.paddingOf(context)`
  plus a margin, and lifted above the bottom control bar so neither covers the other.
  Width about 34% of the screen on landscape desktop/TV, about 44% on a phone held
  sideways, clamped to sensible min/max widths; in portrait it spans the width at the
  bottom. Fade + slight slide in/out (~250 ms, same speed as today).
- **Card content:** episode → 16:9 primary image; movie → the item's image the same
  way `_NextUpInformation` picks it today (poster for movies). Kicker uses the item's
  existing label (`item.label(...)`), title `item.title`. No synopsis.
- **Buttons:** Play → `onTimeOut()` (play next now). Watch credits → `hideNextUp()`
  (hides the card for this episode, as "resume" does today). The old close-player and
  resume buttons and `_SimpleControls` go away; the player's own controls cover them.
- **Controls interaction:** `controlsBuilder` keeps receiving `nextUpVisible`, but the
  controls are no longer hidden or made non-interactive by it; it is only used to keep
  the subtitles clear of the card if needed.
- **D-pad / keyboard:** when the card appears, Play gets focus; Back/Esc while the card
  is visible dismisses the card instead of closing the player.
- **Desktop title bar:** keep showing the custom title bar the same way the player does
  without next-up (the extra `DefaultTitleBar` overlay used for the split screen is no
  longer needed).

## Left to the builder

- Exact sizes, margins, and the min/max card width, by eye on desktop, phone sideways
  and portrait.
- How the card is lifted above the bottom controls (fixed offset vs measuring the
  controls).
- Whether the card stays clickable while the player overlay is hidden (it should;
  only the Back/Esc behaviour above is required).

## Verification

`flutter analyze` clean, tests unchanged, then check by hand in the web build on a
desktop window, a phone sideways and in portrait: card appears at credits, countdown
fills and plays next, Play plays immediately, Watch credits hides it, controls still
work, nothing overlaps the subtitles or the control bar.
