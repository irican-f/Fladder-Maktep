import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/providers/jellybot_api_provider.dart';

void main() {
  group('jellyfinTokenAsAuthorization', () {
    test('moves the Jellyfin token into Authorization', () {
      final headers = jellyfinTokenAsAuthorization({'X-Jellyfin-Token': 'abc123', 'Accept': 'application/json'});

      expect(headers, {'Accept': 'application/json', 'Authorization': 'MediaBrowser Token="abc123"'});
    });

    test('leaves requests without a Jellyfin token untouched', () {
      final original = {'Accept': 'application/json'};

      expect(jellyfinTokenAsAuthorization(original), same(original));
    });
  });
}
