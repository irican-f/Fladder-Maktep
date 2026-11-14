import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/screens/video_player/components/video_player_next_wrapper.dart';

void main() {
  group('nextUpCardLayout', () {
    test('portrait phone spans the screen minus the side margins, with its image', () {
      final layout = nextUpCardLayout(const Size(412, 915));
      expect(layout.width, 412 - 48);
      expect(layout.showImage, isTrue);
    });

    test('desktop / TV gets about a third, capped at 480', () {
      expect(nextUpCardLayout(const Size(1280, 800)).width, closeTo(1280 * 0.34, 0.001));
      expect(nextUpCardLayout(const Size(1920, 1080)).width, 480);
    });

    test('a tall desktop window or portrait tablet keeps the compact card', () {
      expect(nextUpCardLayout(const Size(1000, 1400)).width, closeTo(1000 * 0.34, 0.001));
      expect(nextUpCardLayout(const Size(1729, 2000)).width, 480);
    });

    test('a short wide window shrinks the card so it stays above the controls', () {
      // 686 tall: (686 - 24 - 190 - 160) * 16 / 9 = 554.6 > 480 fits; 600 tall does not.
      final layout = nextUpCardLayout(const Size(1736, 600));
      expect(layout.width, closeTo((600 - 24 - 190 - 160) * 16 / 9, 0.001));
      expect(layout.showImage, isTrue);
    });

    test('a phone held sideways never shows the image, whatever its height', () {
      for (final phone in const [Size(915, 412), Size(932, 430), Size(1000, 560)]) {
        final layout = nextUpCardLayout(phone);
        expect(layout.width, closeTo(phone.width * 0.44, 0.001), reason: '$phone');
        expect(layout.showImage, isFalse, reason: '$phone');
      }
    });
    test('never narrower than 260 so the buttons fit', () {
      expect(nextUpCardLayout(const Size(700, 700)).width, greaterThanOrEqualTo(260));
    });
  });
}
