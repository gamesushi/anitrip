import 'dart:ui';
import '../plan/pilgrimage_models.dart';

class TranslationService {
  static String resolveLanguage(String languageSetting) {
    if (languageSetting != 'system') return languageSetting;
    final locale = PlatformDispatcher.instance.locale;
    final language = locale.languageCode;
    final script = locale.scriptCode;
    if (language == 'zh') {
      if (script == 'Hant') return 'zh_Hant';
      if (locale.countryCode == 'TW' || locale.countryCode == 'HK') {
        return 'zh_Hant';
      }
      return 'zh';
    }
    return language;
  }

  static String translate(String text, String languageCode) {
    if (languageCode == 'zh') return text;
    final map = _translations[text];
    if (map == null) return text;
    return map[languageCode] ?? text;
  }

  static PilgrimagePlan translatePlan(PilgrimagePlan plan, String languageCode) {
    if (languageCode == 'zh') return plan;
    return plan.copyWith(
      name: translate(plan.name, languageCode),
      area: translate(plan.area, languageCode),
      works: plan.works.map((w) => translateWork(w, languageCode)).toList(),
      groups: plan.groups.map((g) => translateGroup(g, languageCode)).toList(),
      points: plan.points.map((p) => translatePoint(p, languageCode)).toList(),
    );
  }

  static PilgrimageWork translateWork(PilgrimageWork work, String languageCode) {
    if (languageCode == 'zh') return work;
    return PilgrimageWork(
      id: work.id,
      title: translate(work.title, languageCode),
      subtitle: work.subtitle,
      city: translate(work.city, languageCode),
      source: work.source,
      bangumiId: work.bangumiId,
      bangumiSubjectType: work.bangumiSubjectType,
    );
  }

  static PilgrimagePlanGroup translateGroup(PilgrimagePlanGroup group, String languageCode) {
    if (languageCode == 'zh') return group;
    return PilgrimagePlanGroup(
      id: group.id,
      name: translate(group.name, languageCode),
      orderIndex: group.orderIndex,
      orderMode: group.orderMode,
      anchorName: group.anchorName != null ? translate(group.anchorName!, languageCode) : null,
      anchorLatitude: group.anchorLatitude,
      anchorLongitude: group.anchorLongitude,
      anchorPointId: group.anchorPointId,
      note: group.note,
      createdAt: group.createdAt,
    );
  }

  static PilgrimagePoint translatePoint(PilgrimagePoint point, String languageCode) {
    if (languageCode == 'zh') return point;
    return point.copyWith(
      work: translateWork(point.work, languageCode),
      name: translate(point.name, languageCode),
      referenceLabel: translate(point.referenceLabel, languageCode),
    );
  }

