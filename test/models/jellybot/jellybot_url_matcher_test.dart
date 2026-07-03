import 'package:flutter_test/flutter_test.dart';

import 'package:fladder/models/jellybot/jellybot_url_matcher.dart';

void main() {
  group('normalizeCrawlUrlKey', () {
    test('strips scheme and host so rotated domains still match', () {
      expect(
        normalizeCrawlUrlKey('https://wawacity.foo/film/matrix-1080p'),
        normalizeCrawlUrlKey('https://wawacity.bar/film/matrix-1080p'),
      );
    });

    test('is case-insensitive and ignores a trailing slash', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/Film/Matrix/'),
        normalizeCrawlUrlKey('http://b.example/film/matrix'),
      );
    });

    test('decodes percent-encoding', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/film/no%C3%ABl-magique'),
        normalizeCrawlUrlKey('https://b.example/film/noël-magique'),
      );
    });

    test('decodes before lowercasing so encoded uppercase letters match', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/film/NO%C3%8BL'),
        normalizeCrawlUrlKey('https://b.example/film/noël'),
      );
    });

    test('query parameter order does not matter', () {
      expect(
        normalizeCrawlUrlKey('https://a.example/watch?a=1&b=2'),
        normalizeCrawlUrlKey('https://b.example/watch?b=2&a=1'),
      );
    });

    test('keeps the query string (some providers identify items by query)', () {
      expect(normalizeCrawlUrlKey('https://a.example/watch?id=42'), '/watch?id=42');
      expect(
        normalizeCrawlUrlKey('https://a.example/watch?id=42'),
        isNot(normalizeCrawlUrlKey('https://a.example/watch?id=43')),
      );
    });

    test('accepts already-relative urls', () {
      expect(normalizeCrawlUrlKey('/film/matrix-1080p'), '/film/matrix-1080p');
      expect(normalizeCrawlUrlKey('film/matrix-1080p'), '/film/matrix-1080p');
    });

    test('returns null for null, empty and blank input', () {
      expect(normalizeCrawlUrlKey(null), isNull);
      expect(normalizeCrawlUrlKey(''), isNull);
      expect(normalizeCrawlUrlKey('   '), isNull);
    });

    test('survives malformed percent-encoding without throwing', () {
      expect(normalizeCrawlUrlKey('https://a.example/bad%zz'), isNotNull);
    });
  });
}
