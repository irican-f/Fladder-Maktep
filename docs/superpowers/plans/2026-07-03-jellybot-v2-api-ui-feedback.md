# Jellybot v2 — API Adaptation, Unified Add Flow & Section Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt Fladder to the new Jellybot API (addToken preview-then-commit flow, 409/410 semantics, enriched search metadata) and overhaul the jellybot section's feedback: a unified add sheet, working "already added" badges, richer result cards, three new admin pages (API clients, providers, Live TV source), and consistent snackbars.

**Architecture:** The add flow becomes a Freezed state machine driven by a generated Riverpod notifier; the UI is one adaptive sheet consuming it. Search-result badging is backed by a pure URL normalizer and a concurrent-fetch provider. New admin pages follow the existing `admin_page.dart` pattern (admin gate → NestedScaffold → SliverAppBar → sections), with read providers in `lib/providers/` and mutations inline in pages (existing convention).

**Tech Stack:** Flutter 3.35.7 (FVM), Riverpod codegen (`@riverpod`), Freezed, Chopper client generated from `swagger/jellybot.json`, auto_route (`*_page.dart` naming required by `build.yaml`), `iconsax_plus`, `flutter gen-l10n` (ARB in `lib/l10n/`).

**Spec:** `docs/superpowers/specs/2026-07-03-jellybot-v2-api-ui-feedback-design.md`

## Global Constraints

