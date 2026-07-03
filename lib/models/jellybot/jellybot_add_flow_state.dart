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

@Freezed(copyWith: true)
abstract class JellybotAddFlowState with _$JellybotAddFlowState {
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
