import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @tabPlan.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get tabPlan;

  /// No description provided for @tabMap.
  ///
  /// In zh, this message translates to:
  /// **'地图'**
  String get tabMap;

  /// No description provided for @tabRecords.
  ///
  /// In zh, this message translates to:
  /// **'记录'**
  String get tabRecords;

  /// No description provided for @tabSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tabSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @languageSetting.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get languageSetting;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageZh.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get languageZh;

  /// No description provided for @languageZhHant.
  ///
  /// In zh, this message translates to:
  /// **'繁體中文'**
  String get languageZhHant;

  /// No description provided for @languageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageFr.
  ///
  /// In zh, this message translates to:
  /// **'Français'**
  String get languageFr;

  /// No description provided for @languageKo.
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get languageKo;

  /// No description provided for @languageJa.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get languageJa;

  /// No description provided for @languageRu.
  ///
  /// In zh, this message translates to:
  /// **'Русский'**
  String get languageRu;

  /// No description provided for @languageEs.
  ///
  /// In zh, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languagePt.
  ///
  /// In zh, this message translates to:
  /// **'Português'**
  String get languagePt;

  /// No description provided for @languageIt.
  ///
  /// In zh, this message translates to:
  /// **'Italiano'**
  String get languageIt;

  /// No description provided for @languageTh.
  ///
  /// In zh, this message translates to:
  /// **'ภาษาไทย'**
  String get languageTh;

  /// No description provided for @languageVi.
  ///
  /// In zh, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVi;

  /// No description provided for @languageMs.
  ///
  /// In zh, this message translates to:
  /// **'Bahasa Melayu'**
  String get languageMs;

  /// No description provided for @labelWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get labelWork;

  /// No description provided for @labelScene.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get labelScene;

  /// No description provided for @labelCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get labelCoordinates;

  /// No description provided for @labelArea.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get labelArea;

  /// No description provided for @labelReference.
  ///
  /// In zh, this message translates to:
  /// **'参考'**
  String get labelReference;

  /// No description provided for @labelSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get labelSource;

  /// No description provided for @labelId.
  ///
  /// In zh, this message translates to:
  /// **'ID'**
  String get labelId;

  /// No description provided for @labelLink.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get labelLink;

  /// No description provided for @btnChange.
  ///
  /// In zh, this message translates to:
  /// **'更改'**
  String get btnChange;

  /// No description provided for @btnReplace.
  ///
  /// In zh, this message translates to:
  /// **'替换'**
  String get btnReplace;

  /// No description provided for @labelLocalRecords.
  ///
  /// In zh, this message translates to:
  /// **'本点记录'**
  String get labelLocalRecords;

  /// No description provided for @labelAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get labelAll;

  /// No description provided for @btnNavigate.
  ///
  /// In zh, this message translates to:
  /// **'导航'**
  String get btnNavigate;

  /// No description provided for @btnOverlay.
  ///
  /// In zh, this message translates to:
  /// **'拍摄参考'**
  String get btnOverlay;

  /// No description provided for @btnSetTarget.
  ///
  /// In zh, this message translates to:
  /// **'设为当前'**
  String get btnSetTarget;

  /// No description provided for @btnMarkDone.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get btnMarkDone;

  /// No description provided for @btnEditPoint.
  ///
  /// In zh, this message translates to:
  /// **'编辑点位'**
  String get btnEditPoint;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观设置'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'主题色、缩放、显示等'**
  String get settingsAppearanceSubtitle;

  /// No description provided for @settingsCamera.
  ///
  /// In zh, this message translates to:
  /// **'拍摄设置'**
  String get settingsCamera;

  /// No description provided for @settingsCameraSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'照片比例、参考图比例、备份等'**
  String get settingsCameraSubtitle;

  /// No description provided for @settingsExport.
  ///
  /// In zh, this message translates to:
  /// **'对比图设置'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'导出样式、自动保存到相册'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsDataSource.
  ///
  /// In zh, this message translates to:
  /// **'数据源设置'**
  String get settingsDataSource;

  /// No description provided for @settingsDataSourceSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'地图源、图片源等'**
  String get settingsDataSourceSubtitle;

  /// No description provided for @settingsClearCache.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'完整参考图缓存'**
  String get settingsClearCacheSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于 anitrip'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'版本信息、开源许可等'**
  String get settingsAboutSubtitle;

  /// No description provided for @btnCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get btnCancel;

  /// No description provided for @btnConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get btnConfirm;

  /// No description provided for @btnSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get btnSave;

  /// No description provided for @labelManualEntry.
  ///
  /// In zh, this message translates to:
  /// **'手动录入'**
  String get labelManualEntry;

  /// No description provided for @labelRevertCompleted.
  ///
  /// In zh, this message translates to:
  /// **'撤回打卡'**
  String get labelRevertCompleted;

  /// No description provided for @labelUnassignedGroup.
  ///
  /// In zh, this message translates to:
  /// **'未分入片区'**
  String get labelUnassignedGroup;

  /// No description provided for @labelUnknownGroup.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get labelUnknownGroup;

  /// No description provided for @labelNoAnchor.
  ///
  /// In zh, this message translates to:
  /// **'未设置关键点'**
  String get labelNoAnchor;

  /// No description provided for @labelStatusCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前目标'**
  String get labelStatusCurrent;

  /// No description provided for @labelStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get labelStatusCompleted;

  /// No description provided for @labelStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待访问'**
  String get labelStatusPending;

  /// No description provided for @settingsReset.
  ///
  /// In zh, this message translates to:
  /// **'恢复初始设置'**
  String get settingsReset;

  /// No description provided for @settingsResetConfirmSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'所有外观、拍摄和地图设置将恢复为默认值。'**
  String get settingsResetConfirmSubtitle;

  /// No description provided for @settingsThemeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get settingsThemeColor;

  /// No description provided for @settingsThemeColorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'影响应用整体配色'**
  String get settingsThemeColorSubtitle;

  /// No description provided for @settingsThemeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsUiScale.
  ///
  /// In zh, this message translates to:
  /// **'页面缩放'**
  String get settingsUiScale;

  /// No description provided for @settingsUiScaleSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'调整界面整体大小（不影响参考图）'**
  String get settingsUiScaleSubtitle;

  /// No description provided for @settingsCameraRatio.
  ///
  /// In zh, this message translates to:
  /// **'拍摄图片比例'**
  String get settingsCameraRatio;

  /// No description provided for @settingsCameraZoom.
  ///
  /// In zh, this message translates to:
  /// **'相机缩放'**
  String get settingsCameraZoom;

  /// No description provided for @settingsPhotoBackup.
  ///
  /// In zh, this message translates to:
  /// **'照片备份'**
  String get settingsPhotoBackup;

  /// No description provided for @settingsPhotoBackupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保存巡礼照片到相册'**
  String get settingsPhotoBackupSubtitle;

  /// No description provided for @settingsAutoSaveComparison.
  ///
  /// In zh, this message translates to:
  /// **'自动保存对比图'**
  String get settingsAutoSaveComparison;

  /// No description provided for @settingsAutoSaveComparisonSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'保存记录时保存到相册'**
  String get settingsAutoSaveComparisonSubtitle;

  /// No description provided for @settingsDesktop.
  ///
  /// In zh, this message translates to:
  /// **'桌面端'**
  String get settingsDesktop;

  /// No description provided for @settingsDesktopSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'启动器、数据目录等'**
  String get settingsDesktopSubtitle;

  /// No description provided for @desktopLauncherChecking.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 检查中'**
  String get desktopLauncherChecking;

  /// No description provided for @desktopLauncherUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 不可用'**
  String get desktopLauncherUnavailable;

  /// No description provided for @desktopSystemDataDir.
  ///
  /// In zh, this message translates to:
  /// **'系统数据目录'**
  String get desktopSystemDataDir;

  /// No description provided for @desktopPortableDir.
  ///
  /// In zh, this message translates to:
  /// **'便携目录'**
  String get desktopPortableDir;

  /// No description provided for @desktopAppDataDir.
  ///
  /// In zh, this message translates to:
  /// **'应用数据目录'**
  String get desktopAppDataDir;

  /// No description provided for @desktopLauncherAvailable.
  ///
  /// In zh, this message translates to:
  /// **'桌面启动器 可用'**
  String get desktopLauncherAvailable;

  /// No description provided for @settingsFontSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get settingsFontSmall;

  /// No description provided for @settingsFontStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get settingsFontStandard;

  /// No description provided for @settingsFontLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get settingsFontLarge;

  /// No description provided for @settingsFontHuge.
  ///
  /// In zh, this message translates to:
  /// **'特大'**
  String get settingsFontHuge;

  /// No description provided for @msgReplacingRef.
  ///
  /// In zh, this message translates to:
  /// **'正在替换参考图...'**
  String get msgReplacingRef;

  /// No description provided for @msgReplaceRefFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图替换失败，请稍后重试。'**
  String get msgReplaceRefFailed;

  /// No description provided for @msgReplaceRefSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已替换参考图'**
  String get msgReplaceRefSuccess;

  /// No description provided for @msgCannotOpenMap.
  ///
  /// In zh, this message translates to:
  /// **'无法打开 Google Maps。'**
  String get msgCannotOpenMap;

  /// No description provided for @titleMoveToGroup.
  ///
  /// In zh, this message translates to:
  /// **'移动到片区'**
  String get titleMoveToGroup;

  /// No description provided for @copyLabelPointName.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get copyLabelPointName;

  /// No description provided for @copyLabelGroupAnchor.
  ///
  /// In zh, this message translates to:
  /// **'片区关键点'**
  String get copyLabelGroupAnchor;

  /// No description provided for @labelNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get labelNote;

  /// No description provided for @themeClassicGreen.
  ///
  /// In zh, this message translates to:
  /// **'经典绿'**
  String get themeClassicGreen;

  /// No description provided for @themeDeepBlue.
  ///
  /// In zh, this message translates to:
  /// **'深邃蓝'**
  String get themeDeepBlue;

  /// No description provided for @themeCherryPink.
  ///
  /// In zh, this message translates to:
  /// **'樱花粉'**
  String get themeCherryPink;

  /// No description provided for @themeTwilightPurple.
  ///
  /// In zh, this message translates to:
  /// **'暮光紫'**
  String get themeTwilightPurple;

  /// No description provided for @themeMiriaYellow.
  ///
  /// In zh, this message translates to:
  /// **'琥珀橙'**
  String get themeMiriaYellow;

  /// No description provided for @themeGraphite.
  ///
  /// In zh, this message translates to:
  /// **'石墨黑'**
  String get themeGraphite;

  /// No description provided for @themeAurora.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get themeAurora;

  /// No description provided for @aspectAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get aspectAuto;

  /// No description provided for @aspectNative.
  ///
  /// In zh, this message translates to:
  /// **'原生比例'**
  String get aspectNative;

  /// No description provided for @aspectCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get aspectCustom;

  /// No description provided for @aspectAutoHint.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get aspectAutoHint;

  /// No description provided for @aspectNativeHint.
  ///
  /// In zh, this message translates to:
  /// **'原生'**
  String get aspectNativeHint;

  /// No description provided for @aspectLandscape16x9Hint.
  ///
  /// In zh, this message translates to:
  /// **'宽屏'**
  String get aspectLandscape16x9Hint;

  /// No description provided for @aspectCinema21x9Hint.
  ///
  /// In zh, this message translates to:
  /// **'电影'**
  String get aspectCinema21x9Hint;

  /// No description provided for @aspectStandard4x3Hint.
  ///
  /// In zh, this message translates to:
  /// **'经典'**
  String get aspectStandard4x3Hint;

  /// No description provided for @aspectPhoto3x2Hint.
  ///
  /// In zh, this message translates to:
  /// **'相机'**
  String get aspectPhoto3x2Hint;

  /// No description provided for @aspectPortrait9x16Hint.
  ///
  /// In zh, this message translates to:
  /// **'竖屏'**
  String get aspectPortrait9x16Hint;

  /// No description provided for @aspectPortrait9x21Hint.
  ///
  /// In zh, this message translates to:
  /// **'全面屏'**
  String get aspectPortrait9x21Hint;

  /// No description provided for @aspectPortrait3x4Hint.
  ///
  /// In zh, this message translates to:
  /// **'竖幅'**
  String get aspectPortrait3x4Hint;

  /// No description provided for @aspectPortrait2x3Hint.
  ///
  /// In zh, this message translates to:
  /// **'竖幅'**
  String get aspectPortrait2x3Hint;

  /// No description provided for @aspectSquare1x1Hint.
  ///
  /// In zh, this message translates to:
  /// **'方形'**
  String get aspectSquare1x1Hint;

  /// No description provided for @aspectCustomHint.
  ///
  /// In zh, this message translates to:
  /// **'自定'**
  String get aspectCustomHint;

  /// No description provided for @mapProviderOpenFreeMap.
  ///
  /// In zh, this message translates to:
  /// **'OpenFreeMap'**
  String get mapProviderOpenFreeMap;

  /// No description provided for @mapProviderOpenFreeMapDesc.
  ///
  /// In zh, this message translates to:
  /// **'默认地图，使用 MapLibre style。'**
  String get mapProviderOpenFreeMapDesc;

  /// No description provided for @mapProviderOpenStreetMap.
  ///
  /// In zh, this message translates to:
  /// **'OpenStreetMap'**
  String get mapProviderOpenStreetMap;

  /// No description provided for @mapProviderOpenStreetMapDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用 OpenStreetMap 标准 XYZ 瓦片。'**
  String get mapProviderOpenStreetMapDesc;

  /// No description provided for @mapProviderCustomXyz.
  ///
  /// In zh, this message translates to:
  /// **'自定义 XYZ'**
  String get mapProviderCustomXyz;

  /// No description provided for @mapProviderCustomXyzDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用包含 {z}/{x}/{y} 的栅格瓦片 URL。'**
  String mapProviderCustomXyzDesc(Object x, Object y, Object z);

  /// No description provided for @mapProviderCustomMapLibre.
  ///
  /// In zh, this message translates to:
  /// **'自定义 MapLibre'**
  String get mapProviderCustomMapLibre;

  /// No description provided for @mapProviderCustomMapLibreDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用自定义 MapLibre style URL。'**
  String get mapProviderCustomMapLibreDesc;

  /// No description provided for @mapStyleLibertyDesc.
  ///
  /// In zh, this message translates to:
  /// **'默认样式，信息密度较高。'**
  String get mapStyleLibertyDesc;

  /// No description provided for @mapStyleBrightDesc.
  ///
  /// In zh, this message translates to:
  /// **'明亮标准样式。'**
  String get mapStyleBrightDesc;

  /// No description provided for @mapStylePositronDesc.
  ///
  /// In zh, this message translates to:
  /// **'浅色低干扰样式。'**
  String get mapStylePositronDesc;

  /// No description provided for @mapStyleDarkDesc.
  ///
  /// In zh, this message translates to:
  /// **'深色地图样式。'**
  String get mapStyleDarkDesc;

  /// No description provided for @mapStyleFiordDesc.
  ///
  /// In zh, this message translates to:
  /// **'柔和地形风格。'**
  String get mapStyleFiordDesc;

  /// No description provided for @imageSourceAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get imageSourceAuto;

  /// No description provided for @imageSourceOfficial.
  ///
  /// In zh, this message translates to:
  /// **'官方默认'**
  String get imageSourceOfficial;

  /// No description provided for @imageSourceMirror.
  ///
  /// In zh, this message translates to:
  /// **'备用源'**
  String get imageSourceMirror;

  /// No description provided for @imageSourceAutoDesc.
  ///
  /// In zh, this message translates to:
  /// **'优先使用 image.anitabi.cn；如果下载到错误页或被拦截，会尝试 img-tc.anitabi.cn。'**
  String get imageSourceAutoDesc;

  /// No description provided for @imageSourceOfficialDesc.
  ///
  /// In zh, this message translates to:
  /// **'固定使用 image.anitabi.cn，保留 Anitabi 官方默认图片源。'**
  String get imageSourceOfficialDesc;

  /// No description provided for @imageSourceMirrorDesc.
  ///
  /// In zh, this message translates to:
  /// **'固定使用 img-tc.anitabi.cn，适合官方默认源经常被拦截时使用。'**
  String get imageSourceMirrorDesc;

  /// No description provided for @mapProviderRecommendedDefault.
  ///
  /// In zh, this message translates to:
  /// **'推荐默认'**
  String get mapProviderRecommendedDefault;

  /// No description provided for @mapProviderStandardTiles.
  ///
  /// In zh, this message translates to:
  /// **'标准瓦片'**
  String get mapProviderStandardTiles;

  /// No description provided for @mapProviderTileTemplate.
  ///
  /// In zh, this message translates to:
  /// **'瓦片模板'**
  String get mapProviderTileTemplate;

  /// No description provided for @mapProviderStyleUrl.
  ///
  /// In zh, this message translates to:
  /// **'样式 URL'**
  String get mapProviderStyleUrl;

  /// No description provided for @cameraCaptureRatioSection.
  ///
  /// In zh, this message translates to:
  /// **'拍摄图片比例'**
  String get cameraCaptureRatioSection;

  /// No description provided for @cameraCaptureRatioDesc.
  ///
  /// In zh, this message translates to:
  /// **'自动会优先跟随参考图比例；选择固定比例后会按该比例拍摄。'**
  String get cameraCaptureRatioDesc;

  /// No description provided for @cameraFallbackRatioSection.
  ///
  /// In zh, this message translates to:
  /// **'无参考图时比例'**
  String get cameraFallbackRatioSection;

  /// No description provided for @cameraFallbackRatioDesc.
  ///
  /// In zh, this message translates to:
  /// **'拍摄图片比例为自动、且没有参考图可对齐时使用。'**
  String get cameraFallbackRatioDesc;

  /// No description provided for @cameraReferenceScaleSection.
  ///
  /// In zh, this message translates to:
  /// **'参考图显示'**
  String get cameraReferenceScaleSection;

  /// No description provided for @cameraZoomSection.
  ///
  /// In zh, this message translates to:
  /// **'相机缩放'**
  String get cameraZoomSection;

  /// No description provided for @cameraBackupDetailDesc.
  ///
  /// In zh, this message translates to:
  /// **'保存记录时同时备份一张巡礼照片。'**
  String get cameraBackupDetailDesc;

  /// No description provided for @mapSourceSection.
  ///
  /// In zh, this message translates to:
  /// **'地图源'**
  String get mapSourceSection;

  /// No description provided for @mapOpenFreeMapStyleSection.
  ///
  /// In zh, this message translates to:
  /// **'OpenFreeMap 样式'**
  String get mapOpenFreeMapStyleSection;

  /// No description provided for @mapCustomXyzUrlNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置自定义 XYZ URL'**
  String get mapCustomXyzUrlNotSet;

  /// No description provided for @mapCustomXyzUrlTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义 XYZ URL'**
  String get mapCustomXyzUrlTitle;

  /// No description provided for @mapCustomXyzUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'URL 需要包含 {z}、{x}、{y}。'**
  String mapCustomXyzUrlHelper(Object x, Object y, Object z);

  /// No description provided for @mapCustomXyzUrlInvalid.
  ///
  /// In zh, this message translates to:
  /// **'URL 格式无效'**
  String get mapCustomXyzUrlInvalid;

  /// No description provided for @mapCustomMapLibreUrlNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置 MapLibre style URL'**
  String get mapCustomMapLibreUrlNotSet;

  /// No description provided for @mapCustomMapLibreUrlTitle.
  ///
  /// In zh, this message translates to:
  /// **'MapLibre style URL'**
  String get mapCustomMapLibreUrlTitle;

  /// No description provided for @mapCustomMapLibreUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'URL 需要指向可公开读取的 style JSON。'**
  String get mapCustomMapLibreUrlHelper;

  /// No description provided for @mapAnitabiImageSourceSection.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 图片源'**
  String get mapAnitabiImageSourceSection;

  /// No description provided for @mapThumbnailSection.
  ///
  /// In zh, this message translates to:
  /// **'地图缩略图'**
  String get mapThumbnailSection;

  /// No description provided for @mapThumbnailThresholdTitle.
  ///
  /// In zh, this message translates to:
  /// **'缩略图显示阈值'**
  String get mapThumbnailThresholdTitle;

  /// No description provided for @mapThumbnailThresholdDesc.
  ///
  /// In zh, this message translates to:
  /// **'视图内点位不超过 {threshold} 个时显示缩略图；超过时仅显示圆点。'**
  String mapThumbnailThresholdDesc(Object threshold);

  /// No description provided for @mapConcurrentLoadsTitle.
  ///
  /// In zh, this message translates to:
  /// **'图片同时请求数'**
  String get mapConcurrentLoadsTitle;

  /// No description provided for @mapConcurrentLoadsDesc.
  ///
  /// In zh, this message translates to:
  /// **'用于地图缩略图显示、导入点位时缓存缩略图，以及批量缓存参考图。数值越大速度可能越快，但网络压力也更高。'**
  String get mapConcurrentLoadsDesc;

  /// No description provided for @mapThumbnailThresholdZeroHint.
  ///
  /// In zh, this message translates to:
  /// **'阈值为 0 时不会在地图上显示缩略图。'**
  String get mapThumbnailThresholdZeroHint;

  /// No description provided for @mapNavigationAppSection.
  ///
  /// In zh, this message translates to:
  /// **'导航软件'**
  String get mapNavigationAppSection;

  /// No description provided for @mapNavigationAppHint.
  ///
  /// In zh, this message translates to:
  /// **'仅保留界面选项，暂不接入实际导航跳转。'**
  String get mapNavigationAppHint;

  /// No description provided for @desktopLauncherSection.
  ///
  /// In zh, this message translates to:
  /// **'启动器'**
  String get desktopLauncherSection;

  /// No description provided for @aboutAppInfoSection.
  ///
  /// In zh, this message translates to:
  /// **'应用信息'**
  String get aboutAppInfoSection;

  /// No description provided for @aboutAppDescription.
  ///
  /// In zh, this message translates to:
  /// **'动漫圣地巡礼计划与拍摄参考工具'**
  String get aboutAppDescription;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get aboutVersionLabel;

  /// No description provided for @aboutLoadingText.
  ///
  /// In zh, this message translates to:
  /// **'读取中'**
  String get aboutLoadingText;

  /// No description provided for @aboutAuthorLabel.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get aboutAuthorLabel;

  /// No description provided for @aboutContactEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'联系邮箱'**
  String get aboutContactEmailLabel;

  /// No description provided for @aboutSourceCodeRepositoryLabel.
  ///
  /// In zh, this message translates to:
  /// **'开源仓库'**
  String get aboutSourceCodeRepositoryLabel;

  /// No description provided for @aboutLicenseLabel.
  ///
  /// In zh, this message translates to:
  /// **'开源许可'**
  String get aboutLicenseLabel;

  /// No description provided for @aboutCopyrightSection.
  ///
  /// In zh, this message translates to:
  /// **'数据与版权'**
  String get aboutCopyrightSection;

  /// No description provided for @aboutCopyrightDescription.
  ///
  /// In zh, this message translates to:
  /// **'地图可使用 OpenFreeMap、OpenStreetMap 或自定义服务；作品搜索使用 Bangumi；巡礼点位与参考图来自 Anitabi。图片源设置只影响访问域名，远端链接会统一保留 Anitabi 默认格式。第三方数据、截图和图片版权归原平台、贡献者或权利方所有。'**
  String get aboutCopyrightDescription;

  /// No description provided for @mapThumbnailCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个'**
  String mapThumbnailCountLabel(Object count);

  /// No description provided for @btnDecrease.
  ///
  /// In zh, this message translates to:
  /// **'减少'**
  String get btnDecrease;

  /// No description provided for @btnIncrease.
  ///
  /// In zh, this message translates to:
  /// **'增加'**
  String get btnIncrease;

  /// No description provided for @settingsExportDefaultConfig.
  ///
  /// In zh, this message translates to:
  /// **'默认配置'**
  String get settingsExportDefaultConfig;

  /// No description provided for @cachePlanSection.
  ///
  /// In zh, this message translates to:
  /// **'计划'**
  String get cachePlanSection;

  /// No description provided for @cacheLoadPlansFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划列表读取失败'**
  String get cacheLoadPlansFailed;

  /// No description provided for @cacheSelectPlanSection.
  ///
  /// In zh, this message translates to:
  /// **'选择计划'**
  String get cacheSelectPlanSection;

  /// No description provided for @cacheClearButton.
  ///
  /// In zh, this message translates to:
  /// **'清除完整参考图缓存'**
  String get cacheClearButton;

  /// No description provided for @btnRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get btnRetry;

  /// No description provided for @tooltipSelectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get tooltipSelectAll;

  /// No description provided for @tooltipClear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get tooltipClear;

  /// No description provided for @cacheClearFuncPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存功能尚未接入，仅展示界面。'**
  String get cacheClearFuncPlaceholder;

  /// No description provided for @cacheSelectedPlansCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {selected} / {total} 个计划'**
  String cacheSelectedPlansCount(int selected, int total);

  /// No description provided for @cachePointsCount.
  ///
  /// In zh, this message translates to:
  /// **'{area} / {count} 个点位'**
  String cachePointsCount(String area, int count);

  /// No description provided for @cacheContentSection.
  ///
  /// In zh, this message translates to:
  /// **'缓存内容'**
  String get cacheContentSection;

  /// No description provided for @cacheReferenceType.
  ///
  /// In zh, this message translates to:
  /// **'完整参考图缓存'**
  String get cacheReferenceType;

  /// No description provided for @cacheReferenceDesc.
  ///
  /// In zh, this message translates to:
  /// **'清除相机参考和大图查看使用的完整参考图。缩略图缓存会保留，以保持列表和地图加载速度。'**
  String get cacheReferenceDesc;

  /// No description provided for @gpsDisabled.
  ///
  /// In zh, this message translates to:
  /// **'定位服务未开启。'**
  String get gpsDisabled;

  /// No description provided for @gpsPermissionRequired.
  ///
  /// In zh, this message translates to:
  /// **'需要定位权限来显示当前位置。'**
  String get gpsPermissionRequired;

  /// No description provided for @gpsTimeout.
  ///
  /// In zh, this message translates to:
  /// **'定位超时，请稍后重试。'**
  String get gpsTimeout;

  /// No description provided for @gpsFailed.
  ///
  /// In zh, this message translates to:
  /// **'定位失败，请检查权限和定位服务。'**
  String get gpsFailed;

  /// No description provided for @planActions.
  ///
  /// In zh, this message translates to:
  /// **'计划操作'**
  String get planActions;

  /// No description provided for @planSwitch.
  ///
  /// In zh, this message translates to:
  /// **'切换计划'**
  String get planSwitch;

  /// No description provided for @planAddPoint.
  ///
  /// In zh, this message translates to:
  /// **'添加点位'**
  String get planAddPoint;

  /// No description provided for @planManage.
  ///
  /// In zh, this message translates to:
  /// **'管理计划'**
  String get planManage;

  /// No description provided for @planMemo.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录'**
  String get planMemo;

  /// No description provided for @planImportExport.
  ///
  /// In zh, this message translates to:
  /// **'导入导出'**
  String get planImportExport;

  /// No description provided for @cacheDownloading.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存完整参考图...'**
  String get cacheDownloading;

  /// No description provided for @cacheNoImagesToDownload.
  ///
  /// In zh, this message translates to:
  /// **'当前计划没有需要缓存的参考图'**
  String get cacheNoImagesToDownload;

  /// No description provided for @cacheTitle.
  ///
  /// In zh, this message translates to:
  /// **'缓存完整参考图'**
  String get cacheTitle;

  /// No description provided for @cacheConfirmMessage.
  ///
  /// In zh, this message translates to:
  /// **'将缓存当前计划中 {count} 张完整参考图，可能需要较长时间和网络流量。'**
  String cacheConfirmMessage(int count);

  /// No description provided for @cacheStart.
  ///
  /// In zh, this message translates to:
  /// **'开始缓存'**
  String get cacheStart;

  /// No description provided for @cacheStarted.
  ///
  /// In zh, this message translates to:
  /// **'已开始缓存完整参考图'**
  String get cacheStarted;

  /// No description provided for @groupPrev.
  ///
  /// In zh, this message translates to:
  /// **'上一个片区'**
  String get groupPrev;

  /// No description provided for @groupNext.
  ///
  /// In zh, this message translates to:
  /// **'下一个片区'**
  String get groupNext;

  /// No description provided for @mapCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起地图'**
  String get mapCollapse;

  /// No description provided for @labelPointsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位'**
  String labelPointsCount(Object count);

  /// No description provided for @labelCompletedCount.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get labelCompletedCount;

  /// No description provided for @labelOrderMode.
  ///
  /// In zh, this message translates to:
  /// **'模式'**
  String get labelOrderMode;

  /// No description provided for @sortModeDefault.
  ///
  /// In zh, this message translates to:
  /// **'默认计划顺序'**
  String get sortModeDefault;

  /// No description provided for @sortModeDistance.
  ///
  /// In zh, this message translates to:
  /// **'按距离当前位置'**
  String get sortModeDistance;

  /// No description provided for @sortModeDefaultShort.
  ///
  /// In zh, this message translates to:
  /// **'默认计划'**
  String get sortModeDefaultShort;

  /// No description provided for @sortModeDistanceShort.
  ///
  /// In zh, this message translates to:
  /// **'按距离'**
  String get sortModeDistanceShort;

  /// No description provided for @sortOrderDesc.
  ///
  /// In zh, this message translates to:
  /// **'反序'**
  String get sortOrderDesc;

  /// No description provided for @sortOrderAsc.
  ///
  /// In zh, this message translates to:
  /// **'正序'**
  String get sortOrderAsc;

  /// No description provided for @sortOrderFarToNear.
  ///
  /// In zh, this message translates to:
  /// **'远到近'**
  String get sortOrderFarToNear;

  /// No description provided for @sortOrderNearToFar.
  ///
  /// In zh, this message translates to:
  /// **'近到远'**
  String get sortOrderNearToFar;

  /// No description provided for @tooltipHideLocation.
  ///
  /// In zh, this message translates to:
  /// **'隐藏当前位置'**
  String get tooltipHideLocation;

  /// No description provided for @tooltipShowLocation.
  ///
  /// In zh, this message translates to:
  /// **'显示当前位置'**
  String get tooltipShowLocation;

  /// No description provided for @labelCompleted.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get labelCompleted;

  /// No description provided for @planNoPointsTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有点位'**
  String get planNoPointsTitle;

  /// No description provided for @planNoPointsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'先从 Anitabi 或手动录入添加巡礼点，之后这里会显示当前目标和完成进度。'**
  String get planNoPointsSubtitle;

  /// No description provided for @planWorksCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 部作品'**
  String planWorksCount(int count);

  /// No description provided for @visitPhotoCount.
  ///
  /// In zh, this message translates to:
  /// **'已拍 {count}'**
  String visitPhotoCount(int count);

  /// No description provided for @planHeaderStats.
  ///
  /// In zh, this message translates to:
  /// **'{area} / {points} 个点位 / {works}'**
  String planHeaderStats(String area, int points, String works);

  /// No description provided for @btnPointDetail.
  ///
  /// In zh, this message translates to:
  /// **'点位详情'**
  String get btnPointDetail;

  /// No description provided for @btnCameraReference.
  ///
  /// In zh, this message translates to:
  /// **'拍摄参考'**
  String get btnCameraReference;

  /// No description provided for @tooltipRevertCompleted.
  ///
  /// In zh, this message translates to:
  /// **'撤回打卡'**
  String get tooltipRevertCompleted;

  /// No description provided for @tooltipMarkCompleted.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get tooltipMarkCompleted;

  /// No description provided for @tooltipSetTarget.
  ///
  /// In zh, this message translates to:
  /// **'设为当前目标'**
  String get tooltipSetTarget;

  /// No description provided for @recordsUnassignedDesc.
  ///
  /// In zh, this message translates to:
  /// **'还没有放入片区的记录'**
  String get recordsUnassignedDesc;

  /// No description provided for @recordsOrphanedTitle.
  ///
  /// In zh, this message translates to:
  /// **'孤立记录'**
  String get recordsOrphanedTitle;

  /// No description provided for @recordsOrphanedDesc.
  ///
  /// In zh, this message translates to:
  /// **'对应点位已不在当前计划中'**
  String get recordsOrphanedDesc;

  /// No description provided for @recordsAllRecords.
  ///
  /// In zh, this message translates to:
  /// **'全部记录'**
  String get recordsAllRecords;

  /// No description provided for @recordsFilterConditionsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个筛选条件'**
  String recordsFilterConditionsCount(int count);

  /// No description provided for @recordsFilterTitle.
  ///
  /// In zh, this message translates to:
  /// **'筛选'**
  String get recordsFilterTitle;

  /// No description provided for @recordsSearchPoints.
  ///
  /// In zh, this message translates to:
  /// **'搜索点位'**
  String get recordsSearchPoints;

  /// No description provided for @recordsSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'点位、作品、场景、集数、坐标'**
  String get recordsSearchHint;

  /// No description provided for @tooltipClearSearch.
  ///
  /// In zh, this message translates to:
  /// **'清空搜索'**
  String get tooltipClearSearch;

  /// No description provided for @recordsFilterStatus.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get recordsFilterStatus;

  /// No description provided for @recordsFilterCompletedPoints.
  ///
  /// In zh, this message translates to:
  /// **'已完成点位'**
  String get recordsFilterCompletedPoints;

  /// No description provided for @recordsFilterPendingPoints.
  ///
  /// In zh, this message translates to:
  /// **'未完成点位'**
  String get recordsFilterPendingPoints;

  /// No description provided for @recordsPhotoTitle.
  ///
  /// In zh, this message translates to:
  /// **'巡礼照片'**
  String get recordsPhotoTitle;

  /// No description provided for @recordsEntriesCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String recordsEntriesCount(int count);

  /// No description provided for @recordsTotalCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条巡礼记录'**
  String recordsTotalCount(int count);

  /// No description provided for @recordsCompletedProgress.
  ///
  /// In zh, this message translates to:
  /// **'完成 {completed}/{total}'**
  String recordsCompletedProgress(int completed, int total);

  /// No description provided for @recordsEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'还没有巡礼记录。拍摄成功后会自动出现在这里。'**
  String get recordsEmptyMessage;

  /// No description provided for @groupOrderModePending.
  ///
  /// In zh, this message translates to:
  /// **'待整理'**
  String get groupOrderModePending;

  /// No description provided for @groupOrderModeManual.
  ///
  /// In zh, this message translates to:
  /// **'手动'**
  String get groupOrderModeManual;

  /// No description provided for @groupOrderModeNone.
  ///
  /// In zh, this message translates to:
  /// **'无序'**
  String get groupOrderModeNone;

  /// No description provided for @groupAnchorPending.
  ///
  /// In zh, this message translates to:
  /// **'等待分入片区'**
  String get groupAnchorPending;

  /// No description provided for @groupAnchorNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'关键点：{name}'**
  String groupAnchorNameLabel(String name);

  /// No description provided for @mapNoPointsSnackBar.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有点位。'**
  String get mapNoPointsSnackBar;

  /// No description provided for @tooltipLocation.
  ///
  /// In zh, this message translates to:
  /// **'定位'**
  String get tooltipLocation;

  /// No description provided for @tooltipUseIconMarkers.
  ///
  /// In zh, this message translates to:
  /// **'使用图标标记'**
  String get tooltipUseIconMarkers;

  /// No description provided for @tooltipShowThumbnailMarkers.
  ///
  /// In zh, this message translates to:
  /// **'显示缩略图标记'**
  String get tooltipShowThumbnailMarkers;

  /// No description provided for @generateRecommendedRoute.
  ///
  /// In zh, this message translates to:
  /// **'生成推荐路线'**
  String get generateRecommendedRoute;

  /// No description provided for @exportRouteToMap.
  ///
  /// In zh, this message translates to:
  /// **'导出路线到地图'**
  String get exportRouteToMap;

  /// No description provided for @tooltipShowRecommendedRoutes.
  ///
  /// In zh, this message translates to:
  /// **'显示推荐路线'**
  String get tooltipShowRecommendedRoutes;

  /// No description provided for @routeGenerated.
  ///
  /// In zh, this message translates to:
  /// **'已生成推荐路线：{summary}'**
  String routeGenerated(Object summary);

  /// No description provided for @routeTooFewPoints.
  ///
  /// In zh, this message translates to:
  /// **'该片区点位不足，无法生成路线'**
  String get routeTooFewPoints;

  /// No description provided for @routeExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开地图应用'**
  String get routeExportFailed;

  /// No description provided for @tooltipPoint.
  ///
  /// In zh, this message translates to:
  /// **'巡礼点'**
  String get tooltipPoint;

  /// No description provided for @copyLabelPointInfo.
  ///
  /// In zh, this message translates to:
  /// **'点位信息'**
  String get copyLabelPointInfo;

  /// No description provided for @mapNoPointsMessage.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有点位。添加点位后会在地图上显示标记。'**
  String get mapNoPointsMessage;

  /// No description provided for @labelEditPointNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'当前环境无法编辑点位。'**
  String get labelEditPointNotSupported;

  /// No description provided for @tooltipGoToTarget.
  ///
  /// In zh, this message translates to:
  /// **'当前目标'**
  String get tooltipGoToTarget;

  /// No description provided for @planDefaultNewName.
  ///
  /// In zh, this message translates to:
  /// **'新巡礼计划 {number}'**
  String planDefaultNewName(int number);

  /// No description provided for @planDefaultArea.
  ///
  /// In zh, this message translates to:
  /// **'未设置区域'**
  String get planDefaultArea;

  /// No description provided for @msgDeletePlanAtLeastOne.
  ///
  /// In zh, this message translates to:
  /// **'至少需要保留一个计划'**
  String get msgDeletePlanAtLeastOne;

  /// No description provided for @dialogDeletePlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除计划'**
  String get dialogDeletePlanTitle;

  /// No description provided for @dialogDeletePlanMessage.
  ///
  /// In zh, this message translates to:
  /// **'将删除「{name}」及其中的点位、片区、作品和巡礼记录。此操作无法撤销。'**
  String dialogDeletePlanMessage(String name);

  /// No description provided for @btnDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get btnDelete;

  /// No description provided for @dialogEditPlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑计划信息'**
  String get dialogEditPlanTitle;

  /// No description provided for @labelPlanName.
  ///
  /// In zh, this message translates to:
  /// **'计划名称'**
  String get labelPlanName;

  /// No description provided for @labelPlanArea.
  ///
  /// In zh, this message translates to:
  /// **'地区 / 区域'**
  String get labelPlanArea;

  /// No description provided for @btnNewPlan.
  ///
  /// In zh, this message translates to:
  /// **'新建计划'**
  String get btnNewPlan;

  /// No description provided for @statusTextCurrentPlan.
  ///
  /// In zh, this message translates to:
  /// **'当前计划'**
  String get statusTextCurrentPlan;

  /// No description provided for @statusTextSwitchable.
  ///
  /// In zh, this message translates to:
  /// **'可切换'**
  String get statusTextSwitchable;

  /// No description provided for @labelPlanInfo.
  ///
  /// In zh, this message translates to:
  /// **'计划信息'**
  String get labelPlanInfo;

  /// No description provided for @planInfoCopyContent.
  ///
  /// In zh, this message translates to:
  /// **'{name}\n{area}\n{points} 个点位\n{works}'**
  String planInfoCopyContent(
    String name,
    String area,
    int points,
    String works,
  );

  /// No description provided for @btnSwitch.
  ///
  /// In zh, this message translates to:
  /// **'切换'**
  String get btnSwitch;

  /// No description provided for @btnReloadPlan.
  ///
  /// In zh, this message translates to:
  /// **'重新加载计划'**
  String get btnReloadPlan;

  /// No description provided for @importExportImportSection.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get importExportImportSection;

  /// No description provided for @importExportImportDescMobile.
  ///
  /// In zh, this message translates to:
  /// **'从文件、聊天、浏览器或网盘等位置用 anitrip 打开 .sjhplan。'**
  String get importExportImportDescMobile;

  /// No description provided for @importExportImportDescWeb.
  ///
  /// In zh, this message translates to:
  /// **'选择 .sjhplan 文件，先预览内容再导入。'**
  String get importExportImportDescWeb;

  /// No description provided for @importExportStatusReading.
  ///
  /// In zh, this message translates to:
  /// **'读取中...'**
  String get importExportStatusReading;

  /// No description provided for @importExportOpenFromApp.
  ///
  /// In zh, this message translates to:
  /// **'从其他 App 打开 .sjhplan'**
  String get importExportOpenFromApp;

  /// No description provided for @importExportImportFileTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入 anitrip 文件'**
  String get importExportImportFileTitle;

  /// No description provided for @importExportOpenFromAppDesc.
  ///
  /// In zh, this message translates to:
  /// **'在文件、聊天、浏览器下载页或网盘中选择 .sjhplan，然后分享或用 anitrip 打开。'**
  String get importExportOpenFromAppDesc;

  /// No description provided for @importExportImportFileDesc.
  ///
  /// In zh, this message translates to:
  /// **'支持 v2 数据包和旧版 v1 JSON 计划包。'**
  String get importExportImportFileDesc;

  /// No description provided for @importExportZipDesc.
  ///
  /// In zh, this message translates to:
  /// **'新版 .sjhplan，内部为 zip，包含 manifest.json。'**
  String get importExportZipDesc;

  /// No description provided for @importExportMyMapsDesc.
  ///
  /// In zh, this message translates to:
  /// **'导出点位 CSV。图片写成链接，可按 Type 列设置样式。'**
  String get importExportMyMapsDesc;

  /// No description provided for @importExportMyMapsTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出 My Maps CSV'**
  String get importExportMyMapsTitle;

  /// No description provided for @importExportMyMapsDetails.
  ///
  /// In zh, this message translates to:
  /// **'前 6 列贴近示例格式，作品、集数、来源等拆成独立列。'**
  String get importExportMyMapsDetails;

  /// No description provided for @msgExportCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消导出'**
  String get msgExportCancelled;

  /// No description provided for @msgImportReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入文件读取失败'**
  String get msgImportReadFailed;

  /// No description provided for @dialogOpenFromAppTitle.
  ///
  /// In zh, this message translates to:
  /// **'从其他 App 打开 .sjhplan'**
  String get dialogOpenFromAppTitle;

  /// No description provided for @dialogOpenFromAppMessage.
  ///
  /// In zh, this message translates to:
  /// **'请在文件、聊天、浏览器下载页、网盘或其他保存位置找到 .sjhplan 文件，然后点开文件，或使用分享/更多菜单选择 anitrip。\n\nanitrip 收到文件后会自动进入导入预览页面。若列表里没有 anitrip，可以先把文件保存到“文件”App，再长按文件选择分享或打开方式。'**
  String get dialogOpenFromAppMessage;

  /// No description provided for @btnGotIt.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get btnGotIt;

  /// No description provided for @exportShareLabel.
  ///
  /// In zh, this message translates to:
  /// **'anitrip数据包：{name}'**
  String exportShareLabel(String name);

  /// No description provided for @msgExportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'数据包已导出'**
  String get msgExportSuccess;

  /// No description provided for @dialogMissingResourcesTitle.
  ///
  /// In zh, this message translates to:
  /// **'部分本地资源缺失'**
  String get dialogMissingResourcesTitle;

  /// No description provided for @dialogMissingResourcesMessage.
  ///
  /// In zh, this message translates to:
  /// **'这些资源不会进入数据包，导入后对应图片可能无法显示。'**
  String get dialogMissingResourcesMessage;

  /// No description provided for @btnContinueExport.
  ///
  /// In zh, this message translates to:
  /// **'继续导出'**
  String get btnContinueExport;

  /// No description provided for @msgExportMyMapsSuccess.
  ///
  /// In zh, this message translates to:
  /// **'My Maps CSV 已导出'**
  String get msgExportMyMapsSuccess;

  /// No description provided for @msgExporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导出...'**
  String get msgExporting;

  /// No description provided for @msgExportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get msgExportFailed;

  /// No description provided for @warningMissingPart.
  ///
  /// In zh, this message translates to:
  /// **'{fallback}，部分资源未能加入'**
  String warningMissingPart(String fallback);

  /// No description provided for @warningUserReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张本地上传参考图缺失'**
  String warningUserReferenceMissing(int count);

  /// No description provided for @warningThumbnailMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张缩略图未加入'**
  String warningThumbnailMissing(int count);

  /// No description provided for @warningFullReferenceDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图下载失败'**
  String warningFullReferenceDownloadFailed(int count);

  /// No description provided for @warningFullReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图缺失'**
  String warningFullReferenceMissing(int count);

  /// No description provided for @warningVisitPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张巡礼照片缺失'**
  String warningVisitPhotoMissing(int count);

  /// No description provided for @warningGradedPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张调色照片缺失'**
  String warningGradedPhotoMissing(int count);

  /// No description provided for @importExportStats.
  ///
  /// In zh, this message translates to:
  /// **'{groups} 个片区 / {points} 个点位'**
  String importExportStats(int groups, int points);

  /// No description provided for @btnPlanOnly.
  ///
  /// In zh, this message translates to:
  /// **'纯计划'**
  String get btnPlanOnly;

  /// No description provided for @btnPlanAndRecords.
  ///
  /// In zh, this message translates to:
  /// **'计划+记录'**
  String get btnPlanAndRecords;

  /// No description provided for @importExportIncludeCache.
  ///
  /// In zh, this message translates to:
  /// **'包含完整参考图缓存'**
  String get importExportIncludeCache;

  /// No description provided for @importExportIncludeCacheDesc.
  ///
  /// In zh, this message translates to:
  /// **'默认仍会包含缩略图和用户自己添加的参考图。'**
  String get importExportIncludeCacheDesc;

  /// No description provided for @btnExportDataPackage.
  ///
  /// In zh, this message translates to:
  /// **'导出 anitrip 数据包'**
  String get btnExportDataPackage;

  /// No description provided for @btnExportingDataPackage.
  ///
  /// In zh, this message translates to:
  /// **'导出中...'**
  String get btnExportingDataPackage;

  /// No description provided for @importExportEstimateEstimating.
  ///
  /// In zh, this message translates to:
  /// **'正在估算数据包大小...'**
  String get importExportEstimateEstimating;

  /// No description provided for @importExportEstimateFailed.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：暂时无法估算'**
  String get importExportEstimateFailed;

  /// No description provided for @importExportEstimateResult.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：{label}'**
  String importExportEstimateResult(String label);

  /// No description provided for @dialogLocalReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'本地上传参考图'**
  String get dialogLocalReferenceMissing;

  /// No description provided for @dialogVisitPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'巡礼照片'**
  String get dialogVisitPhotoMissing;

  /// No description provided for @dialogGradedPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'调色照片'**
  String get dialogGradedPhotoMissing;

  /// No description provided for @estimateThumbnailNotCached.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张缩略图未缓存，不会进入数据包'**
  String estimateThumbnailNotCached(int count);

  /// No description provided for @estimateFullReferenceWillDownload.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张完整参考图将在导出时下载'**
  String estimateFullReferenceWillDownload(int count);

  /// No description provided for @estimateUserReferenceMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张本地上传参考图文件缺失，导出后无法恢复'**
  String estimateUserReferenceMissing(int count);

  /// No description provided for @estimateVisitPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张巡礼照片文件缺失'**
  String estimateVisitPhotoMissing(int count);

  /// No description provided for @estimateGradedPhotoMissing.
  ///
  /// In zh, this message translates to:
  /// **'{count} 张调色照片文件缺失'**
  String estimateGradedPhotoMissing(int count);

  /// No description provided for @estimateUnknownLocalAssets.
  ///
  /// In zh, this message translates to:
  /// **'部分本地资源无法读取，实际包体可能变化'**
  String get estimateUnknownLocalAssets;

  /// No description provided for @estimateLabelAtLeast.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：至少约 {size}，{details}'**
  String estimateLabelAtLeast(String size, String details);

  /// No description provided for @estimateLabelAbout.
  ///
  /// In zh, this message translates to:
  /// **'预计数据包大小：约 {size}'**
  String estimateLabelAbout(String size);

  /// No description provided for @tooltipBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get tooltipBack;

  /// No description provided for @importExportDataPackageHeader.
  ///
  /// In zh, this message translates to:
  /// **'anitrip 数据包'**
  String get importExportDataPackageHeader;

  /// No description provided for @addPointsTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加内容'**
  String get addPointsTitle;

  /// No description provided for @addPointsAddToPlan.
  ///
  /// In zh, this message translates to:
  /// **'加入到：{planName}'**
  String addPointsAddToPlan(String planName);

  /// No description provided for @addPointsWorkManagerTitle.
  ///
  /// In zh, this message translates to:
  /// **'作品管理'**
  String get addPointsWorkManagerTitle;

  /// No description provided for @addPointsWorkManagerDesc.
  ///
  /// In zh, this message translates to:
  /// **'管理计划作品，支持 Bangumi 搜索、手动添加和删除作品。'**
  String get addPointsWorkManagerDesc;

  /// No description provided for @addPointsImportFromWorkMapTitle.
  ///
  /// In zh, this message translates to:
  /// **'从作品地图导入点位'**
  String get addPointsImportFromWorkMapTitle;

  /// No description provided for @addPointsImportFromWorkMapDesc.
  ///
  /// In zh, this message translates to:
  /// **'在 Anitabi 地图上查看作品点位，点击缩略图详情后加入计划。'**
  String get addPointsImportFromWorkMapDesc;

  /// No description provided for @addPointsImportFromLinkTitle.
  ///
  /// In zh, this message translates to:
  /// **'从 Anitabi 链接导入'**
  String get addPointsImportFromLinkTitle;

  /// No description provided for @addPointsImportFromLinkDesc.
  ///
  /// In zh, this message translates to:
  /// **'粘贴 Anitabi 作品或点位链接，快速打开对应作品地图。'**
  String get addPointsImportFromLinkDesc;

  /// No description provided for @addPointsManualTitle.
  ///
  /// In zh, this message translates to:
  /// **'手动添加点位'**
  String get addPointsManualTitle;

  /// No description provided for @addPointsManualDesc.
  ///
  /// In zh, this message translates to:
  /// **'选择已添加作品，再输入名称、坐标和场景信息。'**
  String get addPointsManualDesc;

  /// No description provided for @addPointsActionLabelUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'不可用'**
  String get addPointsActionLabelUnavailable;

  /// No description provided for @addPointsActionLabelManage.
  ///
  /// In zh, this message translates to:
  /// **'管理'**
  String get addPointsActionLabelManage;

  /// No description provided for @addPointsActionLabelOpen.
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get addPointsActionLabelOpen;

  /// No description provided for @addPointsActionLabelInput.
  ///
  /// In zh, this message translates to:
  /// **'输入'**
  String get addPointsActionLabelInput;

  /// No description provided for @addPointsActionLabelAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get addPointsActionLabelAdd;

  /// No description provided for @msgWorkAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加「{title}」。'**
  String msgWorkAdded(String title);

  /// No description provided for @msgWorkAddFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品添加失败，请稍后重试。'**
  String get msgWorkAddFailed;

  /// No description provided for @bangumiSearchTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索 Bangumi'**
  String get bangumiSearchTitle;

  /// No description provided for @bangumiSearchLabel.
  ///
  /// In zh, this message translates to:
  /// **'作品名称'**
  String get bangumiSearchLabel;

  /// No description provided for @bangumiSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 轻音少女'**
  String get bangumiSearchHint;

  /// No description provided for @bangumiSearchBtn.
  ///
  /// In zh, this message translates to:
  /// **'搜索作品'**
  String get bangumiSearchBtn;

  /// No description provided for @bangumiSearchBtnSearching.
  ///
  /// In zh, this message translates to:
  /// **'搜索中'**
  String get bangumiSearchBtnSearching;

  /// No description provided for @bangumiSearchFailed.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi 搜索失败，请检查网络后重试。'**
  String get bangumiSearchFailed;

  /// No description provided for @bangumiSearchEmptyHelp.
  ///
  /// In zh, this message translates to:
  /// **'输入作品名后搜索，选择结果即可加入当前计划。'**
  String get bangumiSearchEmptyHelp;

  /// No description provided for @anitabiLinkImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 链接导入'**
  String get anitabiLinkImportTitle;

  /// No description provided for @anitabiLinkImportLabel.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 链接'**
  String get anitabiLinkImportLabel;

  /// No description provided for @anitabiLinkImportHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 https://www.anitabi.cn/map?bangumiId=8290&pid=qdmnf6iqj'**
  String get anitabiLinkImportHint;

  /// No description provided for @anitabiLinkImportHelp.
  ///
  /// In zh, this message translates to:
  /// **'如果链接里包含作品 ID，会只加载对应作品；如果还包含点位 ID，会自动选中该点位。没有作品 ID 的链接需要先在 Anitabi 中进入对应作品后重新复制。'**
  String get anitabiLinkImportHelp;

  /// No description provided for @anitabiLinkImportBtn.
  ///
  /// In zh, this message translates to:
  /// **'打开 Anitabi 点位'**
  String get anitabiLinkImportBtn;

  /// No description provided for @anitabiLinkImportEmptyErr.
  ///
  /// In zh, this message translates to:
  /// **'请输入 Anitabi 链接'**
  String get anitabiLinkImportEmptyErr;

  /// No description provided for @anitabiLinkImportInvalidErr.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 Anitabi 地图链接'**
  String get anitabiLinkImportInvalidErr;

  /// No description provided for @anitabiLinkImportNoWorkIdErr.
  ///
  /// In zh, this message translates to:
  /// **'链接缺少作品 ID，请先在 Anitabi 进入对应作品后复制链接'**
  String get anitabiLinkImportNoWorkIdErr;

  /// No description provided for @msgPointAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加「{title}」。'**
  String msgPointAdded(String title);

  /// No description provided for @msgPointSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位保存失败，请稍后重试。'**
  String get msgPointSaveFailed;

  /// No description provided for @msgWorkSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品保存失败，请稍后重试。'**
  String get msgWorkSaveFailed;

  /// No description provided for @manualAddWorkTitle.
  ///
  /// In zh, this message translates to:
  /// **'手动添加作品'**
  String get manualAddWorkTitle;

  /// No description provided for @manualAddWorkName.
  ///
  /// In zh, this message translates to:
  /// **'作品名称'**
  String get manualAddWorkName;

  /// No description provided for @manualAddWorkOriginalName.
  ///
  /// In zh, this message translates to:
  /// **'作品原名'**
  String get manualAddWorkOriginalName;

  /// No description provided for @manualAddWorkOriginalNameHint.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get manualAddWorkOriginalNameHint;

  /// No description provided for @manualAddWorkArea.
  ///
  /// In zh, this message translates to:
  /// **'主要地区'**
  String get manualAddWorkArea;

  /// No description provided for @manualAddWorkAreaHint.
  ///
  /// In zh, this message translates to:
  /// **'可选，默认 {defaultArea}'**
  String manualAddWorkAreaHint(String defaultArea);

  /// No description provided for @manualAddWorkBtnSave.
  ///
  /// In zh, this message translates to:
  /// **'保存作品'**
  String get manualAddWorkBtnSave;

  /// No description provided for @manualAddWorkBtnSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get manualAddWorkBtnSaving;

  /// No description provided for @manualAddWorkRequiredField.
  ///
  /// In zh, this message translates to:
  /// **'请填写此项'**
  String get manualAddWorkRequiredField;

  /// No description provided for @msgReferenceImageReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图读取失败，请重新选择。'**
  String get msgReferenceImageReadFailed;

  /// No description provided for @msgClipboardCoordinatesInvalid.
  ///
  /// In zh, this message translates to:
  /// **'剪切板中没有可识别的坐标。'**
  String get msgClipboardCoordinatesInvalid;

  /// No description provided for @msgClipboardCoordinatesApplied.
  ///
  /// In zh, this message translates to:
  /// **'已填入剪切板坐标。'**
  String get msgClipboardCoordinatesApplied;

  /// No description provided for @manualAddPointTitleAdd.
  ///
  /// In zh, this message translates to:
  /// **'手动添加点位'**
  String get manualAddPointTitleAdd;

  /// No description provided for @manualAddPointTitleEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑点位'**
  String get manualAddPointTitleEdit;

  /// No description provided for @manualAddPointStatusEdit.
  ///
  /// In zh, this message translates to:
  /// **'修改：{name}'**
  String manualAddPointStatusEdit(String name);

  /// No description provided for @manualAddPointBelongingWork.
  ///
  /// In zh, this message translates to:
  /// **'所属作品'**
  String get manualAddPointBelongingWork;

  /// No description provided for @manualAddPointSelectWorkErr.
  ///
  /// In zh, this message translates to:
  /// **'请选择作品'**
  String get manualAddPointSelectWorkErr;

  /// No description provided for @manualAddPointWorkName.
  ///
  /// In zh, this message translates to:
  /// **'动画/作品名称'**
  String get manualAddPointWorkName;

  /// No description provided for @manualAddPointWorkOriginalName.
  ///
  /// In zh, this message translates to:
  /// **'作品原名'**
  String get manualAddPointWorkOriginalName;

  /// No description provided for @manualAddPointWorkOriginalNameHint.
  ///
  /// In zh, this message translates to:
  /// **'可选'**
  String get manualAddPointWorkOriginalNameHint;

  /// No description provided for @manualAddPointWorkArea.
  ///
  /// In zh, this message translates to:
  /// **'作品主要地区'**
  String get manualAddPointWorkArea;

  /// No description provided for @manualAddPointWorkAreaHint.
  ///
  /// In zh, this message translates to:
  /// **'可选，默认 {defaultArea}'**
  String manualAddPointWorkAreaHint(String defaultArea);

  /// No description provided for @manualAddPointName.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get manualAddPointName;

  /// No description provided for @manualAddPointPositionDesc.
  ///
  /// In zh, this message translates to:
  /// **'位置说明'**
  String get manualAddPointPositionDesc;

  /// No description provided for @manualAddPointEpisodeLabel.
  ///
  /// In zh, this message translates to:
  /// **'集数/场景标签'**
  String get manualAddPointEpisodeLabel;

  /// No description provided for @manualAddPointSource.
  ///
  /// In zh, this message translates to:
  /// **'参考来源'**
  String get manualAddPointSource;

  /// No description provided for @manualAddPointMemo.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get manualAddPointMemo;

  /// No description provided for @manualAddPointMemoHint.
  ///
  /// In zh, this message translates to:
  /// **'可选，例如闭店、翻修、拍摄建议'**
  String get manualAddPointMemoHint;

  /// No description provided for @manualAddPointSelectCoordsBtn.
  ///
  /// In zh, this message translates to:
  /// **'从地图选择坐标'**
  String get manualAddPointSelectCoordsBtn;

  /// No description provided for @manualAddPointPasteCoordsBtn.
  ///
  /// In zh, this message translates to:
  /// **'粘贴剪切板坐标'**
  String get manualAddPointPasteCoordsBtn;

  /// No description provided for @manualAddPointLatitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get manualAddPointLatitude;

  /// No description provided for @manualAddPointLatitudeHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 34.8917'**
  String get manualAddPointLatitudeHint;

  /// No description provided for @manualAddPointLongitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get manualAddPointLongitude;

  /// No description provided for @manualAddPointLongitudeHint.
  ///
  /// In zh, this message translates to:
  /// **'例如 135.8077'**
  String get manualAddPointLongitudeHint;

  /// No description provided for @manualAddPointBtnSaving.
  ///
  /// In zh, this message translates to:
  /// **'保存中'**
  String get manualAddPointBtnSaving;

  /// No description provided for @manualAddPointBtnSaveEdit.
  ///
  /// In zh, this message translates to:
  /// **'保存修改'**
  String get manualAddPointBtnSaveEdit;

  /// No description provided for @manualAddPointBtnSaveAdd.
  ///
  /// In zh, this message translates to:
  /// **'保存点位'**
  String get manualAddPointBtnSaveAdd;

  /// No description provided for @manualAddPointRequiredField.
  ///
  /// In zh, this message translates to:
  /// **'请填写此项'**
  String get manualAddPointRequiredField;

  /// No description provided for @manualAddPointRequiredLatitude.
  ///
  /// In zh, this message translates to:
  /// **'请填写纬度'**
  String get manualAddPointRequiredLatitude;

  /// No description provided for @manualAddPointRequiredLongitude.
  ///
  /// In zh, this message translates to:
  /// **'请填写经度'**
  String get manualAddPointRequiredLongitude;

  /// No description provided for @manualAddPointInvalidCoordinate.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效坐标'**
  String get manualAddPointInvalidCoordinate;

  /// No description provided for @manualAddPointSelectCoordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择点位坐标'**
  String get manualAddPointSelectCoordsTitle;

  /// No description provided for @manualAddPointSelectCoordsTooltipActive.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图选点'**
  String get manualAddPointSelectCoordsTooltipActive;

  /// No description provided for @manualAddPointSelectCoordsTooltipInactive.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选点'**
  String get manualAddPointSelectCoordsTooltipInactive;

  /// No description provided for @manualAddPointSelectCoordsHelpActive.
  ///
  /// In zh, this message translates to:
  /// **'点击地图任意位置设置点位坐标'**
  String get manualAddPointSelectCoordsHelpActive;

  /// No description provided for @manualAddPointSelectCoordsHelpInactive.
  ///
  /// In zh, this message translates to:
  /// **'先点击右上角选点按钮，再点击地图设置坐标'**
  String get manualAddPointSelectCoordsHelpInactive;

  /// No description provided for @manualAddPointSelectCoordsAdjustHelp.
  ///
  /// In zh, this message translates to:
  /// **'点击地图可继续调整位置'**
  String get manualAddPointSelectCoordsAdjustHelp;

  /// No description provided for @manualAddPointSelectCoordsDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'地图选点'**
  String get manualAddPointSelectCoordsDialogTitle;

  /// No description provided for @manualAddPointSelectCoordsBtnUse.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get manualAddPointSelectCoordsBtnUse;

  /// No description provided for @addPointsNoWorksHelp.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有作品。先添加作品，后续可按作品导入点位。'**
  String get addPointsNoWorksHelp;

  /// No description provided for @addPointsHasWorksHelp.
  ///
  /// In zh, this message translates to:
  /// **'当前计划已有 {count} 部作品：{list}'**
  String addPointsHasWorksHelp(int count, String list);

  /// No description provided for @addPointsRefImageTooltipPreview.
  ///
  /// In zh, this message translates to:
  /// **'查看大图'**
  String get addPointsRefImageTooltipPreview;

  /// No description provided for @addPointsRefImageTooltipEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无参考图'**
  String get addPointsRefImageTooltipEmpty;

  /// No description provided for @addPointsRefImageHeader.
  ///
  /// In zh, this message translates to:
  /// **'参考图片'**
  String get addPointsRefImageHeader;

  /// No description provided for @addPointsRefImageHelpSelected.
  ///
  /// In zh, this message translates to:
  /// **'已选择新图片，保存后生效。'**
  String get addPointsRefImageHelpSelected;

  /// No description provided for @addPointsRefImageHelpCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前参考图，重新选择后需保存才会生效。'**
  String get addPointsRefImageHelpCurrent;

  /// No description provided for @addPointsRefImageHelpEmpty.
  ///
  /// In zh, this message translates to:
  /// **'可选，保存时会复制到 App 本地目录。'**
  String get addPointsRefImageHelpEmpty;

  /// No description provided for @addPointsRefImageBtnReselect.
  ///
  /// In zh, this message translates to:
  /// **'重新选择'**
  String get addPointsRefImageBtnReselect;

  /// No description provided for @addPointsRefImageBtnUpload.
  ///
  /// In zh, this message translates to:
  /// **'上传参考图'**
  String get addPointsRefImageBtnUpload;

  /// No description provided for @addPointsRefImageBtnRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get addPointsRefImageBtnRemove;

  /// No description provided for @addPointsPointBtnAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加'**
  String get addPointsPointBtnAdded;

  /// No description provided for @addPointsPointBtnAdd.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get addPointsPointBtnAdd;

  /// No description provided for @managePlanTitle.
  ///
  /// In zh, this message translates to:
  /// **'管理计划'**
  String get managePlanTitle;

  /// No description provided for @managePlanSelectedCount.
  ///
  /// In zh, this message translates to:
  /// **'已选 {count}'**
  String managePlanSelectedCount(int count);

  /// No description provided for @managePlanTooltipAreas.
  ///
  /// In zh, this message translates to:
  /// **'片区管理'**
  String get managePlanTooltipAreas;

  /// No description provided for @managePlanCachingProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存完整参考图'**
  String get managePlanCachingProgress;

  /// No description provided for @managePlanCacheFullReference.
  ///
  /// In zh, this message translates to:
  /// **'缓存完整参考图'**
  String get managePlanCacheFullReference;

  /// No description provided for @managePlanTooltipExitSelection.
  ///
  /// In zh, this message translates to:
  /// **'退出多选'**
  String get managePlanTooltipExitSelection;

  /// No description provided for @managePlanTooltipSelection.
  ///
  /// In zh, this message translates to:
  /// **'多选'**
  String get managePlanTooltipSelection;

  /// No description provided for @msgNoAnchorForUnassigned.
  ///
  /// In zh, this message translates to:
  /// **'未分配点位没有关键点。'**
  String get msgNoAnchorForUnassigned;

  /// No description provided for @msgAreaNotExist.
  ///
  /// In zh, this message translates to:
  /// **'片区不存在。'**
  String get msgAreaNotExist;

  /// No description provided for @msgSaveAnchorFailed.
  ///
  /// In zh, this message translates to:
  /// **'关键点保存失败。'**
  String get msgSaveAnchorFailed;

  /// No description provided for @msgNoOrderForUnassigned.
  ///
  /// In zh, this message translates to:
  /// **'未分配点位不需要排序方式。'**
  String get msgNoOrderForUnassigned;

  /// No description provided for @managePlanAreaOrderTitle.
  ///
  /// In zh, this message translates to:
  /// **'片区内顺序'**
  String get managePlanAreaOrderTitle;

  /// No description provided for @msgSaveOrderModeFailed.
  ///
  /// In zh, this message translates to:
  /// **'排序方式保存失败。'**
  String get msgSaveOrderModeFailed;

  /// No description provided for @msgMoveAreaFailed.
  ///
  /// In zh, this message translates to:
  /// **'移动片区失败。'**
  String get msgMoveAreaFailed;

  /// No description provided for @msgOpenCameraFromPlanOrMap.
  ///
  /// In zh, this message translates to:
  /// **'请从计划页或地图页打开拍摄。'**
  String get msgOpenCameraFromPlanOrMap;

  /// No description provided for @msgSaveReferenceImageFailed.
  ///
  /// In zh, this message translates to:
  /// **'参考图保存失败。'**
  String get msgSaveReferenceImageFailed;

  /// No description provided for @labelUnknownArea.
  ///
  /// In zh, this message translates to:
  /// **'未知片区'**
  String get labelUnknownArea;

  /// No description provided for @managePlanMoveToAreaTitle.
  ///
  /// In zh, this message translates to:
  /// **'移动到片区'**
  String get managePlanMoveToAreaTitle;

  /// No description provided for @msgSavePointOrderFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位顺序保存失败。'**
  String get msgSavePointOrderFailed;

  /// No description provided for @dialogDeletePointTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除点位'**
  String get dialogDeletePointTitle;

  /// No description provided for @dialogDeletePointMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定从计划中删除「{name}」吗？'**
  String dialogDeletePointMsg(String name);

  /// No description provided for @msgDeletePointFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位删除失败。'**
  String get msgDeletePointFailed;

  /// No description provided for @dialogBulkDeletePointsTitle.
  ///
  /// In zh, this message translates to:
  /// **'批量删除点位'**
  String get dialogBulkDeletePointsTitle;

  /// No description provided for @dialogBulkDeletePointsMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定从计划中删除 {count} 个点位吗？'**
  String dialogBulkDeletePointsMsg(int count);

  /// No description provided for @msgBulkDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量删除失败。'**
  String get msgBulkDeleteFailed;

  /// No description provided for @msgSaveCurrentTargetFailed.
  ///
  /// In zh, this message translates to:
  /// **'当前目标保存失败。'**
  String get msgSaveCurrentTargetFailed;

  /// No description provided for @msgSaveCompletionStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'完成状态保存失败。'**
  String get msgSaveCompletionStatusFailed;

  /// No description provided for @msgSavePointStatusFailed.
  ///
  /// In zh, this message translates to:
  /// **'点位状态保存失败。'**
  String get msgSavePointStatusFailed;

  /// No description provided for @msgBulkCompleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量完成失败。'**
  String get msgBulkCompleteFailed;

  /// No description provided for @msgBulkResetFailed.
  ///
  /// In zh, this message translates to:
  /// **'批量重置失败。'**
  String get msgBulkResetFailed;

  /// No description provided for @msgFullReferenceCacheStarted.
  ///
  /// In zh, this message translates to:
  /// **'已开始缓存完整参考图。'**
  String get msgFullReferenceCacheStarted;

  /// No description provided for @msgCachingFullReferenceProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存完整参考图...'**
  String get msgCachingFullReferenceProgress;

  /// No description provided for @msgNoReferenceToCache.
  ///
  /// In zh, this message translates to:
  /// **'当前计划没有需要缓存的参考图。'**
  String get msgNoReferenceToCache;

  /// No description provided for @dialogCacheFullReferenceTitle.
  ///
  /// In zh, this message translates to:
  /// **'缓存完整参考图'**
  String get dialogCacheFullReferenceTitle;

  /// No description provided for @dialogCacheFullReferenceMsg.
  ///
  /// In zh, this message translates to:
  /// **'将缓存当前计划中 {count} 张完整参考图，可能需要较长时间和网络流量。'**
  String dialogCacheFullReferenceMsg(int count);

  /// No description provided for @btnStartCache.
  ///
  /// In zh, this message translates to:
  /// **'开始缓存'**
  String get btnStartCache;

  /// No description provided for @labelAnchorNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get labelAnchorNotSet;

  /// No description provided for @tooltipPrevArea.
  ///
  /// In zh, this message translates to:
  /// **'上一个片区'**
  String get tooltipPrevArea;

  /// No description provided for @tooltipNextArea.
  ///
  /// In zh, this message translates to:
  /// **'下一个片区'**
  String get tooltipNextArea;

  /// No description provided for @managePlanPointsPending.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位等待整理'**
  String managePlanPointsPending(int count);

  /// No description provided for @managePlanPointsStats.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个点位 · 已完成 {completed} · {num}/{total}'**
  String managePlanPointsStats(int count, int completed, int num, int total);

  /// No description provided for @managePlanAnchorLabel.
  ///
  /// In zh, this message translates to:
  /// **'关键点：{label}'**
  String managePlanAnchorLabel(String label);

  /// No description provided for @btnNearestAssign.
  ///
  /// In zh, this message translates to:
  /// **'最近分配'**
  String get btnNearestAssign;

  /// No description provided for @btnBoxSelectAssign.
  ///
  /// In zh, this message translates to:
  /// **'框选分配'**
  String get btnBoxSelectAssign;

  /// No description provided for @statusCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get statusCurrent;

  /// No description provided for @statusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In zh, this message translates to:
  /// **'待访问'**
  String get statusPending;

  /// No description provided for @tooltipPointActions.
  ///
  /// In zh, this message translates to:
  /// **'点位操作'**
  String get tooltipPointActions;

  /// No description provided for @btnMoveToArea.
  ///
  /// In zh, this message translates to:
  /// **'移动到片区'**
  String get btnMoveToArea;

  /// No description provided for @btnSetAsCurrent.
  ///
  /// In zh, this message translates to:
  /// **'设为当前'**
  String get btnSetAsCurrent;

  /// No description provided for @btnCancelCompletion.
  ///
  /// In zh, this message translates to:
  /// **'取消完成'**
  String get btnCancelCompletion;

  /// No description provided for @btnMarkCompletion.
  ///
  /// In zh, this message translates to:
  /// **'标记完成'**
  String get btnMarkCompletion;

  /// No description provided for @btnDeletePoint.
  ///
  /// In zh, this message translates to:
  /// **'删除点位'**
  String get btnDeletePoint;

  /// No description provided for @refStatusNone.
  ///
  /// In zh, this message translates to:
  /// **'无参考图'**
  String get refStatusNone;

  /// No description provided for @refStatusLocal.
  ///
  /// In zh, this message translates to:
  /// **'本地上传'**
  String get refStatusLocal;

  /// No description provided for @refStatusCached.
  ///
  /// In zh, this message translates to:
  /// **'已缓存'**
  String get refStatusCached;

  /// No description provided for @refStatusRemote.
  ///
  /// In zh, this message translates to:
  /// **'未缓存'**
  String get refStatusRemote;

  /// No description provided for @tooltipClearSelection.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get tooltipClearSelection;

  /// No description provided for @tooltipMoveArea.
  ///
  /// In zh, this message translates to:
  /// **'移动片区'**
  String get tooltipMoveArea;

  /// No description provided for @tooltipReset.
  ///
  /// In zh, this message translates to:
  /// **'重置'**
  String get tooltipReset;

  /// No description provided for @dialogSelectAnchorTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择关键点'**
  String get dialogSelectAnchorTitle;

  /// No description provided for @btnClear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get btnClear;

  /// No description provided for @tooltipCloseMapSelect.
  ///
  /// In zh, this message translates to:
  /// **'关闭地图点选'**
  String get tooltipCloseMapSelect;

  /// No description provided for @tooltipSelectOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图上选点'**
  String get tooltipSelectOnMap;

  /// No description provided for @tooltipInputCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'输入经纬度'**
  String get tooltipInputCoordinates;

  /// No description provided for @dialogInputCoordinatesTitle.
  ///
  /// In zh, this message translates to:
  /// **'输入经纬度'**
  String get dialogInputCoordinatesTitle;

  /// No description provided for @labelManualAnchor.
  ///
  /// In zh, this message translates to:
  /// **'手动关键点'**
  String get labelManualAnchor;

  /// No description provided for @tooltipSelectPoint.
  ///
  /// In zh, this message translates to:
  /// **'选择点位'**
  String get tooltipSelectPoint;

  /// No description provided for @labelAnchorNotSelected.
  ///
  /// In zh, this message translates to:
  /// **'尚未选择关键点'**
  String get labelAnchorNotSelected;

  /// No description provided for @msgClickMapToSetAnchor.
  ///
  /// In zh, this message translates to:
  /// **'点击地图任意位置设置关键点'**
  String get msgClickMapToSetAnchor;

  /// No description provided for @msgSelectAnchorMethods.
  ///
  /// In zh, this message translates to:
  /// **'可点选点位、地图或输入经纬度'**
  String get msgSelectAnchorMethods;

  /// No description provided for @managePlanNoPoints.
  ///
  /// In zh, this message translates to:
  /// **'还没有可以管理的点位'**
  String get managePlanNoPoints;

  /// No description provided for @dialogDiscardMemoTitle.
  ///
  /// In zh, this message translates to:
  /// **'放弃未保存内容？'**
  String get dialogDiscardMemoTitle;

  /// No description provided for @dialogDiscardMemoMsg.
  ///
  /// In zh, this message translates to:
  /// **'当前备忘录还有未保存的修改。'**
  String get dialogDiscardMemoMsg;

  /// No description provided for @btnKeepEditing.
  ///
  /// In zh, this message translates to:
  /// **'继续编辑'**
  String get btnKeepEditing;

  /// No description provided for @btnDiscard.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get btnDiscard;

  /// No description provided for @msgMemoSaved.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录已保存。'**
  String get msgMemoSaved;

  /// No description provided for @msgMemoSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录保存失败。'**
  String get msgMemoSaveFailed;

  /// No description provided for @msgTodoStatusSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'待办状态保存失败。'**
  String get msgTodoStatusSaveFailed;

  /// No description provided for @memoPlaceholderHeading.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get memoPlaceholderHeading;

  /// No description provided for @memoPlaceholderBold.
  ///
  /// In zh, this message translates to:
  /// **'加粗文字'**
  String get memoPlaceholderBold;

  /// No description provided for @memoPlaceholderListItem.
  ///
  /// In zh, this message translates to:
  /// **'列表项'**
  String get memoPlaceholderListItem;

  /// No description provided for @memoPlaceholderTodo.
  ///
  /// In zh, this message translates to:
  /// **'待办事项'**
  String get memoPlaceholderTodo;

  /// No description provided for @memoPlaceholderQuote.
  ///
  /// In zh, this message translates to:
  /// **'引用内容'**
  String get memoPlaceholderQuote;

  /// No description provided for @memoPlaceholderLinkText.
  ///
  /// In zh, this message translates to:
  /// **'链接文字'**
  String get memoPlaceholderLinkText;

  /// No description provided for @memoPlaceholderCode.
  ///
  /// In zh, this message translates to:
  /// **'代码'**
  String get memoPlaceholderCode;

  /// No description provided for @msgInvalidLinkFormat.
  ///
  /// In zh, this message translates to:
  /// **'链接格式不正确。'**
  String get msgInvalidLinkFormat;

  /// No description provided for @msgUnableToOpenLink.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接。'**
  String get msgUnableToOpenLink;

  /// No description provided for @planMemoTitle.
  ///
  /// In zh, this message translates to:
  /// **'计划备忘录'**
  String get planMemoTitle;

  /// No description provided for @labelMemoContent.
  ///
  /// In zh, this message translates to:
  /// **'备忘录内容'**
  String get labelMemoContent;

  /// No description provided for @hintMemoContent.
  ///
  /// In zh, this message translates to:
  /// **'可以记录交通、预约、补拍事项、同行安排等。'**
  String get hintMemoContent;

  /// No description provided for @tooltipHeading.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get tooltipHeading;

  /// No description provided for @tooltipBold.
  ///
  /// In zh, this message translates to:
  /// **'加粗'**
  String get tooltipBold;

  /// No description provided for @tooltipList.
  ///
  /// In zh, this message translates to:
  /// **'列表'**
  String get tooltipList;

  /// No description provided for @tooltipTodo.
  ///
  /// In zh, this message translates to:
  /// **'待办'**
  String get tooltipTodo;

  /// No description provided for @tooltipQuote.
  ///
  /// In zh, this message translates to:
  /// **'引用'**
  String get tooltipQuote;

  /// No description provided for @tooltipDivider.
  ///
  /// In zh, this message translates to:
  /// **'分割线'**
  String get tooltipDivider;

  /// No description provided for @tooltipLink.
  ///
  /// In zh, this message translates to:
  /// **'链接'**
  String get tooltipLink;

  /// No description provided for @tooltipCode.
  ///
  /// In zh, this message translates to:
  /// **'代码'**
  String get tooltipCode;

  /// No description provided for @tooltipUncheck.
  ///
  /// In zh, this message translates to:
  /// **'取消勾选'**
  String get tooltipUncheck;

  /// No description provided for @msgMemoImageNotSupported.
  ///
  /// In zh, this message translates to:
  /// **'备忘录不支持图片：{label}'**
  String msgMemoImageNotSupported(String label);

  /// No description provided for @memoEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有写计划备忘'**
  String get memoEmptyTitle;

  /// No description provided for @memoEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击右上角编辑，记录交通、预约、补拍事项或其他准备内容。'**
  String get memoEmptySubtitle;

  /// No description provided for @msgInvalidRatio.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效比例。'**
  String get msgInvalidRatio;

  /// No description provided for @dialogCustomRatioTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义比例'**
  String get dialogCustomRatioTitle;

  /// No description provided for @labelWidth.
  ///
  /// In zh, this message translates to:
  /// **'宽'**
  String get labelWidth;

  /// No description provided for @labelHeight.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get labelHeight;

  /// No description provided for @msgColorNameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入颜色名称。'**
  String get msgColorNameRequired;

  /// No description provided for @dialogCustomThemeColorTitle.
  ///
  /// In zh, this message translates to:
  /// **'自定义主题色'**
  String get dialogCustomThemeColorTitle;

  /// No description provided for @labelColorName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get labelColorName;

  /// No description provided for @labelColorHex.
  ///
  /// In zh, this message translates to:
  /// **'色号'**
  String get labelColorHex;

  /// No description provided for @btnAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get btnAdd;

  /// No description provided for @navAppGoogleMaps.
  ///
  /// In zh, this message translates to:
  /// **'Google Maps'**
  String get navAppGoogleMaps;

  /// No description provided for @navAppAmap.
  ///
  /// In zh, this message translates to:
  /// **'高德地图'**
  String get navAppAmap;

  /// No description provided for @navAppAppleMaps.
  ///
  /// In zh, this message translates to:
  /// **'Apple Maps'**
  String get navAppAppleMaps;

  /// No description provided for @navAppBaiduMaps.
  ///
  /// In zh, this message translates to:
  /// **'百度地图'**
  String get navAppBaiduMaps;

  /// No description provided for @navAppTencentMaps.
  ///
  /// In zh, this message translates to:
  /// **'腾讯地图'**
  String get navAppTencentMaps;

  /// No description provided for @navAppBrowser.
  ///
  /// In zh, this message translates to:
  /// **'浏览器'**
  String get navAppBrowser;

  /// No description provided for @navAppGoogleMapsSub.
  ///
  /// In zh, this message translates to:
  /// **'默认选项'**
  String get navAppGoogleMapsSub;

  /// No description provided for @navAppAmapSub.
  ///
  /// In zh, this message translates to:
  /// **'国内常用'**
  String get navAppAmapSub;

  /// No description provided for @navAppAppleMapsSub.
  ///
  /// In zh, this message translates to:
  /// **'iOS 原生'**
  String get navAppAppleMapsSub;

  /// No description provided for @navAppBaiduMapsSub.
  ///
  /// In zh, this message translates to:
  /// **'城市导航'**
  String get navAppBaiduMapsSub;

  /// No description provided for @navAppTencentMapsSub.
  ///
  /// In zh, this message translates to:
  /// **'轻量备选'**
  String get navAppTencentMapsSub;

  /// No description provided for @navAppBrowserSub.
  ///
  /// In zh, this message translates to:
  /// **'网页打开'**
  String get navAppBrowserSub;

  /// No description provided for @comparisonBorderColorWhite.
  ///
  /// In zh, this message translates to:
  /// **'白色'**
  String get comparisonBorderColorWhite;

  /// No description provided for @comparisonBorderColorBlack.
  ///
  /// In zh, this message translates to:
  /// **'黑色'**
  String get comparisonBorderColorBlack;

  /// No description provided for @comparisonBorderColorTheme.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get comparisonBorderColorTheme;

  /// No description provided for @comparisonWidthLabel.
  ///
  /// In zh, this message translates to:
  /// **'宽度 {label}'**
  String comparisonWidthLabel(String label);

  /// No description provided for @comparisonNoBorder.
  ///
  /// In zh, this message translates to:
  /// **'无边框'**
  String get comparisonNoBorder;

  /// No description provided for @comparisonBorderPercent.
  ///
  /// In zh, this message translates to:
  /// **'边框 {percent}%'**
  String comparisonBorderPercent(String percent);

  /// No description provided for @comparisonShowLabels.
  ///
  /// In zh, this message translates to:
  /// **'显示标签'**
  String get comparisonShowLabels;

  /// No description provided for @comparisonHideLabels.
  ///
  /// In zh, this message translates to:
  /// **'不显示标签'**
  String get comparisonHideLabels;

  /// No description provided for @comparisonPilgrimName.
  ///
  /// In zh, this message translates to:
  /// **'巡礼者 {name}'**
  String comparisonPilgrimName(String name);

  /// No description provided for @comparisonSectionAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get comparisonSectionAppearance;

  /// No description provided for @comparisonFieldBorderWidth.
  ///
  /// In zh, this message translates to:
  /// **'边框宽度'**
  String get comparisonFieldBorderWidth;

  /// No description provided for @comparisonBorderWidthNone.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get comparisonBorderWidthNone;

  /// No description provided for @comparisonFieldBorderColor.
  ///
  /// In zh, this message translates to:
  /// **'边框颜色'**
  String get comparisonFieldBorderColor;

  /// No description provided for @comparisonFieldOutputWidth.
  ///
  /// In zh, this message translates to:
  /// **'输出宽度'**
  String get comparisonFieldOutputWidth;

  /// No description provided for @comparisonLabelShowLabel.
  ///
  /// In zh, this message translates to:
  /// **'显示标签'**
  String get comparisonLabelShowLabel;

  /// No description provided for @comparisonSectionMetadata.
  ///
  /// In zh, this message translates to:
  /// **'元数据'**
  String get comparisonSectionMetadata;

  /// No description provided for @comparisonFieldPilgrimName.
  ///
  /// In zh, this message translates to:
  /// **'巡礼者名字'**
  String get comparisonFieldPilgrimName;

  /// No description provided for @comparisonShowPilgrimRight.
  ///
  /// In zh, this message translates to:
  /// **'在右侧显示巡礼者'**
  String get comparisonShowPilgrimRight;

  /// No description provided for @comparisonShowGradingBottom.
  ///
  /// In zh, this message translates to:
  /// **'底部显示调色参数'**
  String get comparisonShowGradingBottom;

  /// No description provided for @comparisonLabelReference.
  ///
  /// In zh, this message translates to:
  /// **'参考'**
  String get comparisonLabelReference;

  /// No description provided for @comparisonLabelCaptured.
  ///
  /// In zh, this message translates to:
  /// **'巡礼'**
  String get comparisonLabelCaptured;

  /// No description provided for @comparisonLabelPilgrim.
  ///
  /// In zh, this message translates to:
  /// **'巡礼者'**
  String get comparisonLabelPilgrim;

  /// No description provided for @comparisonExportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出对比图'**
  String get comparisonExportTitle;

  /// No description provided for @tooltipClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get tooltipClose;

  /// No description provided for @comparisonExporting.
  ///
  /// In zh, this message translates to:
  /// **'导出中...'**
  String get comparisonExporting;

  /// No description provided for @comparisonExport.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get comparisonExport;

  /// No description provided for @comparisonWidthAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get comparisonWidthAuto;

  /// No description provided for @comparisonMetaCapturedAt.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时间'**
  String get comparisonMetaCapturedAt;

  /// No description provided for @comparisonMetaWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get comparisonMetaWork;

  /// No description provided for @comparisonMetaPoint.
  ///
  /// In zh, this message translates to:
  /// **'地点'**
  String get comparisonMetaPoint;

  /// No description provided for @comparisonMetaCoordinates.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get comparisonMetaCoordinates;

  /// No description provided for @comparisonMetaEpisode.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get comparisonMetaEpisode;

  /// No description provided for @comparisonErrRefUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'参考图不可用，无法导出对比图片。'**
  String get comparisonErrRefUnavailable;

  /// No description provided for @comparisonErrCapturedUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图不可用，无法导出对比图片。'**
  String get comparisonErrCapturedUnavailable;

  /// No description provided for @comparisonErrRenderFailed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败，请稍后重试。'**
  String get comparisonErrRenderFailed;

  /// No description provided for @cameraFallbackRatioTitle.
  ///
  /// In zh, this message translates to:
  /// **'无参考图时比例'**
  String get cameraFallbackRatioTitle;

  /// No description provided for @btnEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get btnEdit;

  /// No description provided for @cameraRefModeOverlay.
  ///
  /// In zh, this message translates to:
  /// **'叠影'**
  String get cameraRefModeOverlay;

  /// No description provided for @cameraRefModeSplit.
  ///
  /// In zh, this message translates to:
  /// **'上下'**
  String get cameraRefModeSplit;

  /// No description provided for @cameraRefModePinned.
  ///
  /// In zh, this message translates to:
  /// **'小窗'**
  String get cameraRefModePinned;

  /// No description provided for @cameraWebPreviewWarning.
  ///
  /// In zh, this message translates to:
  /// **'Web 预览不启动实时相机。'**
  String get cameraWebPreviewWarning;

  /// No description provided for @workManagerEmptyHelp.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有作品。'**
  String get workManagerEmptyHelp;

  /// No description provided for @dialogDeleteWorkTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除作品'**
  String get dialogDeleteWorkTitle;

  /// No description provided for @dialogDeleteWorkConfirmSingle.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」吗？'**
  String dialogDeleteWorkConfirmSingle(Object name);

  /// No description provided for @dialogDeleteWorkConfirmMultiple.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」吗？这会同时移除 {count} 个相关点位和对应记录。'**
  String dialogDeleteWorkConfirmMultiple(Object count, Object name);

  /// No description provided for @msgDeleteWorkFailed.
  ///
  /// In zh, this message translates to:
  /// **'作品删除失败'**
  String get msgDeleteWorkFailed;

  /// No description provided for @tooltipDeleteWork.
  ///
  /// In zh, this message translates to:
  /// **'删除作品'**
  String get tooltipDeleteWork;

  /// No description provided for @labelWorkTitleText.
  ///
  /// In zh, this message translates to:
  /// **'作品名称'**
  String get labelWorkTitleText;

  /// No description provided for @labelWorkInfoText.
  ///
  /// In zh, this message translates to:
  /// **'作品信息'**
  String get labelWorkInfoText;

  /// No description provided for @btnManualAdd.
  ///
  /// In zh, this message translates to:
  /// **'手动添加'**
  String get btnManualAdd;

  /// No description provided for @btnBangumiSearch.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi'**
  String get btnBangumiSearch;

  /// No description provided for @labelBangumiSource.
  ///
  /// In zh, this message translates to:
  /// **'Bangumi #{bangumiId}'**
  String labelBangumiSource(int bangumiId);

  /// No description provided for @subjectTypeBook.
  ///
  /// In zh, this message translates to:
  /// **'书籍'**
  String get subjectTypeBook;

  /// No description provided for @subjectTypeAnime.
  ///
  /// In zh, this message translates to:
  /// **'动画'**
  String get subjectTypeAnime;

  /// No description provided for @subjectTypeMusic.
  ///
  /// In zh, this message translates to:
  /// **'音乐'**
  String get subjectTypeMusic;

  /// No description provided for @subjectTypeGame.
  ///
  /// In zh, this message translates to:
  /// **'游戏'**
  String get subjectTypeGame;

  /// No description provided for @subjectTypeReal.
  ///
  /// In zh, this message translates to:
  /// **'三次元'**
  String get subjectTypeReal;

  /// No description provided for @labelPoints.
  ///
  /// In zh, this message translates to:
  /// **'点位'**
  String get labelPoints;

  /// No description provided for @mapImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'从作品地图导入'**
  String get mapImportTitle;

  /// No description provided for @mapImportRefreshingCache.
  ///
  /// In zh, this message translates to:
  /// **'正在清除缓存并重新加载 Anitabi 点位…'**
  String get mapImportRefreshingCache;

  /// No description provided for @mapImportManualWorkNoBangumiId.
  ///
  /// In zh, this message translates to:
  /// **'手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。'**
  String get mapImportManualWorkNoBangumiId;

  /// No description provided for @mapImportPointAddedMsg.
  ///
  /// In zh, this message translates to:
  /// **'已加入计划，可继续选择点位。'**
  String get mapImportPointAddedMsg;

  /// No description provided for @mapImportPointAddFailedMsg.
  ///
  /// In zh, this message translates to:
  /// **'点位导入失败，请稍后重试。'**
  String get mapImportPointAddFailedMsg;

  /// No description provided for @mapImportAllAddedMsg.
  ///
  /// In zh, this message translates to:
  /// **'已添加所有未加入的点位。'**
  String get mapImportAllAddedMsg;

  /// No description provided for @mapImportBatchFailedMsg.
  ///
  /// In zh, this message translates to:
  /// **'批量导入失败，请稍后重试。'**
  String get mapImportBatchFailedMsg;

  /// No description provided for @mapImportBoxSelectionEmptyMsg.
  ///
  /// In zh, this message translates to:
  /// **'框选范围内没有可添加点位'**
  String get mapImportBoxSelectionEmptyMsg;

  /// No description provided for @mapImportBoxAddedMsg.
  ///
  /// In zh, this message translates to:
  /// **'已添加框选点位。'**
  String get mapImportBoxAddedMsg;

  /// No description provided for @mapImportBoxFailedMsg.
  ///
  /// In zh, this message translates to:
  /// **'框选点位导入失败，请稍后重试。'**
  String get mapImportBoxFailedMsg;

  /// No description provided for @mapImportImportingMsg.
  ///
  /// In zh, this message translates to:
  /// **'正在导入 {count} 个点位…'**
  String mapImportImportingMsg(int count);

  /// No description provided for @mapImportCachingProgressMsg.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存缩略图 {processed}/{total}，成功 {succeeded}'**
  String mapImportCachingProgressMsg(int processed, int total, int succeeded);

  /// No description provided for @mapImportPartialSuccessMsg.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个点位，缩略图缓存 {cached}/{total}，其余稍后会自动补齐。'**
  String mapImportPartialSuccessMsg(int count, int cached, int total);

  /// No description provided for @mapImportAddAllDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加所有点位'**
  String get mapImportAddAllDialogTitle;

  /// No description provided for @mapImportAddAllDialogMsg.
  ///
  /// In zh, this message translates to:
  /// **'将把当前作品中 {count} 个还不在计划里的点位加入计划，并暂时放在未分组。'**
  String mapImportAddAllDialogMsg(int count);

  /// No description provided for @mapImportAddAllConfirmLabel.
  ///
  /// In zh, this message translates to:
  /// **'添加全部'**
  String get mapImportAddAllConfirmLabel;

  /// No description provided for @mapImportAddBoxDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加框选点位'**
  String get mapImportAddBoxDialogTitle;

  /// No description provided for @mapImportAddBoxDialogMsg.
  ///
  /// In zh, this message translates to:
  /// **'将把框选范围内 {count} 个还不在计划里的点位加入计划，并暂时放在未分组。'**
  String mapImportAddBoxDialogMsg(int count);

  /// No description provided for @mapImportAddBoxBtnLabel.
  ///
  /// In zh, this message translates to:
  /// **'添加框选'**
  String get mapImportAddBoxBtnLabel;

  /// No description provided for @mapImportAddBoxBtnWithCount.
  ///
  /// In zh, this message translates to:
  /// **'添加 {count} 个'**
  String mapImportAddBoxBtnWithCount(int count);

  /// No description provided for @mapImportOrganizeDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'整理刚导入的点位'**
  String get mapImportOrganizeDialogTitle;

  /// No description provided for @mapImportOrganizeDialogMsg.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个点位，并暂时放在未分组。可以先创建片区和关键点，再按最近关键点快速分配。'**
  String mapImportOrganizeDialogMsg(int count);

  /// No description provided for @mapImportOrganizeNearestAssign.
  ///
  /// In zh, this message translates to:
  /// **'最近分配'**
  String get mapImportOrganizeNearestAssign;

  /// No description provided for @mapImportOrganizeGroupManager.
  ///
  /// In zh, this message translates to:
  /// **'片区管理'**
  String get mapImportOrganizeGroupManager;

  /// No description provided for @mapImportOrganizeLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后'**
  String get mapImportOrganizeLater;

  /// No description provided for @mapImportRefreshTooltip.
  ///
  /// In zh, this message translates to:
  /// **'清除缓存并重新加载 Anitabi 点位'**
  String get mapImportRefreshTooltip;

  /// No description provided for @mapImportMarkerTooltip.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位'**
  String get mapImportMarkerTooltip;

  /// No description provided for @mapImportErrDataUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 地图数据无法加载'**
  String get mapImportErrDataUnavailable;

  /// No description provided for @mapImportErrPartialData.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位只加载到一部分'**
  String get mapImportErrPartialData;

  /// No description provided for @mapImportErrNotFound.
  ///
  /// In zh, this message translates to:
  /// **'这个 Bangumi 条目暂无 Anitabi 地图数据'**
  String get mapImportErrNotFound;

  /// No description provided for @mapImportErrLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 点位加载失败'**
  String get mapImportErrLoadFailed;

  /// No description provided for @mapImportErrDataUnavailableDetailWeb.
  ///
  /// In zh, this message translates to:
  /// **'可能是 Anitabi 地图数据缓存版本不一致，或当前预览服务网络请求被拦截。请清除缓存并重新加载 Anitabi 点位。'**
  String get mapImportErrDataUnavailableDetailWeb;

  /// No description provided for @mapImportErrDataUnavailableDetail.
  ///
  /// In zh, this message translates to:
  /// **'无法读取 Anitabi 地图索引。请检查网络连接，或清除缓存并重新加载 Anitabi 点位。'**
  String get mapImportErrDataUnavailableDetail;

  /// No description provided for @mapImportErrPartialDataDetail.
  ///
  /// In zh, this message translates to:
  /// **'当前只取得 {loaded} / 共 {expected} 个点位。请重新加载，或检查网络是否能访问 Anitabi 地图数据。'**
  String mapImportErrPartialDataDetail(int loaded, int expected);

  /// No description provided for @mapImportErrNotFoundDetail.
  ///
  /// In zh, this message translates to:
  /// **'可以尝试在作品管理中添加同名的原作、游戏或其他关联条目。'**
  String get mapImportErrNotFoundDetail;

  /// No description provided for @mapImportErrLoadFailedDetail.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络后重试，或稍后再重新加载。'**
  String get mapImportErrLoadFailedDetail;

  /// No description provided for @mapImportProgressImporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导入 {total} 个点位…'**
  String mapImportProgressImporting(int total);

  /// No description provided for @mapImportProgressCaching.
  ///
  /// In zh, this message translates to:
  /// **'正在缓存缩略图 {processed}/{total}，成功 {succeeded}'**
  String mapImportProgressCaching(int processed, int total, int succeeded);

  /// No description provided for @mapImportMarkerImportedTooltip.
  ///
  /// In zh, this message translates to:
  /// **'已导入点位'**
  String get mapImportMarkerImportedTooltip;

  /// No description provided for @mapImportMarkerAvailableTooltip.
  ///
  /// In zh, this message translates to:
  /// **'可导入点位'**
  String get mapImportMarkerAvailableTooltip;

  /// No description provided for @mapImportSummaryLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 Anitabi 点位'**
  String get mapImportSummaryLoading;

  /// No description provided for @mapImportSummaryStats.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {imported} / 当前显示 {displayed}{expectedPart}'**
  String mapImportSummaryStats(
    int imported,
    int displayed,
    String expectedPart,
  );

  /// No description provided for @mapImportSummaryExpectedPart.
  ///
  /// In zh, this message translates to:
  /// **' / 共 {expected}'**
  String mapImportSummaryExpectedPart(int expected);

  /// No description provided for @mapImportSummaryTooltipAddAll.
  ///
  /// In zh, this message translates to:
  /// **'添加所有点位'**
  String get mapImportSummaryTooltipAddAll;

  /// No description provided for @mapImportSummaryTooltipBoxExit.
  ///
  /// In zh, this message translates to:
  /// **'退出框选'**
  String get mapImportSummaryTooltipBoxExit;

  /// No description provided for @mapImportSummaryTooltipBoxStart.
  ///
  /// In zh, this message translates to:
  /// **'框选点位'**
  String get mapImportSummaryTooltipBoxStart;

  /// No description provided for @mapImportPointNameLabel.
  ///
  /// In zh, this message translates to:
  /// **'点位名称'**
  String get mapImportPointNameLabel;

  /// No description provided for @mapImportPointInfoLabel.
  ///
  /// In zh, this message translates to:
  /// **'点位信息'**
  String get mapImportPointInfoLabel;

  /// No description provided for @mapImportPointOriginLabel.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get mapImportPointOriginLabel;

  /// No description provided for @mapImportPointDetailBtn.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get mapImportPointDetailBtn;

  /// No description provided for @mapImportPointJoinedBtn.
  ///
  /// In zh, this message translates to:
  /// **'已加入'**
  String get mapImportPointJoinedBtn;

  /// No description provided for @mapImportPointJoinBtn.
  ///
  /// In zh, this message translates to:
  /// **'加入计划'**
  String get mapImportPointJoinBtn;

  /// No description provided for @mapImportDetailSceneLabel.
  ///
  /// In zh, this message translates to:
  /// **'场景'**
  String get mapImportDetailSceneLabel;

  /// No description provided for @mapImportDetailNoteLabel.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get mapImportDetailNoteLabel;

  /// No description provided for @mapImportDetailCoordLabel.
  ///
  /// In zh, this message translates to:
  /// **'坐标'**
  String get mapImportDetailCoordLabel;

  /// No description provided for @mapImportDetailJoinedBtn.
  ///
  /// In zh, this message translates to:
  /// **'已加入计划'**
  String get mapImportDetailJoinedBtn;

  /// No description provided for @mapImportNoPointSelectedHint.
  ///
  /// In zh, this message translates to:
  /// **'点击地图上的点位查看缩略图和详情。'**
  String get mapImportNoPointSelectedHint;

  /// No description provided for @mapImportNoImportablePoints.
  ///
  /// In zh, this message translates to:
  /// **'当前作品没有可导入的 Anitabi 点位。'**
  String get mapImportNoImportablePoints;

  /// No description provided for @mapImportNoImagePoints.
  ///
  /// In zh, this message translates to:
  /// **'当前作品共有 {count} 个点位，但没有可导入的带图参考点位。'**
  String mapImportNoImagePoints(int count);

  /// No description provided for @mapImportEmptyNoWorks.
  ///
  /// In zh, this message translates to:
  /// **'当前计划还没有 Bangumi 作品。请先到作品管理添加 Bangumi 作品。'**
  String get mapImportEmptyNoWorks;

  /// No description provided for @mapImportManualWorkState.
  ///
  /// In zh, this message translates to:
  /// **'手动添加的作品没有 Bangumi ID，无法从 Anitabi 地图导入点位。\n\n请通过 Bangumi/Anitabi 搜索添加作品，或使用手动添加点位。'**
  String get mapImportManualWorkState;

  /// No description provided for @mapImportLoadingWorksAndPoints.
  ///
  /// In zh, this message translates to:
  /// **'正在加载 Anitabi 作品和点位'**
  String get mapImportLoadingWorksAndPoints;

  /// No description provided for @msgCannotOpenMapApp.
  ///
  /// In zh, this message translates to:
  /// **'无法打开{app}。'**
  String msgCannotOpenMapApp(Object app);

  /// No description provided for @mapImportErrPointNotFound.
  ///
  /// In zh, this message translates to:
  /// **'没有找到这个 Anitabi 点位'**
  String get mapImportErrPointNotFound;

  /// No description provided for @mapImportErrPointNotFoundDetail.
  ///
  /// In zh, this message translates to:
  /// **'链接里的点位 ID 可能已失效，或 Anitabi 地图数据尚未同步。'**
  String get mapImportErrPointNotFoundDetail;

  /// No description provided for @navMapSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'导航地图 {app}'**
  String navMapSectionTitle(Object app);

  /// No description provided for @navAppDescGoogleMaps.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过 Google Maps 官方 Maps URL 打开步行路线。'**
  String get navAppDescGoogleMaps;

  /// No description provided for @navAppDescAppleMaps.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过 Apple Map Links 打开步行路线。'**
  String get navAppDescAppleMaps;

  /// No description provided for @navAppDescAmap.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过高德 URI API 打开步行路线，并使用 WGS84 坐标。'**
  String get navAppDescAmap;

  /// No description provided for @navAppDescBaiduMaps.
  ///
  /// In zh, this message translates to:
  /// **'导航按钮会通过百度地图 URI API 打开步行路线，并使用 WGS84 坐标。'**
  String get navAppDescBaiduMaps;

  /// No description provided for @mapProviderHintOpenFreeMap.
  ///
  /// In zh, this message translates to:
  /// **'推荐默认'**
  String get mapProviderHintOpenFreeMap;

  /// No description provided for @mapProviderHintOsm.
  ///
  /// In zh, this message translates to:
  /// **'标准瓦片'**
  String get mapProviderHintOsm;

  /// No description provided for @mapProviderHintCustomXyz.
  ///
  /// In zh, this message translates to:
  /// **'瓦片模板'**
  String get mapProviderHintCustomXyz;

  /// No description provided for @mapProviderHintCustomStyle.
  ///
  /// In zh, this message translates to:
  /// **'样式 URL'**
  String get mapProviderHintCustomStyle;

  /// No description provided for @anitabiSrcAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动选择'**
  String get anitabiSrcAuto;

  /// No description provided for @anitabiSrcOfficial.
  ///
  /// In zh, this message translates to:
  /// **'官方默认'**
  String get anitabiSrcOfficial;

  /// No description provided for @anitabiSrcMirror.
  ///
  /// In zh, this message translates to:
  /// **'备用源'**
  String get anitabiSrcMirror;

  /// No description provided for @anitabiSrcAutoDesc.
  ///
  /// In zh, this message translates to:
  /// **'优先使用 image.anitabi.cn；如果下载到错误页或被拦截，会尝试 img-tc.anitabi.cn。'**
  String get anitabiSrcAutoDesc;

  /// No description provided for @anitabiSrcOfficialDesc.
  ///
  /// In zh, this message translates to:
  /// **'固定使用 image.anitabi.cn，保留 Anitabi 官方默认图片源。'**
  String get anitabiSrcOfficialDesc;

  /// No description provided for @anitabiSrcMirrorDesc.
  ///
  /// In zh, this message translates to:
  /// **'固定使用 img-tc.anitabi.cn，适合官方默认源经常被拦截时使用。'**
  String get anitabiSrcMirrorDesc;

  /// No description provided for @tabExplore.
  ///
  /// In zh, this message translates to:
  /// **'探索'**
  String get tabExplore;

  /// No description provided for @exploreSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索作品、地名、城市'**
  String get exploreSearchHint;

  /// No description provided for @exploreMyWorks.
  ///
  /// In zh, this message translates to:
  /// **'我的作品'**
  String get exploreMyWorks;

  /// No description provided for @exploreHotWorks.
  ///
  /// In zh, this message translates to:
  /// **'热门作品'**
  String get exploreHotWorks;

  /// No description provided for @exploreCollectionKyotoAnimation.
  ///
  /// In zh, this message translates to:
  /// **'京阿尼名作选'**
  String get exploreCollectionKyotoAnimation;

  /// No description provided for @exploreCollectionMakotoShinkai.
  ///
  /// In zh, this message translates to:
  /// **'新海诚剧场'**
  String get exploreCollectionMakotoShinkai;

  /// No description provided for @explorePointCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个地点'**
  String explorePointCount(int count);

  /// No description provided for @exploreEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无作品数据'**
  String get exploreEmpty;

  /// No description provided for @exploreLoadError.
  ///
  /// In zh, this message translates to:
  /// **'作品数据加载失败，请检查网络后重试'**
  String get exploreLoadError;

  /// No description provided for @tabProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabProfile;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的巡礼'**
  String get profileTitle;

  /// No description provided for @profileStatCheckins.
  ///
  /// In zh, this message translates to:
  /// **'打卡'**
  String get profileStatCheckins;

  /// No description provided for @profileWorks.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get profileWorks;

  /// No description provided for @profileCities.
  ///
  /// In zh, this message translates to:
  /// **'城市'**
  String get profileCities;

  /// No description provided for @profileFootprints.
  ///
  /// In zh, this message translates to:
  /// **'足迹'**
  String get profileFootprints;

  /// No description provided for @profileCheckinTimes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 次打卡'**
  String profileCheckinTimes(int count);

  /// No description provided for @profileEmptyFootprints.
  ///
  /// In zh, this message translates to:
  /// **'还没有打卡记录'**
  String get profileEmptyFootprints;

  /// No description provided for @profileEmptyWorks.
  ///
  /// In zh, this message translates to:
  /// **'还没有打卡过的作品'**
  String get profileEmptyWorks;

  /// No description provided for @profileEmptyCities.
  ///
  /// In zh, this message translates to:
  /// **'还没有去过的城市'**
  String get profileEmptyCities;

  /// No description provided for @profileManageRecords.
  ///
  /// In zh, this message translates to:
  /// **'管理记录'**
  String get profileManageRecords;

  /// No description provided for @profileFavorites.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get profileFavorites;

  /// No description provided for @profileFavoritesSoon.
  ///
  /// In zh, this message translates to:
  /// **'敬请期待'**
  String get profileFavoritesSoon;

  /// No description provided for @exploreAddToPlan.
  ///
  /// In zh, this message translates to:
  /// **'添加到计划'**
  String get exploreAddToPlan;

  /// No description provided for @exploreAddWorkPoints.
  ///
  /// In zh, this message translates to:
  /// **'将导入 {count} 个巡礼点'**
  String exploreAddWorkPoints(int count);

  /// No description provided for @exploreImporting.
  ///
  /// In zh, this message translates to:
  /// **'正在导入…'**
  String get exploreImporting;

  /// No description provided for @exploreImportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个巡礼点'**
  String exploreImportSuccess(int count);

  /// No description provided for @exploreImportNoPoints.
  ///
  /// In zh, this message translates to:
  /// **'已添加作品，暂无巡礼点'**
  String get exploreImportNoPoints;

  /// No description provided for @exploreImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败，请检查网络后重试'**
  String get exploreImportFailed;

  /// No description provided for @exploreViewOnMap.
  ///
  /// In zh, this message translates to:
  /// **'在地图查看'**
  String get exploreViewOnMap;

  /// No description provided for @smartPartition.
  ///
  /// In zh, this message translates to:
  /// **'智能分区'**
  String get smartPartition;

  /// No description provided for @partitionByDistance.
  ///
  /// In zh, this message translates to:
  /// **'按距离'**
  String get partitionByDistance;

  /// No description provided for @partitionByCount.
  ///
  /// In zh, this message translates to:
  /// **'按组数'**
  String get partitionByCount;

  /// No description provided for @partitionThreshold.
  ///
  /// In zh, this message translates to:
  /// **'距离阈值'**
  String get partitionThreshold;

  /// No description provided for @partitionGroups.
  ///
  /// In zh, this message translates to:
  /// **'片区数'**
  String get partitionGroups;

  /// No description provided for @partitionGenerate.
  ///
  /// In zh, this message translates to:
  /// **'生成片区'**
  String get partitionGenerate;

  /// No description provided for @partitionGenerating.
  ///
  /// In zh, this message translates to:
  /// **'生成中…'**
  String get partitionGenerating;

  /// No description provided for @partitionGroupName.
  ///
  /// In zh, this message translates to:
  /// **'片区 {index}'**
  String partitionGroupName(int index);

  /// No description provided for @partitionSummary.
  ///
  /// In zh, this message translates to:
  /// **'将分成 {groups} 个片区 · 共 {points} 个点位'**
  String partitionSummary(int groups, int points);

  /// No description provided for @partitionSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已生成 {count} 个片区'**
  String partitionSuccess(int count);

  /// No description provided for @partitionFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成片区失败'**
  String get partitionFailed;

  /// No description provided for @partitionAreaNearStation.
  ///
  /// In zh, this message translates to:
  /// **'{station}附近'**
  String partitionAreaNearStation(String station);

  /// No description provided for @exploreImportWithAreas.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个巡礼点 · {areas} 个片区'**
  String exploreImportWithAreas(int count, int areas);

  /// No description provided for @planNameForWork.
  ///
  /// In zh, this message translates to:
  /// **'{title} 巡礼'**
  String planNameForWork(String title);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'ms',
    'pt',
    'ru',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