  static final Map<String, Map<String, String>> _translations = {
    // Plan names & Area
    '示例计划': {
      'en': 'Sample Plan',
      'fr': 'Plan d\'exemple',
      'ko': '샘플 계획',
      'zh_Hant': '示例計劃',
    },
    '默认计划': {
      'en': 'Default Plan',
      'fr': 'Plan par défaut',
      'ko': '기본 계획',
      'zh_Hant': '默認計劃',
    },
    '宇治市': {
      'en': 'Uji City',
      'fr': 'Ville d\'Uji',
      'ko': '우지시',
      'zh_Hant': '宇治市',
    },
    '未设置区域': {
      'en': 'Not set',
      'fr': 'Non défini',
      'ko': '설정되지 않음',
      'zh_Hant': '未設置區域',
    },

    // Group names
    '宇治站附近': {
      'en': 'Uji Station Area',
      'fr': 'Près de la gare d\'Uji',
      'ko': '우지역 부근',
      'zh_Hant': '宇治站附近',
    },
    '大吉山': {
      'en': 'Mount Daiki',
      'fr': 'Mont Daiki',
      'ko': '다이키산',
      'zh_Hant': '大吉山',
    },
    '平等院表参道': {
      'en': 'Byodoin Omotesando',
      'fr': 'Byodoin Omotesando',
      'ko': '뵤도인 오모테산도',
      'zh_Hant': '平等院表參道',
    },
    '县神社周边': {
      'en': 'Agata Shrine Area',
      'fr': 'Près du sanctuaire Agata',
      'ko': '아가타 신사 주변',
      'zh_Hant': '縣神社周邊',
    },
    '六地藏方向': {
      'en': 'Rokujizo Area',
      'fr': 'Direction Rokujizo',
      'ko': '로쿠지조 방면',
      'zh_Hant': '六地藏方向',
    },
    '黄檗方向': {
      'en': 'Obaku Area',
      'fr': 'Direction Obaku',
      'ko': '오바쿠 방면',
      'zh_Hant': '黃檗方向',
    },
    '木幡方向': {
      'en': 'Kohata Area',
      'fr': 'Direction Kohata',
      'ko': '코하타 방면',
      'zh_Hant': '木幡方向',
    },

    // Anchor names
    'JR 宇治站': {
      'en': 'JR Uji Station',
      'fr': 'Gare JR d\'Uji',
      'ko': 'JR 우지역',
      'zh_Hant': 'JR 宇治站',
    },
    '大吉山展望台': {
      'en': 'Daiki Mountain Observatory',
      'fr': 'Observatoire du mont Daiki',
      'ko': '다이키산 전망대',
      'zh_Hant': '大吉山展望台',
    },
    '平等院表门': {
      'en': 'Byodoin Main Gate',
      'fr': 'Porte principale de Byodoin',
      'ko': '뵤도인 정문',
      'zh_Hant': '平等院表門',
    },
    '縣神社': {
      'en': 'Agata Shrine',
      'fr': 'Sanctuaire Agata',
      'ko': '아가타 신사',
      'zh_Hant': '縣神社',
    },
    '六地藏站': {
      'en': 'Rokujizo Station',
      'fr': 'Gare de Rokujizo',
      'ko': '로쿠지조역',
      'zh_Hant': '六地藏站',
    },
    '黄檗站': {
      'en': 'Obaku Station',
      'fr': 'Gare d\'Obaku',
      'ko': '오바쿠역',
      'zh_Hant': '黃檗站',
    },
    '木幡站': {
      'en': 'Kohata Station',
      'fr': 'Gare de Kohata',
      'ko': '코하타역',
      'zh_Hant': '木幡站',
    },

    // Works
    '吹响吧！上低音号': {
      'en': 'Sound! Euphonium',
      'fr': 'Sound! Euphonium',
      'ko': '울려라! 유포니엄',
      'zh_Hant': '吹響吧！上低音號',
    },

    // Point names
    '井用机前步行道': {
      'en': 'Ajirogi Path',
      'fr': 'Chemin d\'Ajirogi',
      'ko': '아지로기 길',
      'zh_Hant': '井用機前步行道',
    },
    '宇治桥': {
      'en': 'Uji Bridge',
      'fr': 'Pont d\'Uji',
      'ko': '우지교',
      'zh_Hant': '宇治橋',
    },
    '大吉山（仏徳山）登山口': {
      'en': 'Daiki Mountain Trailhead',
      'fr': 'Départ du sentier du mont Daiki',
      'ko': '다이키산 등산로 입구',
      'zh_Hant': '大吉山（佛德山）登山口',
    },
    '宇治文化中心 停车场': {
      'en': 'Uji Cultural Center Parking',
      'fr': 'Parking du centre culturel d\'Uji',
      'ko': '우지 문화 센터 주차장',
      'zh_Hant': '宇治文化中心 停車場',
    },
    '宇治川河畔': {
      'en': 'Uji Riverbank',
      'fr': 'Rives de la rivière Uji',
      'ko': '우지강가',
      'zh_Hant': '宇治川河畔',
    },
    '京阪宇治站前': {
      'en': 'Keihan Uji Station',
      'fr': 'Devant la gare Keihan d\'Uji',
      'ko': '게이한 우지역 앞',
      'zh_Hant': '京阪宇治站前',
    },
    '朝雾桥': {
      'en': 'Asagiri Bridge',
      'fr': 'Pont Asagiri',
      'ko': '아사기리교',
      'zh_Hant': '朝霧橋',
    },
    '大吉山步道': {
      'en': 'Daiki Mountain Trail',
      'fr': 'Sentier du mont Daiki',
      'ko': '다이키산 산책로',
      'zh_Hant': '大吉山步道',
    },
    '大吉山休息处': {
      'en': 'Daiki Mountain Rest Area',
      'fr': 'Aire de repos du mont Daiki',
      'ko': '다이키산 쉼터',
      'zh_Hant': '大吉山休息處',
    },
    '宇治上神社参道': {
      'en': 'Ujigami Shrine Path',
      'fr': 'Chemin du sanctuaire Ujigami',
      'ko': '우지가미 신사 참배길',
      'zh_Hant': '宇治上神社參道',
    },
    '橘桥西侧': {
      'en': 'Tachibana Bridge West',
      'fr': 'Côté ouest du pont Tachibana',
      'ko': '다치바나교 서쪽',
      'zh_Hant': '橘橋西側',
    },
    '县通商店街': {
      'en': 'Agata Street Shopping District',
      'fr': 'Quartier commerçant de la rue Agata',
      'ko': '아가타 도리 상가',
      'zh_Hant': '縣通商店街',
    },
    '县神社参道口': {
      'en': 'Agata Shrine Path Entrance',
      'fr': 'Entrée du chemin du sanctuaire Agata',
      'ko': '아가타 신사 참배길 입구',
      'zh_Hant': '縣神社參道口',
    },
    '六地藏站前': {
      'en': 'Rokujizo Station Area',
      'fr': 'Devant la gare de Rokujizo',
      'ko': '로쿠지조역 앞',
      'zh_Hant': '六地藏站前',
    },
    '六地藏住宅街': {
      'en': 'Rokujizo Residential Area',
      'fr': 'Quartier résidentiel de Rokujizo',
      'ko': '로쿠지조 주택가',
      'zh_Hant': '六地藏住宅街',
    },
    '六地藏河岸': {
      'en': 'Rokujizo Riverbank',
      'fr': 'Rives de la rivière Rokujizo',
      'ko': '로쿠지조 강가',
      'zh_Hant': '六地藏河岸',
    },
    '黄檗站前': {
      'en': 'Obaku Station Area',
      'fr': 'Devant la gare d\'Obaku',
      'ko': '오바쿠역 앞',
      'zh_Hant': '黃檗站前',
    },
    '黄檗公园入口': {
      'en': 'Obaku Park Entrance',
      'fr': 'Entrée du parc Obaku',
      'ko': '오바쿠 공원 입구',
      'zh_Hant': '黃檗公園入口',
    },
    '黄檗街角': {
      'en': 'Obaku Street Corner',
      'fr': 'Coin de rue d\'Obaku',
      'ko': '오바쿠 길모퉁이',
      'zh_Hant': '黃檗街角',
    },
    '木幡站前': {
      'en': 'Kohata Station Area',
      'fr': 'Devant la gare de Kohata',
      'ko': '코하타역 앞',
      'zh_Hant': '木幡站前',
    },
    '木幡商店前': {
      'en': 'In front of Kohata Shop',
      'fr': 'Devant la boutique de Kohata',
      'ko': '코하타 상점 앞',
      'zh_Hant': '木幡商店前',
    },
    '木幡住宅街': {
      'en': 'Kohata Residential Area',
      'fr': 'Quartier résidentiel de Kohata',
      'ko': '코하타 주택가',
      'zh_Hant': '木幡住宅街',
    },
    '测试点位': {
      'en': 'Test Point',
      'fr': 'Point de test',
      'ko': '테스트 지점',
      'zh_Hant': '測試點位',
    },
  };
}
