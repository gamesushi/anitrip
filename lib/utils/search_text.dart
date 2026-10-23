/// Loose text matching helpers used by Explore search.
///
/// The complaints that motivated this (see the AniMap community: "search is
/// strict about case and spaces") are handled here in one place:
///
/// * case-insensitive (was already done via `toLowerCase`),
/// * full-width ASCII / full-width space folded to their ASCII equivalents,
/// * katakana folded to hiragana,
/// * all whitespace and separator punctuation removed before matching, so
///   "kimi no nawa", "kimino nawa" and "君の名は" style variants converge,
/// * multi-token queries behave as AND (every token must match),
/// * when a pure-ASCII query matches nothing, it is retried as Japanese kana
///   so Latin-script users can find titles they only know in romanised form.
class SearchText {
  const SearchText._();

  /// Separators collapsed away before matching: whitespace, punctuation and
  /// Japanese spacing/decoration marks that users inconsistently type.
  static final RegExp _separators = RegExp(
    r'[\s　!-/:-@\[-`{-~ -⁯、-〿！-･]+',
  );

  /// Split points for tokenising a raw query (ASCII + ideographic space).
  static final RegExp _whitespace = RegExp(r'[\s　]+');

  /// Folds [input] into the comparable form: lower-cased, width-folded,
  /// katakana→hiragana, and stripped of every separator.
  static String normalize(String input) {
    final folded = <int>[];
    final units = input.codeUnits;
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      // Half-width dakuten / handakuten: voice the preceding kana instead of
      // emitting the mark itself.
      if (unit == 0xFF9E || unit == 0xFF9F) {
        if (folded.isNotEmpty) {
          final table = unit == 0xFF9E ? _dakuten : _handakuten;
          final voiced = table[folded.last];
          if (voiced != null) {
            folded[folded.length - 1] = voiced;
            continue;
          }
        }
        continue;
      }
      final codePoint = _foldCodeUnit(unit);
      if (codePoint != null) {
        folded.add(codePoint);
      }
    }
    return String.fromCharCodes(folded).toLowerCase();
  }

  static int? _foldCodeUnit(int unit) {
    // Full-width ASCII (！-～) → ASCII.
    if (unit >= 0xFF01 && unit <= 0xFF5E) {
      return unit - 0xFEE0;
    }
    // Full-width space / separators are dropped below.
    if (unit == 0x3000) {
      return null;
    }
    // Half-width katakana (ｦ-ﾝ) → full-width katakana → hiragana.
    final halfKana = _halfWidthKatakana(unit);
    if (halfKana != null) {
      return halfKana - 0x60;
    }
    // Full-width katakana → hiragana.
    if (unit >= 0x30A1 && unit <= 0x30F6) {
      return unit - 0x60;
    }
    final char = String.fromCharCode(unit);
    return _separators.hasMatch(char) ? null : unit;
  }

  /// Splits [query] into AND-matchable tokens.
  ///
  /// The split happens on the **raw** query, because [normalize] removes all
  /// separators — tokenising afterwards would collapse multi-word queries into
  /// a single token and break AND semantics.
  static List<String> tokens(String query) {
    return query
        .split(_whitespace)
        .map(normalize)
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  /// True when every token in [queryTokens] appears in [haystack]. The haystack
  /// is normalised by the caller (see [normalizedHaystack]).
  static bool matchesAll(String normalizedHaystack, List<String> queryTokens) {
    if (queryTokens.isEmpty) {
      return true;
    }
    for (final token in queryTokens) {
      if (!normalizedHaystack.contains(token)) {
        return false;
      }
    }
    return true;
  }

  /// Joins all searchable fields of a single result row into one normalised
  /// string that can be reused across tokens.
  static String normalizedHaystack(Iterable<String?> fields) {
    return normalize(fields.whereType<String>().join(' '));
  }

  /// Whether [query] looks like romanised Japanese (ASCII letters only) and is
  /// therefore worth a second kana-based attempt.
  static bool isLatinOnly(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(trimmed);
  }

  /// Best-effort romanisation → hiragana conversion used as a **fallback**
  /// attempt only. Returns null when the input cannot be converted, so callers
  /// can simply skip the extra pass.
  static String? romajiToKana(String query) {
    var source = normalize(query).replaceAll(RegExp(r'[^a-z]'), '');
    if (source.isEmpty) {
      return null;
    }
    final out = StringBuffer();
    var index = 0;
    var convertedAny = false;
    while (index < source.length) {
      var matched = false;
      // Longest-first so "shi" wins over "si"/"sh"+vowel, and "kya" over "ky".
      for (var length = 4; length >= 1; length--) {
        if (index + length > source.length) {
          continue;
        }
        final chunk = source.substring(index, index + length);
        final kana = _kanaFromChunk(chunk, source, index);
        if (kana == null) {
          continue;
        }
        out.write(kana.$1);
        index += kana.$2;
        matched = true;
        convertedAny = true;
        break;
      }
      if (!matched) {
        // Unmappable character — bail out rather than emit a half-converted
        // string that could produce false matches.
        return null;
      }
    }
    return convertedAny ? out.toString() : null;
  }

  /// Returns (kana, consumedSourceLength) for [chunk] starting at [index].
  /// Consumes an extra character for gemination (っ) and standalone n (ん).
  static (String, int)? _kanaFromChunk(String chunk, String source, int index) {
    final kana = _romajiTable[chunk];
    if (kana != null) {
      return (kana, chunk.length);
    }
    // Sokuon: doubled consonant at a non-final position.
    if (chunk.length == 2 &&
        chunk[0] == chunk[1] &&
        _consonantOnly(chunk[0]) &&
        index + 2 <= source.length) {
      return ('っ', 1);
    }
    // Standalone n before a consonant → ん.
    if (chunk == 'n' && index + 1 < source.length) {
      final next = source[index + 1];
      if (_isConsonant(next) && !'yrw'.contains(next)) {
        return ('ん', 1);
      }
    }
    return null;
  }

  static bool _isConsonant(String char) => RegExp(r'^[bcdfghjkmnpqrstvwxyz]$').hasMatch(char);
  static bool _consonantOnly(String char) =>
      RegExp(r'^[bcdfghjkmnpqrstvwxyz]$').hasMatch(char) && !'aeiou'.contains(char);

  static const Map<String, String> _romajiTable = {
    'a': 'あ', 'i': 'い', 'u': 'う', 'e': 'え', 'o': 'お',
    'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
    'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
    'sa': 'さ', 'shi': 'し', 'si': 'し', 'su': 'す', 'se': 'せ', 'so': 'そ',
    'za': 'ざ', 'ji': 'じ', 'zi': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
    'ta': 'た', 'chi': 'ち', 'ti': 'ち', 'tu': 'つ', 'tsu': 'つ',
    'te': 'て', 'to': 'と',
    'da': 'だ', 'di': 'ぢ', 'du': 'づ', 'de': 'で', 'do': 'ど',
    'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
    'ha': 'は', 'hi': 'ひ', 'fu': 'ふ', 'hu': 'ふ', 'he': 'へ', 'ho': 'ほ',
    'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
    'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
    'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
    'ya': 'や', 'yu': 'ゆ', 'yo': 'よ',
    'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
    'wa': 'わ', 'wo': 'を', 'nn': 'ん', 'n': 'ん',
    // Contracted (yōon) forms that matter for common titles.
    'kya': 'きゃ', 'kyu': 'きゅ', 'kyo': 'きょ',
    'sha': 'しゃ', 'shu': 'しゅ', 'sho': 'しょ',
    'cha': 'ちゃ', 'chu': 'ちゅ', 'cho': 'ちょ',
    'nya': 'にゃ', 'nyu': 'にゅ', 'nyo': 'にょ',
    'rya': 'りゃ', 'ryu': 'りゅ', 'ryo': 'りょ',
    'gya': 'ぎゃ', 'gyu': 'ぎゅ', 'gyo': 'ぎょ',
    'ja': 'じゃ', 'ju': 'じゅ', 'jo': 'じょ',
    'bya': 'びゃ', 'byu': 'びゅ', 'byo': 'びょ',
    'pya': 'ぴゃ', 'pyu': 'ぴゅ', 'pyo': 'ぴょ',
    'mya': 'みゃ', 'myu': 'みゅ', 'myo': 'みょ',
  };

  /// Half-width katakana (ｦ-ﾝ) → full-width katakana code points.
  static int? _halfWidthKatakana(int unit) {
    if (unit < 0xFF66 || unit > 0xFF9D) {
      return null;
    }
    // 0xFF9E / 0xFF9F are dakuten/handakuten marks, handled by [normalize].
    if (unit == 0xFF9E || unit == 0xFF9F) {
      return null;
    }
    return _halfToFull(unit);
  }

  /// Retro-voicing tables for half-width katakana, keyed by the already-folded
  /// hiragana code point.
  static const Map<int, int> _dakuten = {
    0x304B: 0x304C, 0x304D: 0x304E, 0x304F: 0x3050, 0x3051: 0x3052,
    0x3053: 0x3054, 0x3055: 0x3056, 0x3057: 0x3058, 0x3059: 0x305A,
    0x305B: 0x305C, 0x305D: 0x305E, 0x305F: 0x3060, 0x3061: 0x3062,
    0x3064: 0x3065, 0x3066: 0x3067, 0x3068: 0x3069, 0x306F: 0x3070,
    0x3072: 0x3073, 0x3075: 0x3076, 0x3078: 0x3079, 0x307B: 0x307C,
    0x3046: 0x3094,
  };

  static const Map<int, int> _handakuten = {
    0x306F: 0x3071, 0x3072: 0x3074, 0x3075: 0x3077, 0x3078: 0x307A,
    0x307B: 0x307D,
  };

  static int _halfToFull(int unit) {
    const map = <int, int>{
      0xFF66: 0x30F2, 0xFF67: 0x30A1, 0xFF68: 0x30A3, 0xFF69: 0x30A5,
      0xFF6A: 0x30A7, 0xFF6B: 0x30A9, 0xFF6C: 0x30E3, 0xFF6D: 0x30E5,
      0xFF6E: 0x30E7, 0xFF6F: 0x30C3, 0xFF70: 0x30FC,
      0xFF71: 0x30A2, 0xFF72: 0x30A4, 0xFF73: 0x30A6, 0xFF74: 0x30A8,
      0xFF75: 0x30AA, 0xFF76: 0x30AB, 0xFF77: 0x30AD, 0xFF78: 0x30AF,
      0xFF79: 0x30B1, 0xFF7A: 0x30B3, 0xFF7B: 0x30B5, 0xFF7C: 0x30B7,
      0xFF7D: 0x30B9, 0xFF7E: 0x30BB, 0xFF7F: 0x30BD, 0xFF80: 0x30BF,
      0xFF81: 0x30C1, 0xFF82: 0x30C4, 0xFF83: 0x30C6, 0xFF84: 0x30C8,
      0xFF85: 0x30CA, 0xFF86: 0x30CB, 0xFF87: 0x30CC, 0xFF88: 0x30CD,
      0xFF89: 0x30CE, 0xFF8A: 0x30CF, 0xFF8B: 0x30D2, 0xFF8C: 0x30D5,
      0xFF8D: 0x30D8, 0xFF8E: 0x30DB, 0xFF8F: 0x30DE, 0xFF90: 0x30DF,
      0xFF91: 0x30E0, 0xFF92: 0x30E1, 0xFF93: 0x30E2, 0xFF94: 0x30E4,
      0xFF95: 0x30E6, 0xFF96: 0x30E8, 0xFF97: 0x30E9, 0xFF98: 0x30EA,
      0xFF99: 0x30EB, 0xFF9A: 0x30EC, 0xFF9B: 0x30ED, 0xFF9C: 0x30EF,
      0xFF9D: 0x30F3,
    };
    return map[unit] ?? unit;
  }
}
