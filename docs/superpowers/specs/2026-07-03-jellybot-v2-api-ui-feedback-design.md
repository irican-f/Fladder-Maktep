# Jellybot v2 — API Adaptation, Unified Add Flow & Section Polish

**Date:** 2026-07-03
**Status:** Approved design, pending implementation plan
**Server prerequisite:** DEPLOYED — jellybot.maktep.fr now serves the updated API (addToken flow, enriched search metadata, new admin endpoints).

## Context

The Jellybot server API changed in breaking and additive ways, and a live UX review
of the current client (Flutter web, `http://localhost:52847`) surfaced concrete
feedback failures. This spec covers adapting Fladder to the new API and overhauling
the jellybot section's UI/user feedback.

### API changes (local `swagger/jellybot.json` vs live spec)

**Breaking — add-link flow is now preview-then-commit:**
- `POST /api/crawl-links` extracts WITHOUT persisting and returns an `addToken`
  in `ExtractMediaResponse`.
- `POST /api/crawl-links/select-season` previews (no persist), also returns `addToken`.
- `POST /api/crawl-links/confirm-add` commits; `ExtractMediaConfirmationRequest`
  lost `crawlLinkId` and gained `addToken`.
- New status codes: **409** "a link for this URL is already added" (on add,
  select-season, confirm-add); **410** "preview expired or token already used"
  (on confirm-add). **400** now strictly means provider unsupported / extraction failed.
- Client-side cleanup deletes on cancel are obsolete (nothing persisted until commit).

**Additive:**
- `ProviderSearchItemDto` gained `year` (int?) and `score` (double?, 0..1), and the
  server now populates `quality`/`language` and returns clean titles for all
  providers (Wawacity previously embedded metadata in the title).
- API client management: `GET/POST /api/api-clients`, `PUT/DELETE /api/api-clients/{id}`
  (`ApiClientDto`, `CreateApiClientRequest`, `UpdateApiClientRequest`; secrets are
  write-only — `hasApiKey`/`hasPassword` booleans on the DTO).
- Provider management: `GET /api/providers/all`, `PUT /api/providers/{providerId}`
  (`UpdateProviderRequest`: displayName, url, enabled, searchEnabled, isManuallyDisabled).
- Live TV source settings: `GET/PUT /api/settings/live-tv-source`
  (`LiveTvSourceResult` incl. `fromDatabase` flag, `UpdateLiveTvSourceRequest`),
  `GET /api/settings/live-tv-source/countries`.
- `LiveTvChannelCategory` gained `Entertainment` (8).
- Removed: `GET /api/iptv/atlas-pro` (unused by Fladder — no impact).

### UX failures observed live (2026-07-03 session)

1. Confirm-add sends the removed `crawlLinkId`, never checks the response, and shows
   a success snackbar while the server rejects the commit (user-confirmed via devtools).
2. HTTP 400 is treated as "already added"; under the new API that response means
   extraction failure — duplicates (409) and failures are conflated.
3. Zero feedback during multi-second extraction; one hung extract froze the right
   pane (tab navigation dead until page reload).
4. The "already added" badge never renders: URL matching between search-result `url`
   and stored `fullUrl` fails (providers rotate domains), even though the client
   fetches the full crawl-links collection — 12 sequential `GET /api/crawl-links`
   roundtrips (~2,400 items) — to build that set.
5. Duplicate dialog gives no visual context (matched "Tous les chemins mènent à Rome"
   against *Fast & Furious 6 (2013)* with no posters) and its three buttons have
   inverted emphasis.
6. Result cards lack metadata (no year/quality/language for some providers) — now
   fixed server-side; the client must render the enriched fields.
7. Raw `ScaffoldMessenger` snackbars (full-width, bottom-left, easy to miss) instead
   of the project's `FladderSnack` overlay notifications
   (`lib/screens/shared/fladder_notification_overlay.dart` — CLAUDE.md's mention of
   `fladderSnackbar` is outdated); at least one hardcoded English label
   ("Confirm") in the French locale.

## Design

### 1. API contract update

- Overwrite `swagger/jellybot.json` with the live spec
  (`https://jellybot.maktep.fr/swagger/v1/swagger.json`).
- Regenerate `lib/jellyfin/jellybot.*` via
  `flutter pub run build_runner build --delete-conflicting-outputs`.
- Compilation will fail at the old `crawlLinkId:` call site — fixed by section 2.

### 2. Unified add flow (state machine + adaptive sheet)

**State.** `lib/models/jellybot/jellybot_add_flow_state.dart` (Freezed):

```
enum AddFlowStep { extracting, seasonSelection, duplicateCheck, confirming, committing, success, failure }
enum AddFlowFailure { alreadyAdded, previewExpired, extractionFailed, network }

JellybotAddFlowState(
  ProviderSearchItemDto item,      // source card
  MediaCategory category,
  AddFlowStep step,
  String? addToken,
  int? availableSeasons, int? selectedSeason,
  CrawlLinkDto? previewLink,       // parsed from ExtractMediaResponse.crawlLink
  MediaSearchResultDto? existingMedia,
  String? mediaTitle,              // editable name, seeded from previewLink.name
  AddFlowFailure? failure,
  String? failureDetail,           // ProblemDetails.detail when present
)
```

