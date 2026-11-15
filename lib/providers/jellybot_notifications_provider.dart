import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/providers/jellybot_api_provider.dart';
import 'package:fladder/providers/shared_provider.dart';
import 'package:fladder/providers/update_notifications_provider.dart';
import 'package:fladder/providers/user_provider.dart';
import 'package:fladder/util/jellybot_ready_notifications.dart';

part 'jellybot_notifications_provider.g.dart';

/// Keeps the account's 401 marker in step with what JellyBot just said about its token: a 401 sets it (polling
/// pauses for a while), any success clears it and brings the background task back. Other failures (503: Jellyfin
/// unreachable) say nothing about the token and leave it alone.
Future<void> _recordJellybotAuth(Ref ref, String? accountId, Response<dynamic> response) async {
  if (accountId == null) {
    return;
  }
  final store = JellybotNotificationStore(ref.read(sharedPreferencesProvider));
  if (response.statusCode == 401) {
    await store.markUnsupported(accountId, DateTime.now());
  } else if (response.isSuccessful && await store.clearUnsupported(accountId)) {
    await ref.read(updateNotificationsProvider).registerBackgroundTask();
  }
}

bool _jellybotConfigured(Ref ref) => configuredJellybotBaseUrl(ref.read(sharedPreferencesProvider)) != null;

/// The signed-in user's JellyBot notification preferences; null when JellyBot is not configured, unreachable, or
/// does not know this account's server (401).
@riverpod
class JellybotNotificationPreferences extends _$JellybotNotificationPreferences {
  @override
  Future<NotificationPreferencesDto?> build() async {
    // Watched before any early return, so setting the JellyBot URL later rebuilds this.
    final api = ref.watch(jellybotApiProvider);
    final account = ref.watch(userProvider.select((u) => u == null ? null : (id: u.id, token: u.credentials.token)));
    if (account == null || !_jellybotConfigured(ref)) {
      return null;
    }
    final response = await api.apiNotificationsPreferencesGet(xJellyfinToken: account.token);
    await _recordJellybotAuth(ref, account.id, response);
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      return null;
    }
    await JellybotNotificationStore(
      ref.read(sharedPreferencesProvider),
    ).setCachedEnabled(account.id, body.enabled ?? true);
    return body;
  }

  /// Saves both values; returns false (and restores the previous state) when JellyBot refused.
  Future<bool> save({required bool enabled, required bool onlyMine}) async {
    final account = ref.read(userProvider);
    final previous = state.value;
    if (account == null || previous == null) {
      return false;
    }
    final next = NotificationPreferencesDto(enabled: enabled, onlyMine: onlyMine);
    state = AsyncData(next);
    try {
      final response = await ref
          .read(jellybotApiProvider)
          .apiNotificationsPreferencesPut(xJellyfinToken: account.credentials.token, body: next);
      await _recordJellybotAuth(ref, account.id, response);
      if (!response.isSuccessful) {
        state = AsyncData(previous);
        return false;
      }
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
    await JellybotNotificationStore(ref.read(sharedPreferencesProvider)).setCachedEnabled(account.id, enabled);
    // The master value gates the background task, which registers or unregisters itself from it.
    await ref.read(updateNotificationsProvider).registerBackgroundTask();
    return true;
  }
}

/// Whether the user follows [seriesId] and whether JellyBot tracks it (drives the bell). Null = no bell.
/// Read it with [jellybotSeriesKey] so dashed and undashed ids share one entry.
///
/// Kept alive so the synchronous show context menu can read a value fetched earlier.
@Riverpod(keepAlive: true)
class JellybotSeriesSubscription extends _$JellybotSeriesSubscription {
  @override
  Future<SeriesSubscriptionDto?> build(String seriesId) async {
    final api = ref.watch(jellybotApiProvider);
    final account = ref.watch(userProvider.select((u) => u == null ? null : (id: u.id, token: u.credentials.token)));
    if (account == null || seriesId.isEmpty || !_jellybotConfigured(ref)) {
      return null;
    }
    final response = await api.apiNotificationsSubscriptionsSeriesIdGet(
      xJellyfinToken: account.token,
      seriesId: seriesId,
    );
    await _recordJellybotAuth(ref, account.id, response);
    return response.isSuccessful ? response.body : null;
  }

