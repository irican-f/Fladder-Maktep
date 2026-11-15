import 'package:shared_preferences/shared_preferences.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart' as dto;
import 'package:fladder/l10n/generated/app_localizations.dart';
import 'package:fladder/models/notification_model.dart';
import 'package:fladder/util/notification_helpers.dart';

/// Page size asked of `GET /api/notifications`; a page this full is truncated (the rest comes next check).
const jellybotFeedLimit = 50;

/// How long a 401 ("token not on JellyBot's Jellyfin server") silences an account before it is tried again.
const jellybotUnsupportedRetry = Duration(hours: 24);

/// Per-account, per-device JellyBot notification state, kept apart from [AccountModel] so the background worker
/// and the main isolate never overwrite each other's copy of the account.
class JellybotNotificationStore {
  const JellybotNotificationStore(this.prefs);

  final SharedPreferences prefs;

  static String _key(String accountId, String field) => 'jellybotReadyNotifications.$accountId.$field';

  /// Last JellyBot event id this device has seen for the account; null = never polled (first run).
  int? cursor(String accountId) => prefs.getInt(_key(accountId, 'cursor'));
  Future<void> setCursor(String accountId, int value) => prefs.setInt(_key(accountId, 'cursor'), value);

  /// Last master toggle value read from or written to JellyBot; null = unknown.
  bool? cachedEnabled(String accountId) => prefs.getBool(_key(accountId, 'enabled'));
  Future<void> setCachedEnabled(String accountId, bool value) => prefs.setBool(_key(accountId, 'enabled'), value);

  /// When JellyBot last answered 401 for this account's token; null = not marked.
  DateTime? unsupportedAt(String accountId) {
    final ms = prefs.getInt(_key(accountId, 'unsupportedAt'));
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markUnsupported(String accountId, DateTime now) =>
      prefs.setInt(_key(accountId, 'unsupportedAt'), now.millisecondsSinceEpoch);

  /// Clears the 401 marker; true when there was one (the caller then re-registers the background task).
  Future<bool> clearUnsupported(String accountId) async {
    if (unsupportedAt(accountId) == null) {
      return false;
    }
    await prefs.remove(_key(accountId, 'unsupportedAt'));
    return true;
  }
}

/// An account is polled when JellyBot is configured, its cached master toggle is on (unknown counts as on: fresh
/// install, the server default) and no 401 marked it within [jellybotUnsupportedRetry].
bool shouldPollJellybot(
  JellybotNotificationStore store,
  String accountId, {
  required bool jellybotConfigured,
  DateTime? now,
}) {
  final unsupportedAt = store.unsupportedAt(accountId);
  return jellybotConfigured &&
      (store.cachedEnabled(accountId) ?? true) &&
      (unsupportedAt == null || !(now ?? DateTime.now()).isBefore(unsupportedAt.add(jellybotUnsupportedRetry)));
}

/// First run ([storedCursor] null) shows nothing and starts from the server's newest id, so a device never dumps
/// history. Later runs show what's past the cursor. A page that isn't full moves the cursor to the newest id
/// overall, so events that only become visible later (only-mine off, master back on, a new subscription) are never
/// announced; a full page moves it to its last item and the rest comes next check.
({List<ReadyNotificationDto> events, int cursor}) applyJellybotResponse(
  int? storedCursor,
  ReadyNotificationsResponse response, {
  int limit = jellybotFeedLimit,
}) {
  final latestId = response.latestId ?? 0;
  if (storedCursor == null) {
    return (events: const [], cursor: latestId);
  }
  final items = response.items ?? const <ReadyNotificationDto>[];
  final events = items.where((e) => (e.id ?? 0) > storedCursor).toList();
  final newestShown = events.fold(storedCursor, (max, e) => (e.id ?? 0) > max ? e.id! : max);
  final truncated = items.length >= limit;
  return (events: events, cursor: truncated || latestId < newestShown ? newestShown : latestId);
}

/// Maps a JellyBot event to a notification whose tap opens the item. Null when the event has no Jellyfin id.
NotificationModel? jellybotNotificationModel(
  ReadyNotificationDto event,
  AppLocalizations l10n, {
  String? userId,
  String? serverId,
}) {
  final itemId = event.jellyfinItemId;
  if (itemId == null || itemId.isEmpty) {
    return null;
  }
  return NotificationModel(
    key: 'jellybot-${event.id}',
    id: itemId,
    title: event.title?.isNotEmpty == true ? event.title! : l10n.unknown,
    subtitle: jellybotKindLine(event, l10n),
    payLoad: NotificationHelpers.buildDetailsDeepLink(itemId, userId: userId, serverId: serverId),
  );
}

/// Jellyfin ids (item and series) JellyBot reported, used to drop the same content from the latest-items batch.
Set<String> jellybotReportedIds(Iterable<ReadyNotificationDto> events) => {
  for (final e in events) ...[e.jellyfinItemId, e.seriesId].nonNulls.where((id) => id.isNotEmpty),
};

/// "JellyBot wins": drops latest items that are, or belong to a series/season, JellyBot already notified about.
List<dto.BaseItemDto> dropJellybotReported(List<dto.BaseItemDto> items, Set<String> reportedIds) {
  if (reportedIds.isEmpty) {
    return items;
  }
  return items
      .where((item) => ![item.id, item.seriesId, item.seasonId, item.parentId].any(reportedIds.contains))
      .toList();
}

/// The provider family key for a series: Jellyfin ids come with or without dashes, in either case.
String jellybotSeriesKey(String seriesId) => seriesId.toLowerCase().replaceAll('-', '');

/// The notification's second line: "Movie ready", "Season 2 complete", "Episodes 3–4".
String jellybotKindLine(ReadyNotificationDto event, AppLocalizations l10n) {
  switch (event.kind) {
    case ReadyNotificationKind.seasoncomplete:
      return event.seasonNumber != null
          ? l10n.jellybotKindSeasonComplete(event.seasonNumber!)
          : l10n.jellybotReadyToWatch;
    case ReadyNotificationKind.newepisodes:
      final episodes = [...?event.episodeNumbers]..sort();
      if (episodes.isEmpty) {
        return l10n.jellybotKindNewEpisodes;
      }
      return l10n.jellybotKindEpisodes(episodes.length, formatEpisodeNumbers(episodes));
    case ReadyNotificationKind.movie:
      return l10n.jellybotKindMovie;
    default:
      return l10n.jellybotReadyToWatch;
  }
}

/// "3", "3–4", "1–3, 7": consecutive numbers collapse into ranges. Expects a sorted list.
String formatEpisodeNumbers(List<int> sorted) {
  final parts = <String>[];
  var start = sorted.first;
  var end = start;
  for (final n in sorted.skip(1)) {
    if (n == end + 1) {
      end = n;
      continue;
    }
    if (n == end) {
      continue;
    }
    parts.add(start == end ? '$start' : '$start–$end');
    start = end = n;
  }
  parts.add(start == end ? '$start' : '$start–$end');
  return parts.join(', ');
}

/// An event is unread when nothing was ever read (null) or its id is past the read marker.
bool isJellybotUnread(ReadyNotificationDto event, int? lastReadId) =>
    lastReadId == null || (event.id ?? 0) > lastReadId;

int jellybotUnreadCount(Iterable<ReadyNotificationDto> events, int? lastReadId) =>
    events.where((e) => isJellybotUnread(e, lastReadId)).length;
