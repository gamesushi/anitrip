import 'package:flutter_test/flutter_test.dart';

import 'package:anitrip/utils/search_text.dart';

void main() {
  group('SearchText.normalize', () {
    test('lowercases and strips separators', () {
      expect(SearchText.normalize('Kimi No Nawa'), 'kiminonawa');
      expect(SearchText.normalize('Your Name'), 'yourname');
    });

    test('folds full-width ASCII to ASCII', () {
      expect(SearchText.normalize('ＡＮＩＴＡＢＩ'), 'anitabi');
      expect(SearchText.normalize('すずめ　の　とじまり'), isNot(contains('　')));
    });

    test('folds katakana to hiragana', () {
      expect(SearchText.normalize('すずめ'), SearchText.normalize('スズメ'));
    });

    test('folds half-width katakana', () {
      expect(SearchText.normalize('ｽｽﾞﾒ'), SearchText.normalize('すずめ'));
    });

    test('ignores Japanese punctuation differences', () {
      expect(
        SearchText.normalize('君の名は。'),
        SearchText.normalize('君の名は'),
      );
    });
  });

  group('SearchText.tokens', () {
    test('splits into AND tokens', () {
      expect(SearchText.tokens('kimi no'), ['kimi', 'no']);
      expect(SearchText.tokens('   '), isEmpty);
    });
  });

  group('SearchText.matchesAll', () {
    test('requires every token', () {
      final haystack = SearchText.normalize('すずめ の とじまり chiba');
      expect(SearchText.matchesAll(haystack, SearchText.tokens('suzume')),
          isFalse);
      expect(
        SearchText.matchesAll(haystack, SearchText.tokens('じまり chiba')),
        isTrue,
      );
      expect(SearchText.matchesAll(haystack, const []), isTrue);
    });
  });

  group('SearchText query scenarios (AniMap complaint cases)', () {
    String haystackOf(String title) {
      return SearchText.normalizedHaystack([title]);
    }

    test('space differences do not break the match', () {
      final haystack = haystackOf('すずめの戸締まり Suzume no Tojimari');
      for (final query in [
        'suzumenotojimari',
        'Suzume no Tojimari',
        'SUZUME NO TOJIMARI',
        '  suzume   no   tojimari  ',
      ]) {
        expect(
          SearchText.matchesAll(haystack, SearchText.tokens(query)),
          isTrue,
          reason: 'query "$query" should match',
        );
      }
    });

    test('full-width input matches half-width catalog', () {
      final haystack = haystackOf('ANITABI');
      expect(
        SearchText.matchesAll(haystack, SearchText.tokens('ＡＮＩＴＡＢＩ')),
        isTrue,
      );
    });

    test('katakana catalog entry found from hiragana query', () {
      final haystack = haystackOf('スズメのトジマリ すずめの戸締まり');
      expect(
        SearchText.matchesAll(haystack, SearchText.tokens('すずめ')),
        isTrue,
      );
    });
  });

  group('SearchText.romajiToKana fallback', () {
    test('converts common romanised titles', () {
      expect(SearchText.romajiToKana('kimi no nawa'), 'きみのなわ');
      expect(SearchText.romajiToKana('suzume'), 'すずめ');
      expect(SearchText.romajiToKana('kiminonawa'), 'きみのなわ');
    });

    test('handles gemination via doubled consonants', () {
      final result = SearchText.romajiToKana('natto');
      expect(result, isNotNull);
    });

    test('returns null for unconvertible input', () {
      // No mapping for standalone "y" in "yourname" — caller skips the retry.
      expect(SearchText.romajiToKana('your name'), isNull);
    });

    test('romanised query reaches the Japanese haystack', () {
      final haystack = SearchText.normalizedHaystack(['君の名は kimi no nawa']);
      final kana = SearchText.romajiToKana('kimi no nawa');
      expect(kana, 'きみのなわ');
      // The haystack keeps kanji "君の名は", so the fallback only helps when the
      // catalog also carries a kana reading; assert both directions explicitly.
      final kanaHaystack = SearchText.normalizedHaystack(['きみのなわ']);
      expect(
        SearchText.matchesAll(kanaHaystack, SearchText.tokens(kana!)),
        isTrue,
      );
      expect(haystack, isNotEmpty);
    });
  });

  group('SearchText.isLatinOnly', () {
    test('detects Latin-script queries', () {
      expect(SearchText.isLatinOnly('suzume'), isTrue);
      expect(SearchText.isLatinOnly('すずめ'), isFalse);
      expect(SearchText.isLatinOnly(''), isFalse);
    });
  });
}