  /// Flips the subscription; returns the new value, or null when it failed.
  Future<bool?> toggle() async {
    final current = state.value;
    final account = ref.read(userProvider);
    if (current == null || account == null) {
      return null;
    }
    final token = account.credentials.token;
    final subscribe = !(current.subscribed ?? false);
    final api = ref.read(jellybotApiProvider);
    try {
      final response = subscribe
          ? await api.apiNotificationsSubscriptionsSeriesIdPut(xJellyfinToken: token, seriesId: seriesId)
          : await api.apiNotificationsSubscriptionsSeriesIdDelete(xJellyfinToken: token, seriesId: seriesId);
      await _recordJellybotAuth(ref, account.id, response);
      if (!response.isSuccessful) {
        return null;
      }
    } catch (_) {
      return null;
    }
    state = AsyncData(SeriesSubscriptionDto(subscribed: subscribe, tracked: current.tracked));
    return subscribe;
  }
}

/// How many JellyBot events the signed-in user hasn't read, from the newest history page (so it caps at a page).
/// Drives the JellyBot tab dot and the menu count. Refreshes whenever a check publishes to [notificationsProvider]
/// (app open, desktop timer, the Workmanager port) and after marking read. No system-notification gate, so it
/// works on web.
@Riverpod(keepAlive: true)
class JellybotUnreadNotifications extends _$JellybotUnreadNotifications {
  @override
  Future<int?> build() async {
    ref.listen(notificationsProvider, (_, _) => ref.invalidateSelf());
    final api = ref.watch(jellybotApiProvider);
    final account = ref.watch(userProvider.select((u) => u == null ? null : (id: u.id, token: u.credentials.token)));
    if (account == null || !_jellybotConfigured(ref)) {
      return null;
    }
    final response = await api.apiNotificationsHistoryGet(
      xJellyfinToken: account.token,
      limit: jellybotHistoryPageSize,
    );
    await _recordJellybotAuth(ref, account.id, response);
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      return null;
    }
    return jellybotUnreadCount(body.items ?? const [], body.lastReadId);
  }

  /// Marks read up to [newestShown] when it is past JellyBot's [lastReadId]. Called once per page open.
  Future<void> markRead(int? newestShown, int? lastReadId) async {
    final account = ref.read(userProvider);
    if (newestShown == null || (lastReadId != null && newestShown <= lastReadId) || account == null) {
      return;
    }
    try {
      final response = await ref
          .read(jellybotApiProvider)
          .apiNotificationsReadPut(
            xJellyfinToken: account.credentials.token,
            body: MarkNotificationsReadRequest(lastReadId: newestShown),
          );
      await _recordJellybotAuth(ref, account.id, response);
      if (response.isSuccessful) {
        state = const AsyncData(0);
      }
    } catch (_) {
      // Stays unread; the next open retries.
    }
  }
}

const jellybotHistoryPageSize = 50;

class JellybotHistoryState {
  const JellybotHistoryState({required this.items, this.lastReadId, this.hasMore = true, this.loadingMore = false});

  /// Newest first.
  final List<ReadyNotificationDto> items;

  /// The read marker as it was when the page opened, so the rows that were new stay highlighted.
  final int? lastReadId;
  final bool hasMore;
  final bool loadingMore;
}

/// The in-app notification list, paged by id. Opening it marks everything shown as read.
@riverpod
class JellybotNotificationHistory extends _$JellybotNotificationHistory {
  @override
  Future<JellybotHistoryState> build() async {
    final page = await _fetch(null);
    final items = page.items ?? const <ReadyNotificationDto>[];
    unawaited(ref.read(jellybotUnreadNotificationsProvider.notifier).markRead(items.firstOrNull?.id, page.lastReadId));
    return JellybotHistoryState(
      items: items,
      lastReadId: page.lastReadId,
      hasMore: items.length >= jellybotHistoryPageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore || current.items.isEmpty) {
      return;
    }
    state = AsyncData(JellybotHistoryState(items: current.items, lastReadId: current.lastReadId, loadingMore: true));
    try {
      final more = (await _fetch(current.items.last.id)).items ?? const <ReadyNotificationDto>[];
      state = AsyncData(
        JellybotHistoryState(
          items: [...current.items, ...more],
          lastReadId: current.lastReadId,
          hasMore: more.length >= jellybotHistoryPageSize,
        ),
      );
    } catch (_) {
      // Keep what we have; scrolling to the end again retries.
      state = AsyncData(current);
    }
  }

  Future<ReadyNotificationHistoryResponse> _fetch(int? beforeId) async {
    final account = ref.read(userProvider);
    if (account == null) {
      throw StateError('Not signed in');
    }
    final response = await ref
        .read(jellybotApiProvider)
        .apiNotificationsHistoryGet(
          xJellyfinToken: account.credentials.token,
          beforeId: beforeId,
          limit: jellybotHistoryPageSize,
        );
    await _recordJellybotAuth(ref, account.id, response);
    final body = response.body;
    if (!response.isSuccessful || body == null) {
      throw StateError('HTTP ${response.statusCode}');
    }
    return body;
  }
}
