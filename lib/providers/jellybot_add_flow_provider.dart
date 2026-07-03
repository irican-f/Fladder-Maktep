import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';
import 'package:fladder/models/jellybot/jellybot_problem_details.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/jellybot_search_provider.dart';
import 'package:fladder/providers/user_provider.dart';

part 'jellybot_add_flow_provider.g.dart';

/// Drives the add-link flow: extract → (season) → (duplicate) → confirm →
/// commit. State is null when no flow is active. The sheet
/// (`AddFlowSheet`) is a thin consumer of this notifier.
///
/// keepAlive because the flow is started via `ref.read` before the sheet
/// mounts — with autoDispose the provider would be disposed in that
/// listener gap. Lifecycle is managed manually: `showAddFlowSheet` calls
/// `cancel()` when the sheet closes.
@Riverpod(keepAlive: true)
class JellybotAddFlow extends _$JellybotAddFlow {
  @override
  JellybotAddFlowState? build() => null;

  /// Test hook — lets pure-logic tests seed a state without HTTP.
  @visibleForTesting
  void debugSetState(JellybotAddFlowState? value) => state = value;

  Future<void> start(ProviderSearchItemDto item, MediaCategory category) async {
    final snapshot = JellybotAddFlowState(item: item, category: category);
    state = snapshot;
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
      _handlePreviewResponse(response, expected: snapshot);
    } catch (e) {
      if (!identical(state, snapshot)) {
        return;
      }
      log('Add-flow extraction failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  Future<void> selectSeason(int season) async {
    final s = state;
    if (s == null || s.step != AddFlowStep.seasonSelection) {
      return;
    }
    final snapshot = s.copyWith(step: AddFlowStep.extracting, selectedSeason: season);
    state = snapshot;
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
      _handlePreviewResponse(response, expected: snapshot);
    } catch (e) {
      if (!identical(state, snapshot)) {
        return;
      }
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
    final snapshot = s.copyWith(step: AddFlowStep.committing, mediaTitle: name);
    state = snapshot;
    final api = ref.read(jellybotApiProvider);
    try {
      final response = await api.apiCrawlLinksConfirmAddPost(
        body: ExtractMediaConfirmationRequest(
          addToken: s.addToken,
          mediaTitle: name.trim() == (s.previewLink?.name ?? '').trim() ? null : name.trim(),
        ),
      );
      if (!identical(state, snapshot)) {
        // Flow was cancelled or restarted for another item while committing.
        return;
      }
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
        _fail(addFlowFailureFromStatus(response.statusCode), problemDetailFromResponse(response));
        return;
      }
      ref.invalidate(addedCrawlLinkUrlsProvider);
      state = snapshot.copyWith(step: AddFlowStep.success);
    } catch (e) {
      if (!identical(state, snapshot)) {
        return;
      }
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
    final snapshot = s.copyWith(
      step: AddFlowStep.extracting,
      hasRetriedExpiredToken: true,
      mediaTitle: name,
    );
    state = snapshot;
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
      _handlePreviewResponse(response, keepTitle: name, skipDuplicateCheck: true, expected: snapshot);
    } catch (e) {
      if (!identical(state, snapshot)) {
        return;
      }
      log('Add-flow re-extraction failed', error: e);
      _fail(AddFlowFailure.network, e.toString());
    }
  }

  void _handlePreviewResponse(
    Response<ExtractMediaResponse> response, {
    required JellybotAddFlowState expected,
    String? keepTitle,
    bool skipDuplicateCheck = false,
  }) {
    final s = state;
    if (s == null || !identical(s, expected)) {
      return; // Flow was cancelled or restarted while the request was in flight.
    }
    if (!response.isSuccessful || response.body == null) {
      if (response.statusCode == 409) {
        ref.invalidate(addedCrawlLinkUrlsProvider);
      }
      _fail(addFlowFailureFromStatus(response.statusCode), problemDetailFromResponse(response));
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
}
