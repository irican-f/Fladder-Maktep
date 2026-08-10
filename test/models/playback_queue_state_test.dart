import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/models/item_base_model.dart';
import 'package:fladder/models/items/item_shared_models.dart';
import 'package:fladder/models/items/overview_model.dart';
import 'package:fladder/models/playback/playback_queue_state.dart';

ItemBaseModel ep(String id) => ItemBaseModel(
      name: id,
      id: id,
      overview: const OverviewModel(),
      parentId: null,
      playlistId: null,
      images: null,
      childCount: null,
      primaryRatio: null,
      userData: const UserData(),
      canDownload: false,
      canDelete: false,
      jellyType: null,
    );

void main() {
  final season = [ep('E1'), ep('E2'), ep('E3'), ep('E4'), ep('E5')];

  group('nextItem — episode advance', () {
    test('mid-season advance returns the following episode', () {
      final q = PlaybackQueueState.fromQueue(season, initialItemId: 'E3');
      expect(q.nextItem('E3')?.id, 'E4');
    });

    test('advancing keeps the anchor in sync (E3 -> E4 -> E5)', () {
      var q = PlaybackQueueState.fromQueue(season, initialItemId: 'E3');
      q = q.advanceFromCurrentTo('E3', 'E4');
      expect(q.mainQueueCurrentId, 'E4');
      expect(q.nextItem('E4')?.id, 'E5');
    });

    // Regression: a drifted mainQueueCurrentId used to win over the item that
    // is actually playing, so nextItem returned the current episode and the
    // player "advanced" by restarting it from zero.
    test('a stale anchor must not make nextItem return the CURRENT episode', () {
      final q = PlaybackQueueState.fromQueue(season, initialItemId: 'E3');
      expect(q.nextItem('E4')?.id, 'E5',
          reason: 'the item actually playing wins over a drifted anchor');
    });

    test('anchor is only a fallback when the playing item is outside the queue', () {
      final q = PlaybackQueueState.fromQueue(season, initialItemId: 'E2');
      // 'X' is not in the main queue (e.g. playing from the next-up queue),
      // so the anchor legitimately decides what comes next.
      expect(q.nextItem('X')?.id, 'E3');
    });

    test('last episode ends the queue when repeat is off', () {
      final q = PlaybackQueueState.fromQueue(season, initialItemId: 'E5');
      expect(q.nextItem('E5'), isNull);
    });
  });
}