**Controller.** `lib/providers/jellybot_add_flow_provider.dart` —
`@riverpod class JellybotAddFlowController` exposing:
`start(item, category)`, `selectSeason(int)`, `resolveDuplicate({required bool sameMedia})`,
`confirm(String name)`, `retry()`, `cancel()`.

Transition rules:
- `start` → POST /crawl-links → on `requiresSeasonSelection` → `seasonSelection`;
  on `mediaExistsOnServer && existingMedia != null` → `duplicateCheck`; else `confirming`.
- `selectSeason` → POST /select-season → same branching (duplicate check → confirm).
- `resolveDuplicate(sameMedia: true)` → terminal: close flow, navigate to the existing
  media's `DetailsRoute` (current behaviour, kept).
- `confirm` → POST /confirm-add with `addToken` + edited title → **response checked**:
  - 200 → `success`; invalidate `addedCrawlLinkUrlsProvider`.
  - 409 → `failure(alreadyAdded)`; also mark the item's URL in the local added-set.
  - 410 → transparently re-run extraction ONCE to get a fresh token, then return to
    `confirming`; a second 410 → `failure(previewExpired)` with retry button.
  - other → `failure(network)` with detail.
- Extraction/season errors: 409 → `alreadyAdded`; 400 → `extractionFailed` with
  `ProblemDetails.detail`; timeout/other → `network`. All failures land in-sheet
  with a retry affordance — never a silent stall.
- `cancel` at any step just resets state. No server cleanup (`_deleteCrawlLink` and
  its call sites are deleted).

**Sheet.** `lib/screens/jellybot/widgets/add_flow_sheet.dart` — opens immediately on
"+" (adaptive: `showDialog` on desktop/tablet, `showModalBottomSheet` on phones,
branched via `AdaptiveLayout`). Thin `ConsumerWidget` over the controller:

- Header: thumbnail (with `errorBuilder`), clean title, badges (quality, language,
  year, season) from the enriched DTO.
