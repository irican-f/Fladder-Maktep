import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/jellyfin/jellybot.swagger.dart';
import 'package:fladder/models/jellybot/jellybot_add_flow_state.dart';

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