- Line length **120**; run `dart format --line-length 120` on touched non-generated files before each commit.
- CI runs `flutter analyze` with `fail-on: info` — zero infos/warnings/errors on touched code.
- Imports always `package:fladder/...` (`avoid_relative_lib_imports`).
- Braces on all `if`/`else`, even single-line.
- Never hand-edit `lib/jellyfin/**`, `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `lib/l10n/generated/**` — regenerate via `flutter pub run build_runner build --delete-conflicting-outputs` / `flutter gen-l10n`.
- New localized strings go to `lib/l10n/app_en.arb` AND `lib/l10n/app_fr.arb` only (Weblate covers other locales).
- No new dev/test dependencies (no mocktail/mockito). Tests are pure-logic only; HTTP paths go to the manual smoke checklist (Task 14).
- Log with `log` from `dart:developer`, never `print` (existing `debugPrint` calls being deleted may stay in untouched code).
- New routable screens must be named `*_page.dart` or `*_screen.dart` (build.yaml runs auto_route_generator only on those).
- The dev server `https://jellybot.maktep.fr` already runs the new API.

---

## File Structure

### New files
| Path | Responsibility |
|---|---|
| `lib/models/jellybot/jellybot_add_flow_state.dart` | `AddFlowStep`, `AddFlowFailure`, `addFlowFailureFromStatus()`, Freezed `JellybotAddFlowState` |
| `lib/providers/jellybot_add_flow_provider.dart` | `JellybotAddFlow` notifier — extract → season → duplicate → confirm → commit state machine |
| `lib/screens/jellybot/widgets/add_flow_sheet.dart` | `showAddFlowSheet()` + `AddFlowSheet` and its private step widgets |
| `lib/models/jellybot/jellybot_url_matcher.dart` | `normalizeCrawlUrlKey()` — domain-agnostic URL key for already-added matching |
| `lib/providers/jellybot_admin_provider.dart` | Read providers: api clients, all providers, live TV source, countries |
| `lib/screens/jellybot/api_clients_page.dart` | `JellybotApiClientsPage` + client card + create/edit form dialog + delete confirm |
| `lib/screens/jellybot/providers_page.dart` | `JellybotProvidersPage` + provider row + edit dialog |
| `lib/screens/jellybot/live_tv_source_page.dart` | `JellybotLiveTvSourcePage` — baseUrl + countries editor |
| `test/models/jellybot/jellybot_add_flow_state_test.dart` | Failure mapping + state defaults |
| `test/models/jellybot/jellybot_url_matcher_test.dart` | Table-driven normalizer tests |
| `test/providers/jellybot/jellybot_add_flow_provider_test.dart` | Non-HTTP controller transitions |

### Modified files
| Path | Why |
|---|---|
| `swagger/jellybot.json` | Replaced with live spec |
| `lib/jellyfin/jellybot.*` | Regenerated (do not hand-edit) |
| `lib/screens/jellybot/provider_search_page.dart` | Task 1 minimal addToken bridge; Task 6 switches to add sheet, deletes dead flow code |
| `lib/screens/jellybot/widgets/adaptive_results_view.dart` | Drop `addingItemUrl` plumbing |
| `lib/screens/jellybot/widgets/search_result_card.dart` | Drop `isAdding`; add year/score chips; normalized already-added matching; tappable tick |
| `lib/providers/jellybot_search_provider.dart` | `addedCrawlLinkUrls` → normalized keys + concurrent page fetch |
| `lib/screens/jellybot/crawl_links_page.dart`, `downloads_page.dart`, `admin_page.dart` | Snackbar swap to `FladderSnack.show` (`lib/screens/shared/fladder_notification_overlay.dart` — the app-wide convention; CLAUDE.md's `fladderSnackbar` reference is outdated) |
| `lib/screens/jellybot/jellybot_screen.dart` | Three new admin-gated tiles |
| `lib/routes/auto_router.dart` | Three new child routes |
| `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb` | New keys; FR `confirm` fix |
| `lib/screens/video_player/components/live_tv_channel_browser.dart`, `lib/screens/live_tv/live_tv_channels_screen.dart` | `LiveTvChannelCategory.entertainment` cases |

### Deleted files
- `lib/screens/jellybot/dialogs/season_picker_dialog.dart`
- `lib/screens/jellybot/dialogs/existing_media_dialog.dart`
- `lib/screens/jellybot/dialogs/confirm_crawl_link_dialog.dart`

---

## Task 1: Sync swagger, regenerate client, bridge the addToken break

The regenerated `ExtractMediaConfirmationRequest` loses `crawlLinkId` and gains `addToken` — the tree won't compile until the confirm call site is bridged. This task also fixes the two live bugs immediately: unchecked confirm response and 400-vs-409 duplicate conflation.

**Files:**
- Modify: `swagger/jellybot.json` (full replace)
- Regenerate: `lib/jellyfin/jellybot.*`
- Modify: `lib/screens/jellybot/provider_search_page.dart:509-661` (`_addToCrawlLinks`)

**Interfaces:**
- Produces: regenerated `Jellybot` client with `ExtractMediaResponse.addToken`, `ProviderSearchItemDto.year`/`.score`, `apiApiClientsGet/Post`, `apiApiClientsApiClientIdPut/Delete`, `apiProvidersAllGet`, `apiProvidersProviderIdPut`, `apiSettingsLiveTvSourceGet/Put`, `apiSettingsLiveTvSourceCountriesGet` (exact names verified in Step 3).

- [ ] **Step 1: Download the live spec over the committed one**

```bash
curl -s https://jellybot.maktep.fr/swagger/v1/swagger.json -o swagger/jellybot.json
git diff --stat swagger/jellybot.json   # sanity: large diff expected
```

- [ ] **Step 2: Regenerate**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: success; `lib/jellyfin/jellybot.swagger.dart` now contains `addToken`.

- [ ] **Step 3: Verify the generated API surface**

```bash
grep -n "addToken" lib/jellyfin/jellybot.swagger.dart | head
grep -n "apiApiClients\|apiProvidersAllGet\|apiProvidersProviderIdPut\|apiSettingsLiveTvSource" lib/jellyfin/jellybot.swagger.dart | head -20
grep -n "year\|score" lib/jellyfin/jellybot.swagger.dart | grep -i "providersearchitem" 
```

Expected: `addToken` on `ExtractMediaResponse`/`ExtractMediaConfirmationRequest`; the nine new client methods listed above (if the generator produced different names, note the actual names — Tasks 9–12 must use them); `year`/`score` on `ProviderSearchItemDto`.

- [ ] **Step 4: Bridge the confirm call site**

In `lib/screens/jellybot/provider_search_page.dart`, `_addToCrawlLinks`:

Replace the 400-as-duplicate check (lines ~527-532):

```dart
      if (!mounted) return;
      if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.localized.jellybotLinkAlreadyExists)),
        );
        return;
      }
```

Replace the confirm block (lines ~619-631):

```dart
      if (result != null && result.confirmed) {
        final confirmResponse = await api.apiCrawlLinksConfirmAddPost(
          body: ExtractMediaConfirmationRequest(
            addToken: responseToCheck.addToken,
            mediaTitle: result.editedName,
          ),
        );
        if (!confirmResponse.isSuccessful) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.localized.jellybotErrorAddingLink)),
            );
          }
          return;
        }
        ref.invalidate(addedCrawlLinkUrlsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.localized.jellybotLinkAdded)),
          );
        }
      } else {
        await _deleteCrawlLink(api, crawlLink.id);
      }
```

(The `_deleteCrawlLink` cancel path is now a harmless no-op server-side; it is deleted entirely in Task 6.)

- [ ] **Step 5: Analyze + format**

```bash
dart format --line-length 120 lib/screens/jellybot/provider_search_page.dart
flutter analyze
```
Expected: 0 issues.

- [ ] **Step 6: Commit**

```bash
git add swagger/jellybot.json lib/jellyfin/ lib/screens/jellybot/provider_search_page.dart
git commit -m "feat(jellybot): sync swagger to addToken API, bridge confirm-add"
```

---

## Task 2: Adopt `FladderSnack` across the jellybot section + FR `confirm` fix

The app-wide feedback convention is `FladderSnack.show(message, context: context)` from `lib/screens/shared/fladder_notification_overlay.dart` (adaptive overlay notifications: top-center on phone, top-right on desktop, stacking, dismissible, optional action button). The jellybot pages are the only ones still on raw `ScaffoldMessenger` — migrate them. CLAUDE.md's mention of `fladderSnackbar` is outdated; do NOT create a new helper.

**Files:**
- Modify: `lib/screens/jellybot/admin_page.dart:76,84,119,584,601`
- Modify: `lib/screens/jellybot/crawl_links_page.dart:141,190`
- Modify: `lib/screens/jellybot/downloads_page.dart:105`
- Modify: `lib/screens/jellybot/provider_search_page.dart` (the 6 remaining `ScaffoldMessenger` sites)
- Modify: `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes (existing): `FladderSnack.show(String message, {BuildContext? context, Duration? duration, bool permanent = false, String? actionLabel, VoidCallback? onActionPressed, bool showCloseButton = false})` — always pass `context: context` explicitly, matching existing call sites (e.g. `lib/widgets/syncplay/syncplay_group_sheet.dart:45`).

- [ ] **Step 1: Swap every jellybot call site**

For each `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(X)))` in the four files, replace with `FladderSnack.show(X, context: context)`. Add the import to each file:

```dart
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
```

Note: `FladderSnack.show` already guards on a null/unmounted context, but keep the existing `if (mounted)` checks around the call sites — they also protect the `context.localized` lookups.

Verify none remain:

```bash
grep -rn "ScaffoldMessenger" lib/screens/jellybot/
```
Expected: no matches.

- [ ] **Step 3: Fix the untranslated Confirm button**

In `lib/l10n/app_fr.arb`, next to the other common keys (e.g. after `"jellybotConfirmAdd"`), add:

```json
  "confirm": "Confirmer",
  "@confirm": {},
```

Run: `flutter gen-l10n`
Expected: `lib/l10n/generated/app_localizations_fr.dart` now overrides `confirm` with "Confirmer".

- [ ] **Step 4: Analyze + format + commit**

```bash
dart format --line-length 120 lib/screens/jellybot/
flutter analyze
git add lib/screens/jellybot/ lib/l10n/
git commit -m "refactor(jellybot): adopt FladderSnack notifications, FR confirm translation"
```

---

## Task 3: Add-flow state model + failure mapping (TDD)

**Files:**
- Create: `lib/models/jellybot/jellybot_add_flow_state.dart`
- Generated: `lib/models/jellybot/jellybot_add_flow_state.freezed.dart`
- Test: `test/models/jellybot/jellybot_add_flow_state_test.dart`

**Interfaces:**
- Produces: `enum AddFlowStep { extracting, seasonSelection, duplicateCheck, confirming, committing, success, failure }`; `enum AddFlowFailure { alreadyAdded, previewExpired, extractionFailed, network }`; `AddFlowFailure addFlowFailureFromStatus(int? statusCode)`; Freezed `JellybotAddFlowState` with fields `item, category, step, addToken, originalUrl, availableSeasons, selectedSeason, previewLink, existingMedia, mediaTitle, failure, failureDetail, hasRetriedExpiredToken`.

- [ ] **Step 1: Write the failing test**

```dart
// test/models/jellybot/jellybot_add_flow_state_test.dart
import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('addFlowFailureFromStatus', () {
    test('maps the documented status codes', () {
      expect(addFlowFailureFromStatus(409), AddFlowFailure.alreadyAdded);
      expect(addFlowFailureFromStatus(410), AddFlowFailure.previewExpired);
      expect(addFlowFailureFromStatus(400), AddFlowFailure.extractionFailed);
      expect(addFlowFailureFromStatus(500), AddFlowFailure.network);
      expect(addFlowFailureFromStatus(null), AddFlowFailure.network);
    });
  });

  group('JellybotAddFlowState', () {
    test('starts at extracting with no token and no failure', () {
      const state = JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'Matrix', url: 'https://a/x'),
        category: MediaCategory.movie,
      );
      expect(state.step, AddFlowStep.extracting);
      expect(state.addToken, isNull);
      expect(state.failure, isNull);
      expect(state.hasRetriedExpiredToken, isFalse);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/models/jellybot/jellybot_add_flow_state_test.dart`
Expected: FAIL — `jellybot_add_flow_state.dart` does not exist.

- [ ] **Step 3: Implement the model**

```dart
// lib/models/jellybot/jellybot_add_flow_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';

part 'jellybot_add_flow_state.freezed.dart';

enum AddFlowStep { extracting, seasonSelection, duplicateCheck, confirming, committing, success, failure }

enum AddFlowFailure { alreadyAdded, previewExpired, extractionFailed, network }

/// Maps an HTTP status from the add / select-season / confirm-add endpoints
/// to the user-facing failure kind (new API semantics: 409 duplicate,
/// 410 expired preview token, 400 extraction failure).
AddFlowFailure addFlowFailureFromStatus(int? statusCode) {
  return switch (statusCode) {
    409 => AddFlowFailure.alreadyAdded,
    410 => AddFlowFailure.previewExpired,
    400 => AddFlowFailure.extractionFailed,
    _ => AddFlowFailure.network,
  };
}

@freezed
class JellybotAddFlowState with _$JellybotAddFlowState {
  const factory JellybotAddFlowState({
    required ProviderSearchItemDto item,
    required MediaCategory category,
    @Default(AddFlowStep.extracting) AddFlowStep step,
    String? addToken,
    String? originalUrl,
    int? availableSeasons,
    int? selectedSeason,
    CrawlLinkDto? previewLink,
    MediaSearchResultDto? existingMedia,
    String? mediaTitle,
    AddFlowFailure? failure,
    String? failureDetail,
    @Default(false) bool hasRetriedExpiredToken,
  }) = _JellybotAddFlowState;
}
```

- [ ] **Step 4: Generate, test, verify pass**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test test/models/jellybot/jellybot_add_flow_state_test.dart
```
Expected: PASS.

- [ ] **Step 5: Analyze, format, commit**

```bash
dart format --line-length 120 lib/models/jellybot/jellybot_add_flow_state.dart test/models/jellybot/
flutter analyze
git add lib/models/jellybot/ test/models/jellybot/
git commit -m "feat(jellybot): add-flow state machine model with failure mapping"
```

---

## Task 4: Add-flow controller

**Files:**
- Create: `lib/providers/jellybot_add_flow_provider.dart`
- Generated: `lib/providers/jellybot_add_flow_provider.g.dart`
- Test: `test/providers/jellybot/jellybot_add_flow_provider_test.dart`

**Interfaces:**
- Consumes: `jellybotApiProvider` (`Jellybot` client), `userProvider`, `addedCrawlLinkUrlsProvider`, Task 3's model.
- Produces: `jellybotAddFlowProvider` — `JellybotAddFlowState?` (null = no active flow) with notifier methods `Future<void> start(ProviderSearchItemDto item, MediaCategory category)`, `Future<void> selectSeason(int season)`, `void continueAfterDuplicate()`, `Future<void> confirm(String name)`, `Future<void> retry()`, `void cancel()`.

> **Testing note:** Per project convention there is no HTTP mocking. The test covers only transitions that never touch HTTP (`cancel`, `confirm` guard, `continueAfterDuplicate` guard). Everything else is in the Task 14 smoke checklist.

- [ ] **Step 1: Write the failing test**

```dart
// test/providers/jellybot/jellybot_add_flow_provider_test.dart
import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/providers/jellybot_add_flow_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial state is null (no active flow)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(jellybotAddFlowProvider), isNull);
  });

  test('cancel resets state to null', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.confirming,
      ),
    );
    expect(container.read(jellybotAddFlowProvider), isNotNull);
    notifier.cancel();
    expect(container.read(jellybotAddFlowProvider), isNull);
  });

  test('confirm without an addToken is a no-op (no HTTP fired)', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.confirming,
      ),
    );
    await notifier.confirm('X');
    // Without a token nothing must change — still confirming, no failure.
    final state = container.read(jellybotAddFlowProvider);
    expect(state?.step, AddFlowStep.confirming);
    expect(state?.failure, isNull);
  });

  test('continueAfterDuplicate moves duplicateCheck to confirming', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(jellybotAddFlowProvider.notifier);
    notifier.debugSetState(
      const JellybotAddFlowState(
        item: ProviderSearchItemDto(title: 'X', url: 'https://a/x'),
        category: MediaCategory.movie,
        step: AddFlowStep.duplicateCheck,
        addToken: 'tok',
      ),
    );
    notifier.continueAfterDuplicate();
    expect(container.read(jellybotAddFlowProvider)?.step, AddFlowStep.confirming);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/providers/jellybot/jellybot_add_flow_provider_test.dart`
Expected: FAIL — provider does not exist.

- [ ] **Step 3: Implement the controller**

```dart
// lib/providers/jellybot_add_flow_provider.dart
import 'dart:convert';
import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/providers/user_provider.dart';

part 'jellybot_add_flow_provider.g.dart';

/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
@riverpod
class JellybotAddFlow extends _$JellybotAddFlow {
  @override
  JellybotAddFlowState? build() => null;

  /// Test hook — lets pure-logic tests seed a state without HTTP.
  @visibleForTesting
  void debugSetState(JellybotAddFlowState? value) => state = value;

  Future<void> start(ProviderSearchItemDto item, MediaCategory category) async {
    state = JellybotAddFlowState(item: item, category: category);
    final api = ref.read(jellybotApiProvider);
    final user = ref.read(userProvider);
    try {
      final response = await api.apiCrawlLinksPost(
        body: ExtractMediaRequest(
          url: item.url,
          mediaCategory: category,
          userId: user?.id,
          userName: user?.name,
        ),
      );
      _handlePreviewResponse(response);
    } catch (e) {
      log('Add-flow extraction failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  Future<void> selectSeason(int season) async {
    final s = state;
    if (s == null || s.step != AddFlowStep.seasonSelection) {
      return;
    }
    state = s.copyWith(step: AddFlowStep.extracting, selectedSeason: season);
    final api = ref.read(jellybotApiProvider);
    final user = ref.read(userProvider);
    try {
      final response = await api.apiCrawlLinksSelectSeasonPost(
        body: SelectSeasonRequest(
          url: s.originalUrl ?? s.item.url,
          season: season,
          userName: user?.name,
          userId: user?.id,
          mediaCategory: s.category,
        ),
      );
      _handlePreviewResponse(response);
    } catch (e) {
      log('Add-flow season selection failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  void continueAfterDuplicate() {
    final s = state;
    if (s == null || s.step != AddFlowStep.duplicateCheck) {
      return;
    }
    state = s.copyWith(step: AddFlowStep.confirming);
  }

  Future<void> confirm(String name) async {
    final s = state;
    if (s == null || s.addToken == null || s.step != AddFlowStep.confirming) {
      return;
    }
    state = s.copyWith(step: AddFlowStep.committing, mediaTitle: name);
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiCrawlLinksConfirmAddPost(
        body: ExtractMediaConfirmationRequest(
          addToken: s.addToken,
          mediaTitle: name.trim() == (s.previewLink?.name ?? '').trim() ? null : name.trim(),
        ),
      );
      if (response.statusCode == 410 && !s.hasRetriedExpiredToken) {
        // Preview expired — transparently re-extract once, then let the user
        // press confirm again with the fresh token.
        await _reExtractAfterExpiry(name);
        return;
      }
      if (!response.isSuccessful) {
        if (response.statusCode == 409) {
          ref.invalidate(addedCrawlLinkUrlsProvider);
        }
        _fail(addFlowFailureFromStatus(response.statusCode), _problemDetail(response));
        return;
      }
      ref.invalidate(addedCrawlLinkUrlsProvider);
      state = state?.copyWith(step: AddFlowStep.success);
    } catch (e) {
      log('Add-flow confirm failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  /// From a failure state, restart the flow for the same item, preserving
  /// the user's edited title.
  Future<void> retry() async {
    final s = state;
    if (s == null || s.step != AddFlowStep.failure) {
      return;
    }
    final keepTitle = s.mediaTitle;
    await start(s.item, s.category);
    final after = state;
    if (after != null && keepTitle != null && after.failure == null) {
      state = after.copyWith(mediaTitle: keepTitle);
    }
  }

  void cancel() {
    state = null;
  }

  Future<void> _reExtractAfterExpiry(String name) async {
    final s = state;
    if (s == null) {
      return;
    }
    state = s.copyWith(
      step: AddFlowStep.extracting,
      hasRetriedExpiredToken: true,
      mediaTitle: name,
    );
    final api = ref.read(jellybotApiProvider);
    final user = ref.read(userProvider);
    try {
      final Response<ExtractMediaResponse> response;
      if (s.selectedSeason != null) {
        response = await api.apiCrawlLinksSelectSeasonPost(
          body: SelectSeasonRequest(
            url: s.originalUrl ?? s.item.url,
            season: s.selectedSeason,
            userName: user?.name,
            userId: user?.id,
            mediaCategory: s.category,
          ),
        );
      } else {
        response = await api.apiCrawlLinksPost(
          body: ExtractMediaRequest(
            url: s.item.url,
            mediaCategory: s.category,
            userId: user?.id,
            userName: user?.name,
          ),
        );
      }
      _handlePreviewResponse(response, keepTitle: name, skipDuplicateCheck: true);
    } catch (e) {
      log('Add-flow re-extraction failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  void _handlePreviewResponse(
    Response<ExtractMediaResponse> response, {
    String? keepTitle,
    bool skipDuplicateCheck = false,
  }) {
    final s = state;
    if (s == null) {
      return; // Flow was cancelled while the request was in flight.
    }
    if (!response.isSuccessful || response.body == null) {
      if (response.statusCode == 409) {
        ref.invalidate(addedCrawlLinkUrlsProvider);
      }
      _fail(addFlowFailureFromStatus(response.statusCode), _problemDetail(response));
      return;
    }
    final body = response.body!;
    if (body.requiresSeasonSelection == true && (body.availableSeasons ?? 0) > 0) {
      state = s.copyWith(
        step: AddFlowStep.seasonSelection,
        availableSeasons: body.availableSeasons,
        originalUrl: body.originalUrl ?? s.item.url,
      );
      return;
    }
    CrawlLinkDto? preview;
    if (body.crawlLink != null) {
      preview = CrawlLinkDto.fromJson(body.crawlLink as Map<String, dynamic>);
    }
    MediaSearchResultDto? existing;
    if (body.mediaExistsOnServer == true && body.existingMedia != null) {
      existing = MediaSearchResultDto.fromJson(body.existingMedia as Map<String, dynamic>);
    }
    state = s.copyWith(
      step: (existing != null && !skipDuplicateCheck) ? AddFlowStep.duplicateCheck : AddFlowStep.confirming,
      addToken: body.addToken,
      originalUrl: body.originalUrl ?? s.originalUrl ?? s.item.url,
      previewLink: preview,
      existingMedia: existing,
      mediaTitle: keepTitle ?? preview?.name ?? body.mediaTitle ?? s.item.title,
    );
  }

  void _fail(AddFlowFailure failure, String? detail) {
    final s = state;
    if (s == null) {
      return;
    }
    state = s.copyWith(step: AddFlowStep.failure, failure: failure, failureDetail: detail);
  }

  String? _problemDetail(Response<dynamic> response) {
    try {
      final decoded = jsonDecode(response.bodyString);
      if (decoded is Map<String, dynamic>) {
        return (decoded['detail'] ?? decoded['title'])?.toString();
      }
    } catch (_) {
      // Not a ProblemDetails payload — no detail to show.
    }
    return null;
  }
}
```

- [ ] **Step 4: Generate, run tests, verify pass**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter test test/providers/jellybot/jellybot_add_flow_provider_test.dart
```
Expected: PASS (4 tests).

- [ ] **Step 5: Analyze, format, commit**

```bash
dart format --line-length 120 lib/providers/jellybot_add_flow_provider.dart test/providers/jellybot/
flutter analyze
git add lib/providers/ test/providers/jellybot/
git commit -m "feat(jellybot): add-flow controller (extract/season/duplicate/confirm/commit)"
```

---

## Task 5: Add-flow sheet UI + l10n keys

**Files:**
- Create: `lib/screens/jellybot/widgets/add_flow_sheet.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes: `jellybotAddFlowProvider` (Task 4), `jellybotSearchControllerProvider.notifier.searchState.category` (sheet reuses existing l10n keys: `jellybotMediaExistsTitle`, `jellybotMediaExistsMessage`, `jellybotExistingTitle`, `jellybotOriginalTitle`, `jellybotProductionYear`, `jellybotViewOnJellyfin`, `jellybotAddedLinkTitle`, `jellybotYesSameMedia`, `jellybotNoDifferentMedia`, `jellybotSelectSeason`, `jellybotConfirmAdd`, `jellybotLinkAdded`, `jellybotLinkAlreadyExists`, `retry`, `cancel`, `confirm`, `name`, `season`, `unknown`).
- Produces: `Future<void> showAddFlowSheet(BuildContext context, WidgetRef ref, ProviderSearchItemDto item)` — the only entry point Task 6 wires up.

- [ ] **Step 1: Add the new l10n keys**

`lib/l10n/app_en.arb` (after the existing jellybot block):

```json
  "jellybotAddFlowExtracting": "Fetching media information…",
  "@jellybotAddFlowExtracting": {},
  "jellybotAddFlowCommitting": "Adding link…",
  "@jellybotAddFlowCommitting": {},
  "jellybotAddFlowPreviewExpired": "The preview expired — please try again.",
  "@jellybotAddFlowPreviewExpired": {},
  "jellybotAddFlowExtractionFailed": "Extraction failed",
  "@jellybotAddFlowExtractionFailed": {},
```

`lib/l10n/app_fr.arb`:

```json
  "jellybotAddFlowExtracting": "Extraction des informations…",
  "@jellybotAddFlowExtracting": {},
  "jellybotAddFlowCommitting": "Ajout du lien…",
  "@jellybotAddFlowCommitting": {},
  "jellybotAddFlowPreviewExpired": "L'aperçu a expiré — veuillez réessayer.",
  "@jellybotAddFlowPreviewExpired": {},
  "jellybotAddFlowExtractionFailed": "Échec de l'extraction",
  "@jellybotAddFlowExtractionFailed": {},
```

Run: `flutter gen-l10n` — expected: success.

- [ ] **Step 2: Implement the sheet**

```dart
// lib/screens/jellybot/widgets/add_flow_sheet.dart
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/providers/jellybot_add_flow_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/routes/auto_router.gr.dart';
import 'package:fladder/screens/jellybot/widgets/language_badge.dart';
import 'package:fladder/screens/jellybot/widgets/quality_badge.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

/// Opens the unified add flow for [item]: starts the controller immediately
/// (so extraction begins before the sheet has even rendered) and presents an
/// adaptive container — dialog on wide layouts, bottom sheet on phones.
/// Always resets the controller when the sheet closes.
Future<void> showAddFlowSheet(BuildContext context, WidgetRef ref, ProviderSearchItemDto item) async {
  final category = ref.read(jellybotSearchControllerProvider.notifier).searchState.category;
  unawaited(ref.read(jellybotAddFlowProvider.notifier).start(item, category));
  if (AdaptiveLayout.layoutModeOf(context) == LayoutMode.single) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddFlowSheet(),
    );
  } else {
    await showDialog(
      context: context,
      builder: (_) => const Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480),
          child: AddFlowSheet(),
        ),
      ),
    );
  }
  ref.read(jellybotAddFlowProvider.notifier).cancel();
}

class AddFlowSheet extends ConsumerWidget {
  const AddFlowSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jellybotAddFlowProvider);

    ref.listen(jellybotAddFlowProvider, (previous, next) {
      if (next?.step == AddFlowStep.success && previous?.step != AddFlowStep.success) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            Navigator.of(context).maybePop();
          }
        });
      }
    });

    if (state == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FlowHeader(state: state),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (state.step) {
                AddFlowStep.extracting => _ProgressStep(
                    key: const ValueKey('extracting'),
                    label: context.localized.jellybotAddFlowExtracting,
                  ),
                AddFlowStep.committing => _ProgressStep(
                    key: const ValueKey('committing'),
                    label: context.localized.jellybotAddFlowCommitting,
                  ),
                AddFlowStep.seasonSelection => _SeasonStep(state: state),
                AddFlowStep.duplicateCheck => _DuplicateStep(state: state),
                AddFlowStep.confirming => _ConfirmStep(state: state),
                AddFlowStep.success => const _SuccessStep(),
                AddFlowStep.failure => _FailureStep(state: state),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowHeader extends StatelessWidget {
  final JellybotAddFlowState state;
  const _FlowHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final item = state.item;
    final thumb = state.previewLink?.thumbnailUrl ?? item.thumbnailUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((thumb ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                thumb!,
                width: 56,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 56, height: 84),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.mediaTitle ?? item.title ?? context.localized.unknown,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if ((item.quality ?? state.previewLink?.quality ?? '').isNotEmpty)
                    QualityBadge(quality: (item.quality ?? state.previewLink?.quality)!),
                  if ((item.language ?? '').isNotEmpty) LanguageBadge(language: item.language!),
                  if (item.year != null || state.previewLink?.productionYear != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${item.year ?? state.previewLink?.productionYear}'),
                    ),
                  if (state.selectedSeason != null || item.season != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('${context.localized.season(1)} ${state.selectedSeason ?? item.season}'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  const _ProgressStep({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SeasonStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _SeasonStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasons = state.availableSeasons ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized.jellybotSelectSeason, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: seasons,
            itemBuilder: (context, index) {
              final season = index + 1;
              return ListTile(
                leading: const Icon(IconsaxPlusLinear.video_play),
                title: Text('${context.localized.season(1)} $season'),
                onTap: () => ref.read(jellybotAddFlowProvider.notifier).selectSeason(season),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(context.localized.cancel),
          ),
        ),
      ],
    );
  }
}

class _DuplicateStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _DuplicateStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = state.existingMedia;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized.jellybotMediaExistsTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(context.localized.jellybotMediaExistsMessage, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.localized.jellybotExistingTitle,
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                ),
                const SizedBox(height: 4),
                Text(
                  media?.title ?? context.localized.unknown,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (media?.productionYear != null)
                  Text('${media!.productionYear}', style: theme.textTheme.bodyMedium),
                if ((media?.id ?? '').isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      final router = context.router;
                      Navigator.of(context).maybePop();
                      router.push(DetailsRoute(id: media!.id!.replaceAll('-', '')));
                    },
                    icon: const Icon(IconsaxPlusLinear.export_3, size: 18),
                    label: Text(context.localized.jellybotViewOnJellyfin),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.localized.jellybotAddedLinkTitle,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
        ),
        Text(state.mediaTitle ?? state.item.title ?? '', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(context.localized.cancel),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                final router = context.router;
                final id = media?.id;
                Navigator.of(context).maybePop();
                if (id != null && id.isNotEmpty) {
                  router.push(DetailsRoute(id: id.replaceAll('-', '')));
                }
              },
              child: Text(context.localized.jellybotYesSameMedia),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => ref.read(jellybotAddFlowProvider.notifier).continueAfterDuplicate(),
              child: Text(context.localized.jellybotNoDifferentMedia),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmStep extends ConsumerStatefulWidget {
  final JellybotAddFlowState state;
  const _ConfirmStep({required this.state});

  @override
  ConsumerState<_ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends ConsumerState<_ConfirmStep> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.state.mediaTitle ?? widget.state.item.title ?? '');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _confirm() {
    ref.read(jellybotAddFlowProvider.notifier).confirm(_nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final link = widget.state.previewLink;
    final theme = Theme.of(context);
    final aired = link?.airedEpisodesCount ?? 0;
    final total = link?.totalEpisodesCount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.localized.jellybotConfirmAdd, style: theme.textTheme.titleSmall),
        if (aired > 0 || total > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$aired / $total ${context.localized.jellybotEpisodes(total)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _confirm(),
          decoration: InputDecoration(
            labelText: context.localized.name,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(context.localized.cancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _confirm,
              child: Text(context.localized.confirm),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(IconsaxPlusBold.tick_circle, color: scheme.tertiary, size: 28),
          const SizedBox(width: 12),
          Text(context.localized.jellybotLinkAdded, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FailureStep extends ConsumerWidget {
  final JellybotAddFlowState state;
  const _FailureStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final failure = state.failure ?? AddFlowFailure.network;
    final (IconData icon, String message) = switch (failure) {
      AddFlowFailure.alreadyAdded => (IconsaxPlusBold.tick_circle, context.localized.jellybotLinkAlreadyExists),
      AddFlowFailure.previewExpired => (IconsaxPlusLinear.timer_1, context.localized.jellybotAddFlowPreviewExpired),
      AddFlowFailure.extractionFailed => (
          IconsaxPlusLinear.warning_2,
          context.localized.jellybotAddFlowExtractionFailed
        ),
      AddFlowFailure.network => (IconsaxPlusLinear.wifi_square, context.localized.jellybotErrorAddingLink),
    };
    final isInfo = failure == AddFlowFailure.alreadyAdded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: isInfo ? theme.colorScheme.tertiary : theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          ],
        ),
        if ((state.failureDetail ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SelectableText.rich(
              TextSpan(
                text: state.failureDetail,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(context.localized.close),
            ),
            if (!isInfo) ...[
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () => ref.read(jellybotAddFlowProvider.notifier).retry(),
                icon: const Icon(IconsaxPlusLinear.refresh),
                label: Text(context.localized.retry),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
```

> If `context.localized.close` does not exist, check `app_en.arb` for an equivalent (`closeButton`, `dismiss`); if none exists add `"close": "Close"` / `"close": "Fermer"` to both ARBs and re-run `flutter gen-l10n`.
> If the analyzer flags `IconsaxPlusLinear.timer_1` or `IconsaxPlusLinear.wifi_square` as unknown symbols, substitute `IconsaxPlusLinear.clock` and `IconsaxPlusLinear.wifi` respectively.

- [ ] **Step 3: Analyze + format**

```bash
dart format --line-length 120 lib/screens/jellybot/widgets/add_flow_sheet.dart
flutter analyze
```
Expected: 0 issues (the sheet is not referenced yet — that's Task 6; an "unused" warning must NOT appear since it's a public API in its own file).

- [ ] **Step 4: Commit**

```bash
git add lib/screens/jellybot/widgets/add_flow_sheet.dart lib/l10n/
git commit -m "feat(jellybot): unified add-flow sheet with in-place steps and errors"
```

---

## Task 6: Wire the search page to the sheet, delete the old flow

**Files:**
- Modify: `lib/screens/jellybot/provider_search_page.dart`
- Modify: `lib/screens/jellybot/widgets/adaptive_results_view.dart`
- Modify: `lib/screens/jellybot/widgets/search_result_card.dart`
- Delete: `lib/screens/jellybot/dialogs/season_picker_dialog.dart`, `lib/screens/jellybot/dialogs/existing_media_dialog.dart`, `lib/screens/jellybot/dialogs/confirm_crawl_link_dialog.dart`

**Interfaces:**
- Consumes: `showAddFlowSheet(context, ref, item)` from Task 5.

- [ ] **Step 1: Rewire `provider_search_page.dart`**

- Remove the fields/methods: `String? _addingItemUrl;`, `_addToCrawlLinks`, `_navigateToExistingMedia`, `_deleteCrawlLink` (the whole block Task 1 bridged — it is now dead).
- Remove imports that become unused: the three `dialogs/` imports, `package:fladder/providers/user_provider.dart`, `package:fladder/routes/auto_router.gr.dart`.
- Add: `import 'package:fladder/screens/jellybot/widgets/add_flow_sheet.dart';`
- In `_buildResultsSlivers`, change the `AdaptiveResultsView` construction to:

```dart
              AdaptiveResultsView(
                items: items,
                provider: controllerState.provider,
                onAdd: (item) => showAddFlowSheet(context, ref, item),
              ),
```

- [ ] **Step 2: Simplify `adaptive_results_view.dart`**

Remove the `addingItemUrl` field and its uses — both `SearchResultCard` constructions become:

```dart
            (context, index) => SearchResultCard(
              item: items[index],
              provider: provider,
              onAdd: () => onAdd(items[index]),
            ),
```

- [ ] **Step 3: Simplify `search_result_card.dart`**

Remove the `isAdding` field, its constructor parameter, the `if (isAdding)` spinner branch (the trailing widget starts at the `isAlreadyAdded` tick), and change `onTap: (isAdding || isAlreadyAdded) ? null : onAdd` to `onTap: isAlreadyAdded ? null : onAdd`.

- [ ] **Step 4: Delete the three dialog files**

```bash
git rm lib/screens/jellybot/dialogs/season_picker_dialog.dart lib/screens/jellybot/dialogs/existing_media_dialog.dart lib/screens/jellybot/dialogs/confirm_crawl_link_dialog.dart
```

- [ ] **Step 5: Analyze, run all jellybot tests, format**

```bash
flutter analyze
flutter test test/providers/jellybot/ test/models/jellybot/
dart format --line-length 120 lib/screens/jellybot/
```
Expected: 0 analyzer issues, all tests pass.

- [ ] **Step 6: Commit**

```bash
git add -A lib/screens/jellybot/
git commit -m "feat(jellybot): route add action through the unified sheet, drop dialog chain"
```

---

## Task 7: URL normalizer (TDD) + reworked added-set provider

**Files:**
- Create: `lib/models/jellybot/jellybot_url_matcher.dart`
- Test: `test/models/jellybot/jellybot_url_matcher_test.dart`
- Modify: `lib/providers/jellybot_search_provider.dart:37-60` (`addedCrawlLinkUrls`)

**Interfaces:**
- Produces: `String? normalizeCrawlUrlKey(String? url)` — null for null/blank input; otherwise a lowercase, decoded, host-stripped `/path?query` key.
- Produces: `addedCrawlLinkUrlsProvider` now yields a `Set<String>` of **normalized keys** (from `relativeUrl`, falling back to `fullUrl`).

- [ ] **Step 1: Write the failing tests**

```dart
// test/models/jellybot/jellybot_url_matcher_test.dart
import 'package:fladder/models/jellybot/jellybot_url_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeCrawlUrlKey', () {
    test('strips scheme and host so rotated domains still match', () {
      expect(
        normalizeCrawlUrlKey('https://wawacity.foo/film/matrix-1080p'),
        normalizeCrawlUrlKey('https://wawacity.bar/film/matrix-1080p'),
      );
    });

    test('is case-insensitive and ignores a trailing slash', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/Film/Matrix/'),
        normalizeCrawlUrlKey('http://b.example/film/matrix'),
      );
    });

    test('decodes percent-encoding', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/film/no%C3%ABl-magique'),
        normalizeCrawlUrlKey('https://b.example/film/noël-magique'),
      );
    });

    test('keeps the query string (some providers identify items by query)', () {
      expect(normalizeCrawlUrlKey('https://a.example/watch?id=42'), '/watch?id=42');
      expect(
        normalizeCrawlUrlKey('https://a.example/watch?id=42'),
        isNot(normalizeCrawlUrlKey('https://a.example/watch?id=43')),
      );
    });

    test('accepts already-relative urls', () {
      expect(normalizeCrawlUrlKey('/film/matrix-1080p'), '/film/matrix-1080p');
      expect(normalizeCrawlUrlKey('film/matrix-1080p'), '/film/matrix-1080p');
    });

    test('returns null for null, empty and blank input', () {
      expect(normalizeCrawlUrlKey(null), isNull);
      expect(normalizeCrawlUrlKey(''), isNull);
      expect(normalizeCrawlUrlKey('   '), isNull);
    });

    test('survives malformed percent-encoding without throwing', () {
      expect(normalizeCrawlUrlKey('https://a.example/bad%zz'), isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `flutter test test/models/jellybot/jellybot_url_matcher_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Implement**

```dart
// lib/models/jellybot/jellybot_url_matcher.dart

/// Normalizes a crawl-link URL to a domain-agnostic comparison key.
///
/// Providers rotate domains regularly (that's what the server's Domain
/// Update job is for), so matching search-result URLs against stored
/// crawl-link URLs must ignore scheme and host. The key is the decoded,
/// lowercased path (no trailing slash) plus the query string when present.
String? normalizeCrawlUrlKey(String? url) {
  if (url == null || url.trim().isEmpty) {
    return null;
  }
  final value = url.trim().toLowerCase();
  String path;
  String query = '';
  final uri = Uri.tryParse(value);
  if (uri != null && uri.hasAuthority) {
    path = uri.path;
    query = uri.query;
  } else {
    path = value;
    final queryIndex = path.indexOf('?');
    if (queryIndex >= 0) {
      query = path.substring(queryIndex + 1);
      path = path.substring(0, queryIndex);
    }
  }
  try {
    path = Uri.decodeComponent(path);
  } on FormatException {
    // Malformed percent-encoding — compare the raw path instead.
  }
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  if (!path.startsWith('/')) {
    path = '/$path';
  }
  return query.isEmpty ? path : '$path?$query';
}
```

- [ ] **Step 4: Run tests, verify pass**

Run: `flutter test test/models/jellybot/jellybot_url_matcher_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Rework `addedCrawlLinkUrls` (concurrent + normalized)**

Replace the provider in `lib/providers/jellybot_search_provider.dart` (add `import 'package:fladder/models/jellybot/jellybot_url_matcher.dart';`):

```dart
/// Normalized URL keys (see [normalizeCrawlUrlKey]) of every crawl link the
/// server knows — backs the "already added" badge on search-result cards.
/// Page 0 is fetched first to learn totalPages, remaining pages concurrently.
/// Invalidated after every successful add (and on 409s) to refresh badging.
@Riverpod(keepAlive: true)
Future<Set<String>> addedCrawlLinkUrls(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final keys = <String>{};

  void collect(PaginatedResponseOfCrawlLinkDto body) {
    for (final item in body.items ?? const <CrawlLinkDto>[]) {
      final key = normalizeCrawlUrlKey(item.relativeUrl) ?? normalizeCrawlUrlKey(item.fullUrl);
      if (key != null) {
        keys.add(key);
      }
    }
  }

  final first = await api.apiCrawlLinksGet(page: 0, limit: 200);
  if (!first.isSuccessful || first.body == null) {
    return keys;
  }
  collect(first.body!);

  final totalPages = first.body!.totalPages ?? 1;
  if (totalPages > 1) {
    final rest = await Future.wait([
      for (var page = 1; page < totalPages; page++) api.apiCrawlLinksGet(page: page, limit: 200),
    ]);
    for (final response in rest) {
      if (response.isSuccessful && response.body != null) {
        collect(response.body!);
      }
    }
  }
  return keys;
}
```

- [ ] **Step 6: Match with normalized keys in the card**

In `lib/screens/jellybot/widgets/search_result_card.dart` (add `import 'package:fladder/models/jellybot/jellybot_url_matcher.dart';`), replace the matching lines:

```dart
    final addedKeys = ref.watch(addedCrawlLinkUrlsProvider).valueOrNull ?? const <String>{};
    final itemKey = normalizeCrawlUrlKey(item.url);
    final isAlreadyAdded = itemKey != null && addedKeys.contains(itemKey);
```

- [ ] **Step 7: Analyze, test, format, commit**

```bash
flutter analyze
flutter test test/models/jellybot/ test/providers/jellybot/
dart format --line-length 120 lib/models/jellybot/jellybot_url_matcher.dart lib/providers/jellybot_search_provider.dart lib/screens/jellybot/widgets/search_result_card.dart test/models/jellybot/
git add lib/models/jellybot/ lib/providers/jellybot_search_provider.dart lib/screens/jellybot/widgets/search_result_card.dart test/models/jellybot/
git commit -m "feat(jellybot): domain-agnostic already-added matching, concurrent page fetch"
```

---

## Task 8: Result card enrichment (year, score, tappable added-tick)

**Files:**
- Modify: `lib/screens/jellybot/widgets/search_result_card.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes: `ProviderSearchItemDto.year` / `.score` (Task 1), `FladderSnack.show` (existing convention, see Task 2), existing `_MetaChip`.

- [ ] **Step 1: Add l10n keys**

`app_en.arb`:
```json
  "jellybotMatchScore": "Match score",
  "@jellybotMatchScore": {},
```
`app_fr.arb`:
```json
  "jellybotMatchScore": "Score de correspondance",
  "@jellybotMatchScore": {},
```
Run: `flutter gen-l10n`.

- [ ] **Step 2: Add year + score chips**

In the badges `Wrap` of `search_result_card.dart`, after the season chip:

```dart
                        if (item.year != null)
                          _MetaChip(
                            icon: IconsaxPlusLinear.calendar_1,
                            label: '${item.year}',
                          ),
                        if (item.score != null)
                          Tooltip(
                            message: context.localized.jellybotMatchScore,
                            child: _MetaChip(
                              icon: IconsaxPlusLinear.activity,
                              label: '${(item.score! * 100).round()}%',
                            ),
                          ),
```

> If the analyzer flags `IconsaxPlusLinear.calendar_1` as unknown, use `IconsaxPlusLinear.calendar` instead.

- [ ] **Step 3: Make the added-tick informative**

Replace the `isAlreadyAdded` trailing branch (`Tooltip` wrapping a plain `Icon`) with (add `import 'package:fladder/screens/shared/fladder_notification_overlay.dart';`):

```dart
              else if (isAlreadyAdded)
                IconButton(
                  onPressed: () => FladderSnack.show(context.localized.jellybotLinkAlreadyExists, context: context),
                  tooltip: context.localized.jellybotAlreadyAdded,
                  icon: Icon(IconsaxPlusBold.tick_circle, color: scheme.tertiary, size: 28),
                )
```

- [ ] **Step 4: Analyze, format, commit**

```bash
flutter analyze
dart format --line-length 120 lib/screens/jellybot/widgets/search_result_card.dart
git add lib/screens/jellybot/widgets/search_result_card.dart lib/l10n/
git commit -m "feat(jellybot): year and match-score chips, tappable added indicator"
```

---

## Task 9: Admin data providers (reads)

**Files:**
- Create: `lib/providers/jellybot_admin_provider.dart`
- Generated: `lib/providers/jellybot_admin_provider.g.dart`

**Interfaces:**
- Consumes: generated client methods verified in Task 1 Step 3 (`apiApiClientsGet`, `apiProvidersAllGet`, `apiSettingsLiveTvSourceGet`, `apiSettingsLiveTvSourceCountriesGet`) — if Task 1 recorded different generated names, use those.
- Produces: `jellybotApiClientsProvider` → `Future<List<ApiClientDto>>`; `jellybotAllProvidersProvider` → `Future<List<IProvider>>`; `jellybotLiveTvSourceProvider` → `Future<LiveTvSourceResult>`; `jellybotLiveTvCountriesProvider` → `Future<List<String>>`. All throw on non-success so pages render `AsyncError` with retry.

- [ ] **Step 1: Implement**

```dart
// lib/providers/jellybot_admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';

part 'jellybot_admin_provider.g.dart';

/// Read-side providers for the jellybot admin pages. Mutations live in the
/// pages themselves (existing section convention) and invalidate these.
@riverpod
Future<List<ApiClientDto>> jellybotApiClients(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiApiClientsGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load API clients (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<List<IProvider>> jellybotAllProviders(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiProvidersAllGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load providers (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<LiveTvSourceResult> jellybotLiveTvSource(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiSettingsLiveTvSourceGet();
  if (!response.isSuccessful || response.body == null) {
    throw StateError('Failed to load Live TV source (HTTP ${response.statusCode})');
  }
  return response.body!;
}

@riverpod
Future<List<String>> jellybotLiveTvCountries(Ref ref) async {
  final api = ref.watch(jellybotApiProvider);
  final response = await api.apiSettingsLiveTvSourceCountriesGet();
  if (!response.isSuccessful || response.body == null) {
    return const <String>[];
  }
  return response.body!;
}
```

- [ ] **Step 2: Generate, analyze, format, commit**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
dart format --line-length 120 lib/providers/jellybot_admin_provider.dart
git add lib/providers/
git commit -m "feat(jellybot): admin read providers (api clients, providers, live tv source)"
```

---

## Task 10: Clients API page (list, create/edit, delete) + route + tile

**Files:**
- Create: `lib/screens/jellybot/api_clients_page.dart`
- Modify: `lib/routes/auto_router.dart:97-103` (`_jellybotChildren`)
- Modify: `lib/screens/jellybot/jellybot_screen.dart` (new tile)
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes: `jellybotApiClientsProvider` (Task 9), `FladderSnack.show` (existing convention, see Task 2), `userProvider` admin gate pattern from `admin_page.dart:130`, generated `CreateApiClientRequest`/`UpdateApiClientRequest`/`apiApiClientsPost`/`apiApiClientsApiClientIdPut`/`apiApiClientsApiClientIdDelete`.
- Produces: `JellybotApiClientsRoute` (path `api-clients`).

- [ ] **Step 1: Add l10n keys**

`app_en.arb` (single block, after the existing jellybot keys; every key followed by its empty `"@key": {}` metadata line, matching file style):

```json
  "jellybotApiClients": "API Clients",
  "jellybotApiClientsDesc": "Manage debrid and torrent service accounts",
  "jellybotApiClientAdd": "Add API client",
  "jellybotApiClientEdit": "Edit API client",
  "jellybotApiClientDelete": "Delete API client",
  "jellybotApiClientDeleteConfirm": "Delete this API client? This cannot be undone.",
  "jellybotApiClientName": "Name",
  "jellybotApiClientType": "Type",
  "jellybotApiClientBaseUrl": "Base URL",
  "jellybotApiClientUsername": "Username",
  "jellybotApiClientApiKey": "API key",
  "jellybotApiClientPassword": "Password",
  "jellybotApiClientSecretHint": "Leave blank to keep the current value",
  "jellybotApiClientPriority": "Priority",
  "jellybotApiClientMaxConcurrent": "Max concurrent requests",
  "jellybotApiClientRateLimit": "Rate limit per minute",
  "jellybotApiClientTorrent": "Torrent client",
  "jellybotApiClientExpiresOn": "Subscription expires {date}",
  "@jellybotApiClientExpiresOn": {"placeholders": {"date": {"type": "String"}}},
  "jellybotApiClientExpired": "Subscription expired",
  "jellybotApiClientSaved": "API client saved",
  "jellybotApiClientDeleted": "API client deleted",
  "jellybotAdvanced": "Advanced",
```

`app_fr.arb`:

```json
  "jellybotApiClients": "Clients API",
  "jellybotApiClientsDesc": "Gérer les comptes des services debrid et torrent",
  "jellybotApiClientAdd": "Ajouter un client API",
  "jellybotApiClientEdit": "Modifier le client API",
  "jellybotApiClientDelete": "Supprimer le client API",
  "jellybotApiClientDeleteConfirm": "Supprimer ce client API ? Cette action est irréversible.",
  "jellybotApiClientName": "Nom",
  "jellybotApiClientType": "Type",
  "jellybotApiClientBaseUrl": "URL de base",
  "jellybotApiClientUsername": "Nom d'utilisateur",
  "jellybotApiClientApiKey": "Clé API",
  "jellybotApiClientPassword": "Mot de passe",
  "jellybotApiClientSecretHint": "Laisser vide pour conserver la valeur actuelle",
  "jellybotApiClientPriority": "Priorité",
  "jellybotApiClientMaxConcurrent": "Requêtes simultanées max",
  "jellybotApiClientRateLimit": "Limite de requêtes par minute",
  "jellybotApiClientTorrent": "Client torrent",
  "jellybotApiClientExpiresOn": "Abonnement expire le {date}",
  "@jellybotApiClientExpiresOn": {"placeholders": {"date": {"type": "String"}}},
  "jellybotApiClientExpired": "Abonnement expiré",
  "jellybotApiClientSaved": "Client API enregistré",
  "jellybotApiClientDeleted": "Client API supprimé",
  "jellybotAdvanced": "Avancé",
```

Run: `flutter gen-l10n`.

- [ ] **Step 2: Implement the page**

```dart
// lib/screens/jellybot/api_clients_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_admin_provider.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/jellybot/widgets/search_error_state.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

@RoutePage()
class JellybotApiClientsPage extends ConsumerWidget {
  const JellybotApiClientsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.lock, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(context.localized.adminOnly, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final clientsAsync = ref.watch(jellybotApiClientsProvider);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showForm(context, ref, client: null),
            icon: const Icon(IconsaxPlusLinear.add),
            label: Text(context.localized.jellybotApiClientAdd),
          ),
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                leading: AdaptiveLayout.layoutModeOf(context) == LayoutMode.single
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.router.maybePop(),
                      )
                    : null,
                title: Row(
                  children: [
                    const Icon(IconsaxPlusLinear.cloud),
                    const SizedBox(width: 12),
                    Text(context.localized.jellybotApiClients),
                  ],
                ),
              ),
              clientsAsync.when(
                data: (clients) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ApiClientCard(client: clients[index]),
                      childCount: clients.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: SearchErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(jellybotApiClientsProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _showForm(BuildContext context, WidgetRef ref, {ApiClientDto? client}) async {
    await showDialog(
      context: context,
      builder: (_) => _ApiClientFormDialog(client: client),
    );
  }
}

class _ApiClientCard extends ConsumerWidget {
  final ApiClientDto client;
  const _ApiClientCard({required this.client});

  Future<void> _setEnabled(BuildContext context, WidgetRef ref, bool value) async {
    final api = ref.read(jellybotApiProvider);
    final response = await api.apiApiClientsApiClientIdPut(
      apiClientId: client.id,
      body: UpdateApiClientRequest(isEnabled: value),
    );
    if (!context.mounted) {
      return;
    }
    if (response.isSuccessful) {
      ref.invalidate(jellybotApiClientsProvider);
    } else {
      FladderSnack.show('HTTP ${response.statusCode}', context: context);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localized.jellybotApiClientDelete),
        content: Text(context.localized.jellybotApiClientDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final api = ref.read(jellybotApiProvider);
    final response = await api.apiApiClientsApiClientIdDelete(apiClientId: client.id);
    if (!context.mounted) {
      return;
    }
    if (response.isSuccessful) {
      ref.invalidate(jellybotApiClientsProvider);
      FladderSnack.show(context.localized.jellybotApiClientDeleted, context: context);
    } else {
      FladderSnack.show('HTTP ${response.statusCode}', context: context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expires = client.subscriptionExpiresAt;
    final now = DateTime.now();
    final isExpired = expires != null && expires.isBefore(now);
    final expiresSoon = expires != null && !isExpired && expires.difference(now).inDays < 7;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              client.isTorrentClient == true ? IconsaxPlusLinear.magnet : IconsaxPlusLinear.cloud,
              color: client.isActive == true ? theme.colorScheme.tertiary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name ?? '', style: theme.textTheme.titleSmall),
                  Text(
                    [
                      client.type,
                      if ((client.baseUrl ?? '').isNotEmpty) client.baseUrl,
                      '${context.localized.jellybotApiClientPriority} ${client.priority}',
                    ].whereType<String>().join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (expires != null)
                    Text(
                      isExpired
                          ? context.localized.jellybotApiClientExpired
                          : context.localized.jellybotApiClientExpiresOn(DateFormat.yMMMd().format(expires)),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isExpired
                            ? theme.colorScheme.error
                            : expiresSoon
                                ? theme.colorScheme.tertiary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: client.isEnabled ?? false,
              onChanged: (value) => _setEnabled(context, ref, value),
            ),
            IconButton(
              icon: const Icon(IconsaxPlusLinear.edit_2),
              tooltip: context.localized.jellybotApiClientEdit,
              onPressed: () => showDialog(
                context: context,
                builder: (_) => _ApiClientFormDialog(client: client),
              ),
            ),
            IconButton(
              icon: Icon(IconsaxPlusLinear.trash, color: theme.colorScheme.error),
              onPressed: () => _delete(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiClientFormDialog extends ConsumerStatefulWidget {
  final ApiClientDto? client;
  const _ApiClientFormDialog({required this.client});

  @override
  ConsumerState<_ApiClientFormDialog> createState() => _ApiClientFormDialogState();
}

class _ApiClientFormDialogState extends ConsumerState<_ApiClientFormDialog> {
  late final _name = TextEditingController(text: widget.client?.name ?? '');
  late final _type = TextEditingController(text: widget.client?.type ?? '');
  late final _baseUrl = TextEditingController(text: widget.client?.baseUrl ?? '');
  late final _username = TextEditingController(text: widget.client?.username ?? '');
  final _apiKey = TextEditingController();
  final _password = TextEditingController();
  late final _priority = TextEditingController(text: '${widget.client?.priority ?? 0}');
  late final _maxConcurrent = TextEditingController(text: '${widget.client?.maxConcurrentRequests ?? 1}');
  late final _rateLimit = TextEditingController(text: '${widget.client?.rateLimitPerMinute ?? 60}');
  late bool _isEnabled = widget.client?.isEnabled ?? true;
  late bool _isTorrent = widget.client?.isTorrentClient ?? false;
  late DateTime? _expiresAt = widget.client?.subscriptionExpiresAt;
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_name, _type, _baseUrl, _username, _apiKey, _password, _priority, _maxConcurrent, _rateLimit]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _errorText = null;
    });
    final api = ref.read(jellybotApiProvider);
    final isEdit = widget.client != null;
    final response = isEdit
        ? await api.apiApiClientsApiClientIdPut(
            apiClientId: widget.client!.id,
            body: UpdateApiClientRequest(
              name: _name.text.trim(),
              type: _type.text.trim(),
              baseUrl: _baseUrl.text.trim().isEmpty ? null : _baseUrl.text.trim(),
              username: _username.text.trim().isEmpty ? null : _username.text.trim(),
              apiKey: _apiKey.text.isEmpty ? null : _apiKey.text,
              password: _password.text.isEmpty ? null : _password.text,
              isEnabled: _isEnabled,
              isTorrentClient: _isTorrent,
              priority: int.tryParse(_priority.text),
              maxConcurrentRequests: int.tryParse(_maxConcurrent.text),
              rateLimitPerMinute: int.tryParse(_rateLimit.text),
              subscriptionExpiresAt: _expiresAt,
            ),
          )
        : await api.apiApiClientsPost(
            body: CreateApiClientRequest(
              name: _name.text.trim(),
              type: _type.text.trim(),
              baseUrl: _baseUrl.text.trim().isEmpty ? null : _baseUrl.text.trim(),
              username: _username.text.trim().isEmpty ? null : _username.text.trim(),
              apiKey: _apiKey.text.isEmpty ? null : _apiKey.text,
              password: _password.text.isEmpty ? null : _password.text,
              isEnabled: _isEnabled,
              isTorrentClient: _isTorrent,
              priority: int.tryParse(_priority.text) ?? 0,
              maxConcurrentRequests: int.tryParse(_maxConcurrent.text) ?? 1,
              rateLimitPerMinute: int.tryParse(_rateLimit.text) ?? 60,
              subscriptionExpiresAt: _expiresAt,
            ),
          );
    if (!mounted) {
      return;
    }
    if (response.isSuccessful) {
      ref.invalidate(jellybotApiClientsProvider);
      Navigator.pop(context);
      FladderSnack.show(context.localized.jellybotApiClientSaved, context: context);
    } else {
      setState(() {
        _saving = false;
        _errorText = 'HTTP ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
    final secretHint = isEdit ? context.localized.jellybotApiClientSecretHint : null;
    return AlertDialog(
      title: Text(isEdit ? context.localized.jellybotApiClientEdit : context.localized.jellybotApiClientAdd),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: '${context.localized.jellybotApiClientName} *',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _type,
                decoration: InputDecoration(
                  labelText: '${context.localized.jellybotApiClientType} *',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKey,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.localized.jellybotApiClientApiKey,
                  helperText: (widget.client?.hasApiKey ?? false) ? secretHint : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.localized.enabled),
                value: _isEnabled,
                onChanged: (value) => setState(() => _isEnabled = value),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(context.localized.jellybotAdvanced),
                children: [
                  TextField(
                    controller: _baseUrl,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientBaseUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _username,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientUsername,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientPassword,
                      helperText: (widget.client?.hasPassword ?? false) ? secretHint : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _priority,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.localized.jellybotApiClientPriority,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxConcurrent,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: context.localized.jellybotApiClientMaxConcurrent,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rateLimit,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotApiClientRateLimit,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotApiClientTorrent),
                    value: _isTorrent,
                    onChanged: (value) => setState(() => _isTorrent = value),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotApiClientExpiresOn(
                      _expiresAt != null ? DateFormat.yMMMd().format(_expiresAt!) : '—',
                    )),
                    trailing: const Icon(IconsaxPlusLinear.calendar_1),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expiresAt ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _expiresAt = picked);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(context.localized.cancel),
        ),
        FilledButton(
          onPressed: _saving || _name.text.trim().isEmpty ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(context.localized.save),
        ),
      ],
    );
  }
}
```

> Key existence checks: `context.localized.enabled`, `.save`, `.delete` — if any is missing from `app_en.arb`, add it (EN + FR: "Enabled"/"Activé", "Save"/"Enregistrer", "Delete"/"Supprimer") and re-run `flutter gen-l10n`. `ApiClientDto.id` nullability: if the generated field is `String?`, guard the PUT/DELETE calls with `if (client.id == null) return;`.

- [ ] **Step 3: Register the route**

In `lib/routes/auto_router.dart`, extend `_jellybotChildren`:

```dart
final List<AutoRoute> _jellybotChildren = [
  AutoRoute(page: JellybotSelectionRoute.page, path: 'list'),
  AutoRoute(page: JellybotProviderSearchRoute.page, path: 'search'),
  AutoRoute(page: JellybotCrawlLinksRoute.page, path: 'links'),
  AutoRoute(page: JellybotDownloadsRoute.page, path: 'downloads'),
  AutoRoute(page: JellybotApiClientsRoute.page, path: 'api-clients'),
  AutoRoute(page: JellybotAdminRoute.page, path: 'admin'),
];
```

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `auto_router.gr.dart` gains `JellybotApiClientsRoute`.

- [ ] **Step 4: Add the admin-gated tile**

In `lib/screens/jellybot/jellybot_screen.dart` `_leftPane` (before the Administration tile), and make the pane admin-aware — `_JellybotScreenState` already has `ref`:

```dart
            if (ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false)))
              SettingsListTile(
                label: Text(context.localized.jellybotApiClients),
                subLabel: Text(context.localized.jellybotApiClientsDesc),
                selected: containsRoute(const JellybotApiClientsRoute()),
                icon: IconsaxPlusLinear.cloud,
                onTap: () => navigateTo(const JellybotApiClientsRoute()),
              ),
```

Add `import 'package:fladder/providers/user_provider.dart';` to the file.

- [ ] **Step 5: Analyze, format, commit**

```bash
flutter analyze
dart format --line-length 120 lib/screens/jellybot/ lib/routes/auto_router.dart
git add lib/screens/jellybot/ lib/routes/ lib/l10n/
git commit -m "feat(jellybot): API clients management page"
```

---

## Task 11: Fournisseurs (providers management) page + route + tile

**Files:**
- Create: `lib/screens/jellybot/providers_page.dart`
- Modify: `lib/routes/auto_router.dart` (`_jellybotChildren`), `lib/screens/jellybot/jellybot_screen.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes: `jellybotAllProvidersProvider` (Task 9), `jellybotProvidersProvider` (search dropdown source — invalidated after PUT), `UpdateProviderRequest`, `apiProvidersProviderIdPut`.
- Produces: `JellybotProvidersRoute` (path `providers`).

- [ ] **Step 1: Add l10n keys** (both ARBs, `@key: {}` lines as in Task 10)

EN: `"jellybotProvidersManage": "Providers"`, `"jellybotProvidersManageDesc": "Enable, rename and configure search providers"`, `"jellybotProviderEnabled": "Enabled"`, `"jellybotProviderSearchEnabled": "Search enabled"`, `"jellybotProviderManuallyDisabled": "Manually disabled"`, `"jellybotProviderUpdated": "Provider updated"`, `"jellybotProviderEditTitle": "Edit provider"`, `"jellybotProviderUrl": "URL"`, `"jellybotProviderDisplayName": "Display name"`.

FR: `"jellybotProvidersManage": "Fournisseurs"`, `"jellybotProvidersManageDesc": "Activer, renommer et configurer les fournisseurs de recherche"`, `"jellybotProviderEnabled": "Activé"`, `"jellybotProviderSearchEnabled": "Recherche activée"`, `"jellybotProviderManuallyDisabled": "Désactivé manuellement"`, `"jellybotProviderUpdated": "Fournisseur mis à jour"`, `"jellybotProviderEditTitle": "Modifier le fournisseur"`, `"jellybotProviderUrl": "URL"`, `"jellybotProviderDisplayName": "Nom d'affichage"`.

Run: `flutter gen-l10n`.

- [ ] **Step 2: Implement the page**

```dart
// lib/screens/jellybot/providers_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_admin_provider.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/jellybot/widgets/search_error_state.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

@RoutePage()
class JellybotProvidersPage extends ConsumerWidget {
  const JellybotProvidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.lock, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(context.localized.adminOnly, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final providersAsync = ref.watch(jellybotAllProvidersProvider);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                leading: AdaptiveLayout.layoutModeOf(context) == LayoutMode.single
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.router.maybePop(),
                      )
                    : null,
                title: Row(
                  children: [
                    const Icon(IconsaxPlusLinear.global),
                    const SizedBox(width: 12),
                    Text(context.localized.jellybotProvidersManage),
                  ],
                ),
              ),
              providersAsync.when(
                data: (providers) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ProviderCard(provider: providers[index]),
                      childCount: providers.length,
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: SearchErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(jellybotAllProvidersProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderCard extends ConsumerWidget {
  final IProvider provider;
  const _ProviderCard({required this.provider});

  Future<void> _update(BuildContext context, WidgetRef ref, UpdateProviderRequest request) async {
    final id = provider.id;
    if (id == null) {
      return;
    }
    final api = ref.read(jellybotApiProvider);
    final response = await api.apiProvidersProviderIdPut(providerId: id, body: request);
    if (!context.mounted) {
      return;
    }
    if (response.isSuccessful) {
      ref.invalidate(jellybotAllProvidersProvider);
      ref.invalidate(jellybotProvidersProvider);
      FladderSnack.show(context.localized.jellybotProviderUpdated, context: context);
    } else {
      FladderSnack.show('HTTP ${response.statusCode}', context: context);
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: provider.displayName ?? provider.name ?? '');
    final urlController = TextEditingController(text: provider.url ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localized.jellybotProviderEditTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.localized.jellybotProviderDisplayName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: context.localized.jellybotProviderUrl,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localized.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.localized.save),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      await _update(
        context,
        ref,
        UpdateProviderRequest(
          displayName: nameController.text.trim(),
          url: urlController.text.trim(),
        ),
      );
    }
    nameController.dispose();
    urlController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.displayName ?? provider.name ?? '', style: theme.textTheme.titleSmall),
                      if ((provider.url ?? '').isNotEmpty)
                        Text(
                          provider.url!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (provider.isManuallyDisabled == true)
                        Text(
                          context.localized.jellybotProviderManuallyDisabled,
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(IconsaxPlusLinear.edit_2),
                  onPressed: () => _edit(context, ref),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotProviderEnabled),
                    value: provider.enabled ?? false,
                    onChanged: (value) => _update(context, ref, UpdateProviderRequest(enabled: value)),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.localized.jellybotProviderSearchEnabled),
                    value: provider.searchEnabled ?? false,
                    onChanged: (value) => _update(context, ref, UpdateProviderRequest(searchEnabled: value)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Route + tile**

- `auto_router.dart`: add `AutoRoute(page: JellybotProvidersRoute.page, path: 'providers'),` after the `api-clients` entry.
- `jellybot_screen.dart`: inside the same `if (isAdmin)`-gated group as Task 10's tile, add:

```dart
              SettingsListTile(
                label: Text(context.localized.jellybotProvidersManage),
                subLabel: Text(context.localized.jellybotProvidersManageDesc),
                selected: containsRoute(const JellybotProvidersRoute()),
                icon: IconsaxPlusLinear.global_edit,
                onTap: () => navigateTo(const JellybotProvidersRoute()),
              ),
```

(To gate multiple tiles cleanly, wrap them in a collection-if with a list spread: `if (isAdmin) ...[tileA, tileB, tileC]` — where `isAdmin` is read once at the top of `_leftPane` via `ref.watch`.)

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Analyze, format, commit**

```bash
flutter analyze
dart format --line-length 120 lib/screens/jellybot/ lib/routes/auto_router.dart
git add lib/screens/jellybot/ lib/routes/ lib/l10n/
git commit -m "feat(jellybot): providers management page"
```

---

## Task 12: Source Live TV page + route + tile

**Files:**
- Create: `lib/screens/jellybot/live_tv_source_page.dart`
- Modify: `lib/routes/auto_router.dart`, `lib/screens/jellybot/jellybot_screen.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`

**Interfaces:**
- Consumes: `jellybotLiveTvSourceProvider`, `jellybotLiveTvCountriesProvider` (Task 9), `UpdateLiveTvSourceRequest`, `apiSettingsLiveTvSourcePut`, job trigger `apiJobsPost(body: TriggerJobRequest(jobType: 'LiveTvChannelsJob'))` (same as `admin_page.dart:34-36,72`).
- Produces: `JellybotLiveTvSourceRoute` (path `live-tv-source`).

- [ ] **Step 1: Add l10n keys** (both ARBs)

EN: `"jellybotLiveTvSource": "Live TV Source"`, `"jellybotLiveTvSourceDesc": "Channel source URL and countries"`, `"jellybotLiveTvSourceUrl": "Source URL"`, `"jellybotLiveTvSourceCountries": "Countries"`, `"jellybotLiveTvSourceFromConfig": "Values come from the config file — nothing saved yet"`, `"jellybotLiveTvSourceNoCountries": "No countries available — the source may be unreachable"`, `"jellybotLiveTvSourceSaved": "Saved — applied at the next Live TV job run"`, `"jellybotLiveTvRunJob": "Run job now"`.

FR: `"jellybotLiveTvSource": "Source Live TV"`, `"jellybotLiveTvSourceDesc": "URL de la source des chaînes et pays"`, `"jellybotLiveTvSourceUrl": "URL de la source"`, `"jellybotLiveTvSourceCountries": "Pays"`, `"jellybotLiveTvSourceFromConfig": "Valeurs issues du fichier de configuration — rien d'enregistré"`, `"jellybotLiveTvSourceNoCountries": "Aucun pays disponible — la source est peut-être injoignable"`, `"jellybotLiveTvSourceSaved": "Enregistré — appliqué à la prochaine exécution de la tâche Live TV"`, `"jellybotLiveTvRunJob": "Lancer la tâche"`.

Run: `flutter gen-l10n`.

- [ ] **Step 2: Implement the page**

```dart
// lib/screens/jellybot/live_tv_source_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_admin_provider.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/screens/jellybot/widgets/search_error_state.dart';
import 'package:fladder/screens/shared/fladder_notification_overlay.dart';
import 'package:fladder/screens/shared/nested_scaffold.dart';
import 'package:fladder/util/adaptive_layout/adaptive_layout.dart';
import 'package:fladder/util/localization_helper.dart';

@RoutePage()
class JellybotLiveTvSourcePage extends ConsumerStatefulWidget {
  const JellybotLiveTvSourcePage({super.key});

  @override
  ConsumerState<JellybotLiveTvSourcePage> createState() => _JellybotLiveTvSourcePageState();
}

class _JellybotLiveTvSourcePageState extends ConsumerState<JellybotLiveTvSourcePage> {
  final _urlController = TextEditingController();
  Set<String> _selectedCountries = {};
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _seedFrom(LiveTvSourceResult source) {
    if (_seeded) {
      return;
    }
    _seeded = true;
    _urlController.text = source.baseUrl ?? '';
    _selectedCountries = {...(source.countries ?? const <String>[])};
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final api = ref.read(jellybotApiProvider);
    final response = await api.apiSettingsLiveTvSourcePut(
      body: UpdateLiveTvSourceRequest(
        baseUrl: _urlController.text.trim(),
        countries: _selectedCountries.toList(),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (response.isSuccessful) {
      _seeded = false;
      ref.invalidate(jellybotLiveTvSourceProvider);
      ref.invalidate(jellybotLiveTvCountriesProvider);
      FladderSnack.show(
        context.localized.jellybotLiveTvSourceSaved,
        context: context,
        actionLabel: context.localized.jellybotLiveTvRunJob,
        onActionPressed: () => ref
            .read(jellybotApiProvider)
            .apiJobsPost(body: const TriggerJobRequest(jobType: 'LiveTvChannelsJob')),
      );
    } else {
      FladderSnack.show('HTTP ${response.statusCode}', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(userProvider.select((value) => value?.policy?.isAdministrator ?? false));
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.lock, size: 64, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 16),
              Text(context.localized.adminOnly, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final sourceAsync = ref.watch(jellybotLiveTvSourceProvider);
    final countriesAsync = ref.watch(jellybotLiveTvCountriesProvider);
    final theme = Theme.of(context);

    return NestedScaffold(
      body: Padding(
        padding: EdgeInsets.only(left: AdaptiveLayout.of(context).sideBarWidth),
        child: Scaffold(
          backgroundColor: null,
          body: sourceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => SearchErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(jellybotLiveTvSourceProvider),
            ),
            data: (source) {
              _seedFrom(source);
              final countries = countriesAsync.valueOrNull ?? const <String>[];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.router.maybePop(),
                      ),
                      const Icon(IconsaxPlusLinear.monitor),
                      const SizedBox(width: 12),
                      Text(context.localized.jellybotLiveTvSource, style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (source.fromDatabase == false)
                    Card(
                      color: theme.colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(IconsaxPlusLinear.info_circle, color: theme.colorScheme.onTertiaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.localized.jellybotLiveTvSourceFromConfig,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: context.localized.jellybotLiveTvSourceUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.localized.jellybotLiveTvSourceCountries, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (countries.isEmpty)
                    Text(
                      context.localized.jellybotLiveTvSourceNoCountries,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: countries
                          .map(
                            (country) => FilterChip(
                              label: Text(country.toUpperCase()),
                              selected: _selectedCountries.contains(country),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _selectedCountries.add(country);
                                } else {
                                  _selectedCountries.remove(country);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(IconsaxPlusLinear.tick_circle),
                      label: Text(context.localized.save),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

> If the generated `TriggerJobRequest` constructor is not `const`, drop the `const` keyword at the call site.

- [ ] **Step 3: Route + tile**

- `auto_router.dart`: add `AutoRoute(page: JellybotLiveTvSourceRoute.page, path: 'live-tv-source'),` after the `providers` entry.
- `jellybot_screen.dart`: third tile in the admin-gated spread:

```dart
              SettingsListTile(
                label: Text(context.localized.jellybotLiveTvSource),
                subLabel: Text(context.localized.jellybotLiveTvSourceDesc),
                selected: containsRoute(const JellybotLiveTvSourceRoute()),
                icon: IconsaxPlusLinear.monitor,
                onTap: () => navigateTo(const JellybotLiveTvSourceRoute()),
              ),
```

Run: `flutter pub run build_runner build --delete-conflicting-outputs`

- [ ] **Step 4: Analyze, format, commit**

```bash
flutter analyze
dart format --line-length 120 lib/screens/jellybot/ lib/routes/auto_router.dart
git add lib/screens/jellybot/ lib/routes/ lib/l10n/
git commit -m "feat(jellybot): Live TV source settings page"
```

---

## Task 13: `LiveTvChannelCategory.entertainment`

**Files:**
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`
- Modify: `lib/screens/video_player/components/live_tv_channel_browser.dart:235-242`
- Modify: `lib/screens/live_tv/live_tv_channels_screen.dart:174-181,287-294`

- [ ] **Step 1: Add the key**

EN: `"categoryEntertainment": "Entertainment"` — FR: `"categoryEntertainment": "Divertissement"` (next to the existing `categoryOther` keys, with `"@categoryEntertainment": {}` lines). Run `flutter gen-l10n`.

- [ ] **Step 2: Extend the switches**

In both label switches (`live_tv_channel_browser.dart:235-242` and `live_tv_channels_screen.dart:287-294`) add before the `other` arm:

```dart
      LiveTvChannelCategory.entertainment => context.localized.categoryEntertainment,
```

In the ordered category list at `live_tv_channels_screen.dart:174-181` add `LiveTvChannelCategory.entertainment,` before `LiveTvChannelCategory.other,`.

> The regenerated enum (Task 1) already contains `entertainment` — the analyzer's exhaustiveness check is what would have caught this; verify no `switch` warnings remain.

- [ ] **Step 3: Analyze, format, commit**

```bash
flutter analyze
dart format --line-length 120 lib/screens/video_player/components/live_tv_channel_browser.dart lib/screens/live_tv/live_tv_channels_screen.dart
git add lib/screens/ lib/l10n/
git commit -m "feat(jellybot): Entertainment live TV category"
```

---

## Task 14: Final verification + manual smoke checklist

- [ ] **Step 1: Full static + test pass**

```bash
flutter analyze
flutter test test/models/jellybot/ test/providers/jellybot/ test/providers/syncplay/
dart format --line-length 120 ./lib/ --set-exit-if-changed
```
Expected: analyze 0 issues; all tests pass; format exits 0. (`widget_test.dart` is the broken starter template — do not run the full `flutter test` suite; see CLAUDE.md.)

- [ ] **Step 2: Manual smoke checklist (dev instance + jellybot.maktep.fr)**

Run the app (`flutter run -d chrome` or the existing dev web server), log in, open Jellybot, verify each:

- [ ] Add a movie that is NOT in the library: sheet opens instantly with spinner → confirm step (title editable) → Confirmer → success tick → sheet auto-closes; the card now shows the "already added" badge without a page refresh; the link appears in Liens de téléchargement.
- [ ] Add a show requiring season selection: season list renders in-sheet, selection continues to confirm; committed link carries the season.
- [ ] Already-added item: card shows badge + tick (no server roundtrip on tap — snackbar only). Force the 409 path via a second client/device if available.
- [ ] Duplicate detection: add an item the server matches to existing Jellyfin media — duplicate step shows both titles/years; "C'est le même" navigates to the media; "Continuer l'ajout" reaches confirm.
- [ ] 410 expiry: open a confirm step, wait past the server's preview TTL, press Confirmer — flow re-extracts once and returns to confirm; a second immediate expiry shows the expired error with Réessayer.
- [ ] Extraction failure: add a link from a provider the server can't extract (or briefly break the provider) — error step shows the server detail, Réessayer works, sheet close leaves the page healthy (navigation still works — regression check for the frozen-pane bug).
- [ ] Cards show year/quality/language/score badges on Wawacity results (server now returns clean titles + fields).
- [ ] Clients API page: create (with API key), edit leaving the key blank (key preserved — `hasApiKey` hint shows), toggle enabled, delete with confirmation. Non-admin account sees the lock screen and no tile.
- [ ] Fournisseurs page: rename a provider, toggle searchEnabled off → provider disappears from the search dropdown immediately.
- [ ] Source Live TV: current URL + countries load; when nothing was ever saved the config-file banner shows; save → snackbar with "Lancer la tâche" action; job appears in Admin > Tâches en cours when triggered.
- [ ] Live TV browser shows the Divertissement category when the source exposes it.
- [ ] All feedback renders as FladderSnack overlay notifications (top-center on phone, top-right on desktop); no raw full-width bottom `SnackBar` remains anywhere in the section.
- [ ] Liens de téléchargement, Téléchargements and Administration pages each show a loading indicator while fetching, their empty state when the server returns nothing, and a retryable error state when the Jellybot URL is unreachable (test by pointing the server URL at a bogus host in Administration, then resetting it).

- [ ] **Step 3: Update the spec status line**

In `docs/superpowers/specs/2026-07-03-jellybot-v2-api-ui-feedback-design.md`, change `**Status:**` to `Implemented (see docs/superpowers/plans/2026-07-03-jellybot-v2-api-ui-feedback.md)`.

```bash
git add docs/superpowers/specs/2026-07-03-jellybot-v2-api-ui-feedback-design.md
git commit -m "docs(jellybot): mark v2 spec implemented"
```