- Step body swaps by `AddFlowStep` (AnimatedSwitcher, 150–300 ms):
  - `extracting`/`committing`: progress indicator + step label
    ("Extraction des informations…" / "Ajout en cours…").
  - `seasonSelection`: in-sheet season list (replaces `SeasonPickerDialog`).
  - `duplicateCheck`: side-by-side comparison — existing Jellyfin media (poster,
    title, year, "Voir sur Jellyfin" link) vs the link being added (thumb, title,
    year). Primary button: "Continuer l'ajout" (it's different); secondary:
    "C'est le même" (closes flow, navigates to existing); tertiary: Annuler.
    Replaces `ExistingMediaDialog`.
  - `confirming`: metadata recap + editable name field + "Confirmer" filled button.
    Replaces `ConfirmCrawlLinkDialog`.
  - `success`: check icon + "Lien ajouté" → auto-close after ~1.5 s.
  - `failure`: per-kind icon/message (`alreadyAdded`: info tone; `previewExpired`:
    warning + "Réessayer"; `extractionFailed`: `SelectableText.rich` red with server
    detail + "Réessayer"; `network`: retry). Escape route (close) always visible.
- Old dialog files (`season_picker_dialog.dart`, `existing_media_dialog.dart`,
  `confirm_crawl_link_dialog.dart`) are deleted; their content lives as private
  step widgets in the sheet's file (or sibling `add_flow_steps/` files if large).

### 3. Result cards enrichment + already-added fix

- `SearchResultCard` renders the enriched fields: clean title, `year` chip,
  `QualityBadge`, `LanguageBadge`, season chip, provider chip, and a subtle match
  chip when `score != null` (e.g. "87 %"). Existing badge widgets are reused.
- **URL matching fix** — `lib/models/jellybot/jellybot_url_matcher.dart`, pure
  function: normalize URLs to a comparable key (strip scheme/host/trailing slash,
  lowercase, decode) because providers rotate domains. The added-set stores
  normalized keys from `CrawlLinkDto.relativeUrl` (fallback: path of `fullUrl`);
  cards test the normalized path of `item.url`.
- Already-added cards: `AlreadyAddedBadge` over the thumbnail (existing widget,
  finally functional) + the "+" IconButton replaced by a tick with tooltip;
  tapping shows the info snackbar without any server roundtrip.
- `addedCrawlLinkUrlsProvider` performance: fetch page 0, read `totalPages`, then
  fetch remaining pages with `Future.wait` (concurrent instead of 12 sequential
  roundtrips). Stays `keepAlive`, invalidated after each successful commit.

### 4. New admin pages (left-pane entries)

Three new routed pages beside Search/Links/Downloads/Admin, using the same
admin gating as `JellybotAdminPage` and the `*_page.dart` naming required by
`build.yaml` for auto_route generation. New tiles in `jellybot_screen.dart`'s
left pane (hidden for non-admins), new routes in `lib/routes/auto_router.dart`.

**4a. Clients API — `lib/screens/jellybot/api_clients_page.dart`**
- Provider: `jellybotApiClientsProvider` (list, `AsyncValue`), mutations through the
  controller (`create/update/delete` → invalidate on success).
- List of cards: name, type, `isEnabled` switch (inline PUT), `isActive` status dot,
  priority, torrent-client icon, subscription expiry (warning tone when < 7 days,
  error tone when expired).
- Create/edit form dialog: required fields (name, type) up front; advanced fields
  (baseUrl, priority, maxConcurrentRequests, rateLimitPerMinute, isTorrentClient,
  subscriptionExpiresAt) behind a collapsed "Avancé" section (progressive
  disclosure). Secrets (apiKey, password) write-only: placeholder "laisser vide
  pour conserver", `hasApiKey`/`hasPassword` shown as state chips.
- Delete: confirmation dialog, destructive styling, spatially separated from
  the primary action.
- 400 duplicate-name error surfaced inline under the name field.

**4b. Fournisseurs — `lib/screens/jellybot/providers_page.dart`**
- Provider: `jellybotAllProvidersProvider` via `GET /api/providers/all`.
- List: display name, URL, status chips; toggles for `enabled` and `searchEnabled`;
  `isManuallyDisabled` indicator; edit dialog for displayName/url.
- Each PUT invalidates both this list and `jellybotProvidersProvider` so the
  search page's provider dropdown updates immediately.

**4c. Source Live TV — `lib/screens/jellybot/live_tv_source_page.dart`**
- Providers: `jellybotLiveTvSourceProvider` (GET) + `jellybotLiveTvCountriesProvider`.
- Shows `baseUrl` field, "valeurs par défaut (fichier de config)" banner when
  `fromDatabase == false`, and a country multi-select (FilterChips) fed by the
  countries endpoint — with an explicit empty state when the source is unreachable
  (endpoint returns an empty list).
- Save via PUT; success snackbar includes the hint that changes apply at the next
  Live TV job run, with an inline action to trigger the `Live TV Channels` job
  (same call the Admin page uses).

### 5. Section-wide feedback polish

- Replace every raw `ScaffoldMessenger.of(context).showSnackBar` in
  `lib/screens/jellybot/**` with `FladderSnack.show(message, context: context)`
  (the app-wide convention from `lib/screens/shared/fladder_notification_overlay.dart`;
  it supports `actionLabel`/`onActionPressed` for snackbar actions).
- Distinct localized messages per add-flow outcome (added / already added /
  preview expired / extraction failed / network).
- Fix the hardcoded "Confirm" label; audit the jellybot section for other
  non-localized strings.
- New l10n keys go to `app_en.arb` and `app_fr.arb` only (Weblate handles the rest).
- `LiveTvChannelCategory.entertainment`: add `categoryEntertainment` key and extend
  the exhaustive switches in `live_tv_channel_browser.dart` and
  `live_tv_channels_screen.dart`.
- Verify links/downloads/admin pages keep proper loading/empty/error states; the
  frozen-pane failure mode disappears with the add-flow rework (state in provider,
  UI never awaits a bare Future without rendering progress).

### 6. Testing

Per project convention (no HTTP mocking; pure logic only — see `test/providers/`):

- `test/providers/jellybot/jellybot_add_flow_state_test.dart` — state-machine
  transitions that don't require HTTP: initial state, `selectSeason` stores the
  season, `resolveDuplicate` outcomes, failure-kind mapping from status codes
  (pure `AddFlowFailure.fromStatus(int)` helper), `cancel` resets.
- `test/models/jellybot/jellybot_url_matcher_test.dart` — table-driven: same path
  across different domains matches; trailing slash/case/encoding normalization;
  fullUrl fallback.
- Existing `jellybot_search_state_test.dart` continues to pass.
- Manual smoke checklist (end of implementation plan): add a movie; add a show
  with season selection; 409 duplicate on extract and on confirm; 410 expiry
  (long-idle confirm); API client create/edit-with-blank-secret/delete; provider
  rename + search-enabled toggle reflected in search dropdown; Live TV source save
  + countries list; Entertainment category renders in Live TV browser.

## Out of scope

- Server-side search relevance (e.g. "the matrix" returning unrelated titles) —
  Jellybot server concern.
- Login/auth screens, non-jellybot sections.
- Deep-link restoration into jellybot sub-tabs (redirects to search today; minor,
  can be a follow-up).

## Rollout notes

- Single branch (`maktep` workflow); regenerate swagger first, then land the add
  flow, then cards, then admin pages, then polish. CI: `flutter analyze`
  (fatal-infos, line length 120) and `dart format --line-length 120`.
- Do not commit generated-file noise beyond the jellybot swagger regen.
