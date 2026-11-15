import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/jellyfin/jellyfin_open_api.swagger.dart' as dto;
import 'package:fladder/l10n/generated/app_localizations.dart';
import 'package:fladder/util/jellybot_ready_notifications.dart';
import 'package:fladder/util/notification_helpers.dart';

ReadyNotificationDto _event(
  int id, {
  ReadyNotificationKind kind = ReadyNotificationKind.movie,
  String? itemId = 'item',
  String? seriesId,
  int? season,
  List<int> episodes = const [],
}) => ReadyNotificationDto(
  id: id,
  kind: kind,
  jellyfinItemId: itemId,
  seriesId: seriesId,
  title: 'Title $id',
  seasonNumber: season,
  episodeNumbers: episodes,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('applyJellybotResponse', () {
    test('first run stores latestId and shows nothing', () {
      final result = applyJellybotResponse(null, ReadyNotificationsResponse(items: [_event(7)], latestId: 42));
      expect(result.events, isEmpty);
      expect(result.cursor, 42);
    });

    test('first run with no events starts at 0 so the next event is not skipped', () {
      final result = applyJellybotResponse(null, const ReadyNotificationsResponse(items: [], latestId: null));
      expect(result.cursor, 0);
    });

    test('later runs show events after the cursor and move it to the newest', () {
      final result = applyJellybotResponse(
        10,
        ReadyNotificationsResponse(items: [_event(11), _event(13)], latestId: 13),
      );
      expect(result.events.map((e) => e.id), [11, 13]);
      expect(result.cursor, 13);
    });

    test('no events keeps the cursor', () {
      final result = applyJellybotResponse(10, const ReadyNotificationsResponse(items: [], latestId: 10));
      expect(result.events, isEmpty);
      expect(result.cursor, 10);
    });

    test('events at or before the cursor are never shown again', () {
      final result = applyJellybotResponse(10, ReadyNotificationsResponse(items: [_event(9), _event(10), _event(12)]));
      expect(result.events.map((e) => e.id), [12]);
      expect(result.cursor, 12);
    });

    test('visibility widens -> no old events shown', () {
      // Page not full: the cursor jumps to the newest id overall, past events this user couldn't see yet.
      final quiet = applyJellybotResponse(10, const ReadyNotificationsResponse(items: [], latestId: 200));
      expect(quiet.events, isEmpty);
      expect(quiet.cursor, 200);

      // Only-mine is turned off: older events (<= 200) are never asked for again; newer ones are shown.
      final later = applyJellybotResponse(
        quiet.cursor,
        ReadyNotificationsResponse(items: [_event(201), _event(202)], latestId: 202),
      );
      expect(later.events.map((e) => e.id), [201, 202]);
      expect(later.cursor, 202);
    });

    test('a full page moves the cursor to its last item, not latestId', () {
      final result = applyJellybotResponse(
        10,
        ReadyNotificationsResponse(items: [_event(11), _event(12)], latestId: 500),
        limit: 2,
      );
      expect(result.events.map((e) => e.id), [11, 12]);
      expect(result.cursor, 12);
    });
  });

  group('jellybotNotificationModel', () {
    test('movie opens the movie details', () {
      final model = jellybotNotificationModel(
        _event(1, itemId: 'movie-1'),
        l10n,
        userId: 'u',
        serverId: 's',
      )!;
      expect(model.key, 'jellybot-1');
      expect(model.id, 'movie-1');
      expect(model.title, 'Title 1');
      expect(model.subtitle, 'Movie ready');
      expect(model.payLoad, NotificationHelpers.buildDetailsDeepLink('movie-1', userId: 'u', serverId: 's'));
    });

    test('complete season names the season and opens it', () {
      final model = jellybotNotificationModel(
        _event(2, kind: ReadyNotificationKind.seasoncomplete, itemId: 'season-2', seriesId: 'show', season: 2),
        l10n,
      )!;
      expect(model.subtitle, 'Season 2 complete');
      expect(model.payLoad, NotificationHelpers.buildDetailsDeepLink('season-2'));
    });

    test('new episodes list the episodes and open the series', () {
      final model = jellybotNotificationModel(
        _event(3, kind: ReadyNotificationKind.newepisodes, itemId: 'show', seriesId: 'show', episodes: [4, 5, 6]),
        l10n,
      )!;
      expect(model.subtitle, 'Episodes 4–6');
      expect(model.payLoad, NotificationHelpers.buildDetailsDeepLink('show'));
    });

    test('event without a Jellyfin id is dropped', () {
      expect(jellybotNotificationModel(_event(4, itemId: null), l10n), isNull);
      expect(jellybotNotificationModel(_event(5, itemId: ''), l10n), isNull);
    });
  });

  group('dedup (JellyBot wins)', () {
    final reported = jellybotReportedIds([
      _event(1, itemId: 'movie-1'),
      _event(2, kind: ReadyNotificationKind.newepisodes, itemId: 'show-a', seriesId: 'show-a'),
      _event(3, kind: ReadyNotificationKind.seasoncomplete, itemId: 'season-b1', seriesId: 'show-b'),
    ]);

    test('collects item and series ids', () {
      expect(reported, {'movie-1', 'show-a', 'season-b1', 'show-b'});
    });

    test('drops reported items and everything under a reported series or season', () {
      const items = [
        dto.BaseItemDto(id: 'movie-1'),
        dto.BaseItemDto(id: 'show-a'),
        dto.BaseItemDto(id: 'ep-a1', seriesId: 'show-a'),
        dto.BaseItemDto(id: 'ep-b1', seasonId: 'season-b1'),
        dto.BaseItemDto(id: 'ep-b2', seriesId: 'show-b'),
        dto.BaseItemDto(id: 'movie-2'),
        dto.BaseItemDto(id: 'ep-c1', seriesId: 'show-c', seasonId: 'season-c1'),
      ];
      expect(dropJellybotReported(items, reported).map((e) => e.id), ['movie-2', 'ep-c1']);
    });

    test('nothing reported keeps every item', () {
      const items = [dto.BaseItemDto(id: 'a')];
      expect(dropJellybotReported(items, const {}), items);
    });
  });

  group('gating', () {
    late JellybotNotificationStore store;
    final now = DateTime(2026, 11, 15, 12);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = JellybotNotificationStore(await SharedPreferences.getInstance());
    });

    test('unknown master value counts as on', () {
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now), isTrue);
    });

    test('master off or JellyBot not configured stops polling', () async {
      await store.setCachedEnabled('a', false);
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now), isFalse);
      expect(shouldPollJellybot(store, 'b', jellybotConfigured: false, now: now), isFalse);
    });

    test('a 401 pauses the account for 24 hours, then it is tried again', () async {
      await store.markUnsupported('a', now);
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now), isFalse);
      expect(
        shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now.add(const Duration(hours: 23, minutes: 59))),
        isFalse,
      );
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now.add(jellybotUnsupportedRetry)), isTrue);
    });

    test('clearing the marker resumes polling and reports whether there was one', () async {
      expect(await store.clearUnsupported('a'), isFalse);
      await store.markUnsupported('a', now);
      expect(await store.clearUnsupported('a'), isTrue);
      expect(store.unsupportedAt('a'), isNull);
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now), isTrue);
    });

    test('store keeps state per account', () async {
      expect(store.cursor('a'), isNull);
      await store.setCursor('a', 5);
      await store.markUnsupported('b', now);
      await store.setCachedEnabled('c', false);

      expect(store.cursor('a'), 5);
      expect(store.cursor('b'), isNull);
      expect(shouldPollJellybot(store, 'a', jellybotConfigured: true, now: now), isTrue);
      expect(shouldPollJellybot(store, 'b', jellybotConfigured: true, now: now), isFalse);
      expect(shouldPollJellybot(store, 'c', jellybotConfigured: true, now: now), isFalse);
    });
  });

  test('series key ignores dashes and case', () {
    expect(jellybotSeriesKey('AB12-cd34'), jellybotSeriesKey('ab12cd34'));
  });

  group('kind line', () {
    test('movie and complete season', () {
      expect(jellybotKindLine(_event(1), l10n), 'Movie ready');
      expect(
        jellybotKindLine(_event(2, kind: ReadyNotificationKind.seasoncomplete, season: 2), l10n),
        'Season 2 complete',
      );
    });

    test('episodes collapse into ranges, unsorted input', () {
      String line(List<int> episodes) =>
          jellybotKindLine(_event(3, kind: ReadyNotificationKind.newepisodes, episodes: episodes), l10n);
      expect(line([3]), 'Episode 3');
      expect(line([4, 3]), 'Episodes 3–4');
      expect(line([7, 1, 2, 3, 3]), 'Episodes 1–3, 7');
      expect(line([]), 'New episodes');
    });

    test('complete season without a number falls back', () {
      expect(jellybotKindLine(_event(4, kind: ReadyNotificationKind.seasoncomplete), l10n), l10n.jellybotReadyToWatch);
    });
  });

  group('unread', () {
    final events = [_event(12), _event(11), _event(10)];

    test('never read means everything is unread', () {
      expect(jellybotUnreadCount(events, null), 3);
    });

    test('only ids past the marker are unread', () {
      expect(jellybotUnreadCount(events, 10), 2);
      expect(isJellybotUnread(_event(10), 10), isFalse);
      expect(isJellybotUnread(_event(11), 10), isTrue);
      expect(jellybotUnreadCount(events, 12), 0);
    });
  });
}
