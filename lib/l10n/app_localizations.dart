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
  /// **'深湖蓝'**
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
  /// **'蜜蜡橙'**
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

  /// No description provided for @btnCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get btnCopy;

  /// No description provided for @btnShare.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get btnShare;

  /// No description provided for @btnView.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get btnView;

  /// No description provided for @imageViewerSaveTitle.
  ///
  /// In zh, this message translates to:
  /// **'保存图片'**
  String get imageViewerSaveTitle;

  /// No description provided for @imageViewerSaveToGallery.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get imageViewerSaveToGallery;

  /// No description provided for @imageViewerLoading.
  ///
  /// In zh, this message translates to:
  /// **'图片加载中'**
  String get imageViewerLoading;

  /// No description provided for @imageViewerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无图片'**
  String get imageViewerEmpty;

  /// No description provided for @imageViewerUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'图片暂不可用'**
  String get imageViewerUnavailable;

  /// No description provided for @imageViewerReadFailed.
  ///
  /// In zh, this message translates to:
  /// **'图片读取失败'**
  String get imageViewerReadFailed;

  /// No description provided for @imageViewerSaved.
  ///
  /// In zh, this message translates to:
  /// **'图片已保存'**
  String get imageViewerSaved;

  /// No description provided for @imageViewerSavedToGallery.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册'**
  String get imageViewerSavedToGallery;

  /// No description provided for @imageViewerSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get imageViewerSaveFailed;

  /// No description provided for @imageViewerSaveCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消保存'**
  String get imageViewerSaveCancelled;

  /// No description provided for @appShellPlanFileImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划文件导入失败'**
  String get appShellPlanFileImportFailed;

  /// No description provided for @appShellPlanLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'计划加载失败'**
  String get appShellPlanLoadFailed;

  /// No description provided for @appShellPlanLoading.
  ///
  /// In zh, this message translates to:
  /// **'正在加载巡礼计划'**
  String get appShellPlanLoading;

  /// No description provided for @appShellRetryHint.
  ///
  /// In zh, this message translates to:
  /// **'请稍后重试。'**
  String get appShellRetryHint;

  /// No description provided for @appShellLoadingHint.
  ///
  /// In zh, this message translates to:
  /// **'准备今日点位和当前目标。'**
  String get appShellLoadingHint;

  /// No description provided for @recordDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'记录详情'**
  String get recordDetailTitle;

  /// No description provided for @recordDetailAutoGrading.
  ///
  /// In zh, this message translates to:
  /// **'自动调色'**
  String get recordDetailAutoGrading;

  /// No description provided for @recordDetailDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除记录'**
  String get recordDetailDelete;

  /// No description provided for @recordDetailViewPoint.
  ///
  /// In zh, this message translates to:
  /// **'查看点位详情'**
  String get recordDetailViewPoint;

  /// No description provided for @recordDetailDeleteConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'只删除这条巡礼记录，不会改变点位完成状态。'**
  String get recordDetailDeleteConfirmBody;

  /// No description provided for @recordDetailDeletePhotoFile.
  ///
  /// In zh, this message translates to:
  /// **'同时删除照片文件'**
  String get recordDetailDeletePhotoFile;

  /// No description provided for @recordDetailExportPrefUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前平台暂不支持保存导出偏好。'**
  String get recordDetailExportPrefUnsupported;

  /// No description provided for @recordDetailPointMissing.
  ///
  /// In zh, this message translates to:
  /// **'这条记录对应的点位已不在当前计划中，照片和导出功能仍然可以使用。'**
  String get recordDetailPointMissing;

  /// No description provided for @pointRecordsTitle.
  ///
  /// In zh, this message translates to:
  /// **'点位拍摄记录'**
  String get pointRecordsTitle;

  /// No description provided for @pointRecordsCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 条'**
  String pointRecordsCount(int count);

  /// No description provided for @pointRecordsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'这个点位还没有拍摄记录'**
  String get pointRecordsEmpty;

  /// No description provided for @labelUngrouped.
  ///
  /// In zh, this message translates to:
  /// **'未分组'**
  String get labelUngrouped;

  /// No description provided for @labelGraded.
  ///
  /// In zh, this message translates to:
  /// **'已调色'**
  String get labelGraded;

  /// No description provided for @labelOriginal.
  ///
  /// In zh, this message translates to:
  /// **'原图'**
  String get labelOriginal;

  /// No description provided for @gradingBrightness.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get gradingBrightness;

  /// No description provided for @gradingExposure.
  ///
  /// In zh, this message translates to:
  /// **'曝光'**
  String get gradingExposure;

  /// No description provided for @gradingContrast.
  ///
  /// In zh, this message translates to:
  /// **'对比'**
  String get gradingContrast;

  /// No description provided for @gradingSaturation.
  ///
  /// In zh, this message translates to:
  /// **'饱和'**
  String get gradingSaturation;

  /// No description provided for @gradingTemperature.
  ///
  /// In zh, this message translates to:
  /// **'色温'**
  String get gradingTemperature;

  /// No description provided for @gradingTint.
  ///
  /// In zh, this message translates to:
  /// **'色调'**
  String get gradingTint;

  /// No description provided for @gradingHighlights.
  ///
  /// In zh, this message translates to:
  /// **'高光'**
  String get gradingHighlights;

  /// No description provided for @gradingShadows.
  ///
  /// In zh, this message translates to:
  /// **'阴影'**
  String get gradingShadows;

  /// No description provided for @gradingRedShadow.
  ///
  /// In zh, this message translates to:
  /// **'R暗'**
  String get gradingRedShadow;

  /// No description provided for @gradingRedMid.
  ///
  /// In zh, this message translates to:
  /// **'R中'**
  String get gradingRedMid;

  /// No description provided for @gradingRedHighlight.
  ///
  /// In zh, this message translates to:
  /// **'R亮'**
  String get gradingRedHighlight;

  /// No description provided for @gradingGreenShadow.
  ///
  /// In zh, this message translates to:
  /// **'G暗'**
  String get gradingGreenShadow;

  /// No description provided for @gradingGreenMid.
  ///
  /// In zh, this message translates to:
  /// **'G中'**
  String get gradingGreenMid;

  /// No description provided for @gradingGreenHighlight.
  ///
  /// In zh, this message translates to:
  /// **'G亮'**
  String get gradingGreenHighlight;

  /// No description provided for @gradingBlueShadow.
  ///
  /// In zh, this message translates to:
  /// **'B暗'**
  String get gradingBlueShadow;

  /// No description provided for @gradingBlueMid.
  ///
  /// In zh, this message translates to:
  /// **'B中'**
  String get gradingBlueMid;

  /// No description provided for @gradingBlueHighlight.
  ///
  /// In zh, this message translates to:
  /// **'B亮'**
  String get gradingBlueHighlight;

  /// No description provided for @recordDetailCapturedPhoto.
  ///
  /// In zh, this message translates to:
  /// **'巡礼图'**
  String get recordDetailCapturedPhoto;

  /// No description provided for @failedToReadPilgrimagePhoto2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to read pilgrimage photo'**
  String get failedToReadPilgrimagePhoto2;

  /// No description provided for @noReferenceImageAvailableForAuto2.
  ///
  /// In zh, this message translates to:
  /// **'No reference image available for auto color match'**
  String get noReferenceImageAvailableForAuto2;

  /// No description provided for @autoColorMatchFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Auto color match failed'**
  String get autoColorMatchFailed2;

  /// No description provided for @autoColorParametersGenerated2.
  ///
  /// In zh, this message translates to:
  /// **'Auto color parameters generated'**
  String get autoColorParametersGenerated2;

  /// No description provided for @revertedToOriginalPhoto2.
  ///
  /// In zh, this message translates to:
  /// **'Reverted to original photo'**
  String get revertedToOriginalPhoto2;

  /// No description provided for @matchTheColorToneAutomaticallyFirst2.
  ///
  /// In zh, this message translates to:
  /// **'Match the color tone automatically first'**
  String get matchTheColorToneAutomaticallyFirst2;

  /// No description provided for @colorGradingResultSaved2.
  ///
  /// In zh, this message translates to:
  /// **'Color grading result saved'**
  String get colorGradingResultSaved2;

  /// No description provided for @failedToReadPhoto2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to read photo'**
  String get failedToReadPhoto2;

  /// No description provided for @matching2.
  ///
  /// In zh, this message translates to:
  /// **'Matching…'**
  String get matching2;

  /// No description provided for @autoMatchTone2.
  ///
  /// In zh, this message translates to:
  /// **'Auto match tone'**
  String get autoMatchTone2;

  /// No description provided for @reference2.
  ///
  /// In zh, this message translates to:
  /// **'Reference'**
  String get reference2;

  /// No description provided for @noReferenceImage2.
  ///
  /// In zh, this message translates to:
  /// **'No reference image'**
  String get noReferenceImage2;

  /// No description provided for @original2.
  ///
  /// In zh, this message translates to:
  /// **'Original'**
  String get original2;

  /// No description provided for @graded3.
  ///
  /// In zh, this message translates to:
  /// **'Graded'**
  String get graded3;

  /// No description provided for @showingOriginal2.
  ///
  /// In zh, this message translates to:
  /// **'Showing original'**
  String get showingOriginal2;

  /// No description provided for @holdToShowOriginal2.
  ///
  /// In zh, this message translates to:
  /// **'Hold to show original'**
  String get holdToShowOriginal2;

  /// No description provided for @matchMode2.
  ///
  /// In zh, this message translates to:
  /// **'Match mode'**
  String get matchMode2;

  /// No description provided for @restoredLastColorGradingParameters2.
  ///
  /// In zh, this message translates to:
  /// **'Restored last color grading parameters'**
  String get restoredLastColorGradingParameters2;

  /// No description provided for @saveTheGradedResultAfterAuto2.
  ///
  /// In zh, this message translates to:
  /// **'Save the graded result after auto matching'**
  String get saveTheGradedResultAfterAuto2;

  /// No description provided for @toneMatching2.
  ///
  /// In zh, this message translates to:
  /// **'Tone matching'**
  String get toneMatching2;

  /// No description provided for @gradingIntensity2.
  ///
  /// In zh, this message translates to:
  /// **'Grading intensity'**
  String get gradingIntensity2;

  /// No description provided for @gradingParameters2.
  ///
  /// In zh, this message translates to:
  /// **'Grading parameters'**
  String get gradingParameters2;

  /// No description provided for @showsTheParametersActuallyAppliedAt2.
  ///
  /// In zh, this message translates to:
  /// **'Shows the parameters actually applied at the current grading intensity.'**
  String get showsTheParametersActuallyAppliedAt2;

  /// No description provided for @contrast2.
  ///
  /// In zh, this message translates to:
  /// **'Contrast'**
  String get contrast2;

  /// No description provided for @saturation2.
  ///
  /// In zh, this message translates to:
  /// **'Saturation'**
  String get saturation2;

  /// No description provided for @redShadows2.
  ///
  /// In zh, this message translates to:
  /// **'Red shadows'**
  String get redShadows2;

  /// No description provided for @redMidtones2.
  ///
  /// In zh, this message translates to:
  /// **'Red midtones'**
  String get redMidtones2;

  /// No description provided for @redHighlights2.
  ///
  /// In zh, this message translates to:
  /// **'Red highlights'**
  String get redHighlights2;

  /// No description provided for @greenShadows2.
  ///
  /// In zh, this message translates to:
  /// **'Green shadows'**
  String get greenShadows2;

  /// No description provided for @greenMidtones2.
  ///
  /// In zh, this message translates to:
  /// **'Green midtones'**
  String get greenMidtones2;

  /// No description provided for @greenHighlights2.
  ///
  /// In zh, this message translates to:
  /// **'Green highlights'**
  String get greenHighlights2;

  /// No description provided for @blueShadows2.
  ///
  /// In zh, this message translates to:
  /// **'Blue shadows'**
  String get blueShadows2;

  /// No description provided for @blueMidtones2.
  ///
  /// In zh, this message translates to:
  /// **'Blue midtones'**
  String get blueMidtones2;

  /// No description provided for @blueHighlights2.
  ///
  /// In zh, this message translates to:
  /// **'Blue highlights'**
  String get blueHighlights2;

  /// No description provided for @saveResult2.
  ///
  /// In zh, this message translates to:
  /// **'Save result'**
  String get saveResult2;

  /// No description provided for @afterSavingTheRecordDetailAnd2.
  ///
  /// In zh, this message translates to:
  /// **'After saving, the record detail and export use the graded photo; the original and grading parameters are kept.'**
  String get afterSavingTheRecordDetailAnd2;

  /// No description provided for @saving2.
  ///
  /// In zh, this message translates to:
  /// **'Saving…'**
  String get saving2;

  /// No description provided for @saveColorGrading2.
  ///
  /// In zh, this message translates to:
  /// **'Save color grading'**
  String get saveColorGrading2;

  /// No description provided for @manualOrder2.
  ///
  /// In zh, this message translates to:
  /// **'Manual order'**
  String get manualOrder2;

  /// No description provided for @noAssignablePointsWithinTheCurrent2.
  ///
  /// In zh, this message translates to:
  /// **'No assignable points within the current distance'**
  String get noAssignablePointsWithinTheCurrent2;

  /// No description provided for @confirmNearestAssignment2.
  ///
  /// In zh, this message translates to:
  /// **'Confirm nearest assignment'**
  String get confirmNearestAssignment2;

  /// No description provided for @startAssigning2.
  ///
  /// In zh, this message translates to:
  /// **'Start assigning'**
  String get startAssigning2;

  /// No description provided for @nearestAssignmentFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Nearest assignment failed'**
  String get nearestAssignmentFailed2;

  /// No description provided for @finishAreaAssignmentFirst2.
  ///
  /// In zh, this message translates to:
  /// **'Finish area assignment first'**
  String get finishAreaAssignmentFirst2;

  /// No description provided for @createAnAreaFirst2.
  ///
  /// In zh, this message translates to:
  /// **'Create an area first'**
  String get createAnAreaFirst2;

  /// No description provided for @noUngroupedPointsInTheSelection2.
  ///
  /// In zh, this message translates to:
  /// **'No ungrouped points in the selection'**
  String get noUngroupedPointsInTheSelection2;

  /// No description provided for @confirmBoxSelectionAssignment2.
  ///
  /// In zh, this message translates to:
  /// **'Confirm box selection assignment'**
  String get confirmBoxSelectionAssignment2;

  /// No description provided for @assign2.
  ///
  /// In zh, this message translates to:
  /// **'Assign'**
  String get assign2;

  /// No description provided for @boxSelectionAssignmentFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Box selection assignment failed'**
  String get boxSelectionAssignmentFailed2;

  /// No description provided for @selectArea2.
  ///
  /// In zh, this message translates to:
  /// **'Select area'**
  String get selectArea2;

  /// No description provided for @finishBoxSelection2.
  ///
  /// In zh, this message translates to:
  /// **'Finish box selection'**
  String get finishBoxSelection2;

  /// No description provided for @boxSelect2.
  ///
  /// In zh, this message translates to:
  /// **'Box select'**
  String get boxSelect2;

  /// No description provided for @assigning2.
  ///
  /// In zh, this message translates to:
  /// **'Assigning…'**
  String get assigning2;

  /// No description provided for @ungroupedPointsAreAssignedToThe2.
  ///
  /// In zh, this message translates to:
  /// **'Ungrouped points are assigned to the nearest area anchor within the maximum distance.'**
  String get ungroupedPointsAreAssignedToThe2;

  /// No description provided for @noAvailableAreaAnchors2.
  ///
  /// In zh, this message translates to:
  /// **'No available area anchors'**
  String get noAvailableAreaAnchors2;

  /// No description provided for @createAnAreaFirstUseSmart2.
  ///
  /// In zh, this message translates to:
  /// **'Create an area first (use “Smart Partition” for one-tap generation)'**
  String get createAnAreaFirstUseSmart2;

  /// No description provided for @assignablePoints2.
  ///
  /// In zh, this message translates to:
  /// **'Assignable points'**
  String get assignablePoints2;

  /// No description provided for @pointsOutOfRange2.
  ///
  /// In zh, this message translates to:
  /// **'Points out of range'**
  String get pointsOutOfRange2;

  /// No description provided for @eGHttpsWwAnitabiCn2.
  ///
  /// In zh, this message translates to:
  /// **'e.g. https://ww.anitabi.cn/map?bangumiId=8290&pid=qdmnf6iqj'**
  String get eGHttpsWwAnitabiCn2;

  /// No description provided for @thisWorkWasNotFoundOn2.
  ///
  /// In zh, this message translates to:
  /// **'This work was not found on Anitabi'**
  String get thisWorkWasNotFoundOn2;

  /// No description provided for @thisWorkHasNoAnitabiPoints2.
  ///
  /// In zh, this message translates to:
  /// **'This work has no Anitabi points yet'**
  String get thisWorkHasNoAnitabiPoints2;

  /// No description provided for @thisBangumiEntryHasNoMatching2.
  ///
  /// In zh, this message translates to:
  /// **'This Bangumi entry has no matching work in Anitabi\'s map data. Try adding the same anime, original work, or a related entry.'**
  String get thisBangumiEntryHasNoMatching2;

  /// No description provided for @theWorkExistsOnAnitabiBut2.
  ///
  /// In zh, this message translates to:
  /// **'The work exists on Anitabi, but there are no importable map points yet.'**
  String get theWorkExistsOnAnitabiBut2;

  /// No description provided for @newArea2.
  ///
  /// In zh, this message translates to:
  /// **'New area'**
  String get newArea2;

  /// No description provided for @areaCreationFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Area creation failed'**
  String get areaCreationFailed2;

  /// No description provided for @renameArea2.
  ///
  /// In zh, this message translates to:
  /// **'Rename area'**
  String get renameArea2;

  /// No description provided for @areaName2.
  ///
  /// In zh, this message translates to:
  /// **'Area name'**
  String get areaName2;

  /// No description provided for @areaRenameFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Area rename failed'**
  String get areaRenameFailed2;

  /// No description provided for @failedToSaveSortOrder2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to save sort order'**
  String get failedToSaveSortOrder2;

  /// No description provided for @failedToGenerateRecommendedRoute2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to generate recommended route'**
  String get failedToGenerateRecommendedRoute2;

  /// No description provided for @failedToSaveAnchor2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to save anchor'**
  String get failedToSaveAnchor2;

  /// No description provided for @deleteArea2.
  ///
  /// In zh, this message translates to:
  /// **'Delete area'**
  String get deleteArea2;

  /// No description provided for @areaDeletionFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Area deletion failed'**
  String get areaDeletionFailed2;

  /// No description provided for @failedToSaveAreaOrder2.
  ///
  /// In zh, this message translates to:
  /// **'Failed to save area order'**
  String get failedToSaveAreaOrder2;

  /// No description provided for @ungroupedPoints2.
  ///
  /// In zh, this message translates to:
  /// **'Ungrouped points'**
  String get ungroupedPoints2;

  /// No description provided for @areaNameCannotBeEmpty2.
  ///
  /// In zh, this message translates to:
  /// **'Area name cannot be empty'**
  String get areaNameCannotBeEmpty2;

  /// No description provided for @create2.
  ///
  /// In zh, this message translates to:
  /// **'Create'**
  String get create2;

  /// No description provided for @areaActions2.
  ///
  /// In zh, this message translates to:
  /// **'Area actions'**
  String get areaActions2;

  /// No description provided for @rename2.
  ///
  /// In zh, this message translates to:
  /// **'Rename'**
  String get rename2;

  /// No description provided for @setAnchor2.
  ///
  /// In zh, this message translates to:
  /// **'Set anchor'**
  String get setAnchor2;

  /// No description provided for @switchToUnordered2.
  ///
  /// In zh, this message translates to:
  /// **'Switch to unordered'**
  String get switchToUnordered2;

  /// No description provided for @switchToManualOrder2.
  ///
  /// In zh, this message translates to:
  /// **'Switch to manual order'**
  String get switchToManualOrder2;

  /// No description provided for @importContent2.
  ///
  /// In zh, this message translates to:
  /// **'Import content'**
  String get importContent2;

  /// No description provided for @chooseWhatToImport2.
  ///
  /// In zh, this message translates to:
  /// **'Choose what to import'**
  String get chooseWhatToImport2;

  /// No description provided for @importingWillNotModifyCurrentData2.
  ///
  /// In zh, this message translates to:
  /// **'Importing will not modify current data.'**
  String get importingWillNotModifyCurrentData2;

  /// No description provided for @planStructure2.
  ///
  /// In zh, this message translates to:
  /// **'Plan structure'**
  String get planStructure2;

  /// No description provided for @worksAreasPointsCompletionStatusAnd2.
  ///
  /// In zh, this message translates to:
  /// **'Works, areas, points, completion status, and current target.'**
  String get worksAreasPointsCompletionStatusAnd2;

  /// No description provided for @captureRecords2.
  ///
  /// In zh, this message translates to:
  /// **'Capture records'**
  String get captureRecords2;

  /// No description provided for @v1FilesContainNoPhotoAssets2.
  ///
  /// In zh, this message translates to:
  /// **'v1 files contain no photo assets; only the plan structure is imported.'**
  String get v1FilesContainNoPhotoAssets2;

  /// No description provided for @thisPackageHasNoCaptureRecords2.
  ///
  /// In zh, this message translates to:
  /// **'This package has no capture records.'**
  String get thisPackageHasNoCaptureRecords2;

  /// No description provided for @imagesAndResourceFiles2.
  ///
  /// In zh, this message translates to:
  /// **'Images and resource files'**
  String get imagesAndResourceFiles2;

  /// No description provided for @packageNotes2.
  ///
  /// In zh, this message translates to:
  /// **'Package notes'**
  String get packageNotes2;

  /// No description provided for @missingOrCompatibilityInfoRecordedDuring2.
  ///
  /// In zh, this message translates to:
  /// **'Missing or compatibility info recorded during export.'**
  String get missingOrCompatibilityInfoRecordedDuring2;

  /// No description provided for @importing2.
  ///
  /// In zh, this message translates to:
  /// **'Importing…'**
  String get importing2;

  /// No description provided for @importSelected2.
  ///
  /// In zh, this message translates to:
  /// **'Import selected'**
  String get importSelected2;

  /// No description provided for @importFailed2.
  ///
  /// In zh, this message translates to:
  /// **'Import failed'**
  String get importFailed2;

  /// No description provided for @thisPackageHasNoRecoverableResource2.
  ///
  /// In zh, this message translates to:
  /// **'This package has no recoverable resource files.'**
  String get thisPackageHasNoRecoverableResource2;

  /// No description provided for @resourcesWereRecordedButNoRecoverable2.
  ///
  /// In zh, this message translates to:
  /// **'Resources were recorded, but no recoverable resource files are present.'**
  String get resourcesWereRecordedButNoRecoverable2;

  /// No description provided for @resources2.
  ///
  /// In zh, this message translates to:
  /// **'Resources'**
  String get resources2;

  /// No description provided for @version2.
  ///
  /// In zh, this message translates to:
  /// **'Version'**
  String get version2;

  /// No description provided for @pointName2.
  ///
  /// In zh, this message translates to:
  /// **'Point name'**
  String get pointName2;

  /// No description provided for @subtitle2.
  ///
  /// In zh, this message translates to:
  /// **'Subtitle'**
  String get subtitle2;

  /// No description provided for @episodeScene2.
  ///
  /// In zh, this message translates to:
  /// **'Episode / Scene'**
  String get episodeScene2;

  /// No description provided for @sourceId2.
  ///
  /// In zh, this message translates to:
  /// **'Source ID'**
  String get sourceId2;

  /// No description provided for @referenceImageUrl2.
  ///
  /// In zh, this message translates to:
  /// **'Reference image URL'**
  String get referenceImageUrl2;

  /// No description provided for @recordCount2.
  ///
  /// In zh, this message translates to:
  /// **'Record count'**
  String get recordCount2;

  /// No description provided for @yes2.
  ///
  /// In zh, this message translates to:
  /// **'Yes'**
  String get yes2;

  /// No description provided for @no2.
  ///
  /// In zh, this message translates to:
  /// **'No'**
  String get no2;

  /// No description provided for @recordId2.
  ///
  /// In zh, this message translates to:
  /// **'Record ID'**
  String get recordId2;

  /// No description provided for @referenceMode2.
  ///
  /// In zh, this message translates to:
  /// **'Reference mode'**
  String get referenceMode2;

  /// No description provided for @graded4.
  ///
  /// In zh, this message translates to:
  /// **'Graded?'**
  String get graded4;

  /// No description provided for @photoFileName2.
  ///
  /// In zh, this message translates to:
  /// **'Photo file name'**
  String get photoFileName2;

  /// No description provided for @gradedPhotoFileName2.
  ///
  /// In zh, this message translates to:
  /// **'Graded photo file name'**
  String get gradedPhotoFileName2;

  /// No description provided for @customXyzUrlMustIncludeZ2.
  ///
  /// In zh, this message translates to:
  /// **'Custom XYZ URL must include {z}, {x}, {y} and use http/https.'**
  String customXyzUrlMustIncludeZ2(Object x, Object y, Object z);

  /// No description provided for @customMaplibreStyleUrlMustUse2.
  ///
  /// In zh, this message translates to:
  /// **'Custom MapLibre style URL must use http/https.'**
  String get customMaplibreStyleUrlMustUse2;

  /// No description provided for @photoImportFailedPleaseChooseAgain2.
  ///
  /// In zh, this message translates to:
  /// **'Photo import failed, please choose again.'**
  String get photoImportFailedPleaseChooseAgain2;

  /// No description provided for @readingReferenceRatioPleaseWaitBefore2.
  ///
  /// In zh, this message translates to:
  /// **'Reading reference ratio, please wait before capturing.'**
  String get readingReferenceRatioPleaseWaitBefore2;

  /// No description provided for @cameraPermissionRequired2.
  ///
  /// In zh, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermissionRequired2;

  /// No description provided for @nativeCameraFailedToInitialize2.
  ///
  /// In zh, this message translates to:
  /// **'Native camera failed to initialize'**
  String get nativeCameraFailedToInitialize2;

  /// No description provided for @switchToLandscapeUi2.
  ///
  /// In zh, this message translates to:
  /// **'Switch to landscape UI'**
  String get switchToLandscapeUi2;

  /// No description provided for @importFromAlbum3.
  ///
  /// In zh, this message translates to:
  /// **'Import from album'**
  String get importFromAlbum3;

  /// No description provided for @switchCamera3.
  ///
  /// In zh, this message translates to:
  /// **'Switch camera'**
  String get switchCamera3;

  /// No description provided for @switchToPortraitUi2.
  ///
  /// In zh, this message translates to:
  /// **'Switch to portrait UI'**
  String get switchToPortraitUi2;

  /// No description provided for @checkPhoto2.
  ///
  /// In zh, this message translates to:
  /// **'Check photo'**
  String get checkPhoto2;

  /// No description provided for @flash2.
  ///
  /// In zh, this message translates to:
  /// **'Flash'**
  String get flash2;

  /// No description provided for @switchCamera4.
  ///
  /// In zh, this message translates to:
  /// **'Switch camera'**
  String get switchCamera4;

  /// No description provided for @importFromAlbum4.
  ///
  /// In zh, this message translates to:
  /// **'Import from album'**
  String get importFromAlbum4;

  /// No description provided for @iosNativeCameraDidNotStart2.
  ///
  /// In zh, this message translates to:
  /// **'iOS native camera did not start'**
  String get iosNativeCameraDidNotStart2;

  /// No description provided for @savingRecord2.
  ///
  /// In zh, this message translates to:
  /// **'Saving record…'**
  String get savingRecord2;

  /// No description provided for @backingUpPilgrimagePhotos2.
  ///
  /// In zh, this message translates to:
  /// **'Backing up pilgrimage photos…'**
  String get backingUpPilgrimagePhotos2;

  /// No description provided for @generatingComparison2.
  ///
  /// In zh, this message translates to:
  /// **'Generating comparison…'**
  String get generatingComparison2;

  /// No description provided for @updatingPointStatus2.
  ///
  /// In zh, this message translates to:
  /// **'Updating point status…'**
  String get updatingPointStatus2;

  /// No description provided for @savingTheRecordPleaseWait2.
  ///
  /// In zh, this message translates to:
  /// **'Saving the record, please wait.'**
  String get savingTheRecordPleaseWait2;

  /// No description provided for @confirmRecord2.
  ///
  /// In zh, this message translates to:
  /// **'Confirm record'**
  String get confirmRecord2;

  /// No description provided for @saveRecord2.
  ///
  /// In zh, this message translates to:
  /// **'Save record'**
  String get saveRecord2;

  /// No description provided for @saveAndMarkComplete2.
  ///
  /// In zh, this message translates to:
  /// **'Save and mark complete'**
  String get saveAndMarkComplete2;

  /// No description provided for @savedAndMarkedComplete2.
  ///
  /// In zh, this message translates to:
  /// **'Saved and marked complete'**
  String get savedAndMarkedComplete2;

  /// No description provided for @recordSaved2.
  ///
  /// In zh, this message translates to:
  /// **'Record saved'**
  String get recordSaved2;

  /// No description provided for @saveFailedPleaseTryAgainLater2.
  ///
  /// In zh, this message translates to:
  /// **'Save failed, please try again later.'**
  String get saveFailedPleaseTryAgainLater2;

  /// No description provided for @loadingReference2.
  ///
  /// In zh, this message translates to:
  /// **'Loading reference…'**
  String get loadingReference2;

  /// No description provided for @referenceTemporarilyUnavailable2.
  ///
  /// In zh, this message translates to:
  /// **'Reference temporarily unavailable'**
  String get referenceTemporarilyUnavailable2;

  /// No description provided for @anitripPhoto2.
  ///
  /// In zh, this message translates to:
  /// **'anitrip photo'**
  String get anitripPhoto2;

  /// No description provided for @willAssignCountUngroupedPointsTo2.
  ///
  /// In zh, this message translates to:
  /// **'Will assign {count} ungrouped points to the nearest area anchor, max distance {dist}.'**
  String willAssignCountUngroupedPointsTo2(Object count, Object dist);

  /// No description provided for @assignedCountPoints2.
  ///
  /// In zh, this message translates to:
  /// **'Assigned {count} points'**
  String assignedCountPoints2(Object count);

  /// No description provided for @willMovePointsUngroupedPointsTo2.
  ///
  /// In zh, this message translates to:
  /// **'Will move {points} ungrouped points to “{group}”.'**
  String willMovePointsUngroupedPointsTo2(Object group, Object points);

  /// No description provided for @assignedPointsPoints2.
  ///
  /// In zh, this message translates to:
  /// **'Assigned {points} points'**
  String assignedPointsPoints2(Object points);

  /// No description provided for @selectedSelUngroupedUng2.
  ///
  /// In zh, this message translates to:
  /// **'Selected {sel} / Ungrouped {ung}'**
  String selectedSelUngroupedUng2(Object sel, Object ung);

  /// No description provided for @maxDistanceDistAssignableAUng2.
  ///
  /// In zh, this message translates to:
  /// **'Max distance {dist} · Assignable {a} / {ung}'**
  String maxDistanceDistAssignableAUng2(Object a, Object dist, Object ung);

  /// No description provided for @ungUngroupedTapAMapPoint2.
  ///
  /// In zh, this message translates to:
  /// **'{ung} ungrouped · tap a map point for details'**
  String ungUngroupedTapAMapPoint2(Object ung);

  /// No description provided for @workHasNoImportableAnitabiPoints2.
  ///
  /// In zh, this message translates to:
  /// **'“{work}” has no importable Anitabi points yet.'**
  String workHasNoImportableAnitabiPoints2(Object work);

  /// No description provided for @deleteGroupItsCountPointsWill2.
  ///
  /// In zh, this message translates to:
  /// **'Delete “{group}”? Its {count} points will move to ungrouped.'**
  String deleteGroupItsCountPointsWill2(Object count, Object group);

  /// No description provided for @groupsAreasPointsPoints2.
  ///
  /// In zh, this message translates to:
  /// **'{groups} areas · {points} points'**
  String groupsAreasPointsPoints2(Object groups, Object points);

  /// No description provided for @pointsPointsAnchorOrder2.
  ///
  /// In zh, this message translates to:
  /// **'{points} points · {anchor} · {order}'**
  String pointsPointsAnchorOrder2(Object anchor, Object order, Object points);

  /// No description provided for @countPointsAwaitingOrganization2.
  ///
  /// In zh, this message translates to:
  /// **'{count} points awaiting organization'**
  String countPointsAwaitingOrganization2(Object count);

  /// No description provided for @recordsRecordsIncludingPhotoPathsAnd2.
  ///
  /// In zh, this message translates to:
  /// **'{records} records, including photo paths and grading parameters.'**
  String recordsRecordsIncludingPhotoPathsAnd2(Object records);

  /// No description provided for @importedPlanPlan2.
  ///
  /// In zh, this message translates to:
  /// **'Imported plan “{plan}”'**
  String importedPlanPlan2(Object plan);

  /// No description provided for @importedPlanPlanSomeResourcesWere2.
  ///
  /// In zh, this message translates to:
  /// **'Imported plan “{plan}”; some resources were not restored'**
  String importedPlanPlanSomeResourcesWere2(Object plan);

  /// No description provided for @thePackageHasCountResourceFiles3.
  ///
  /// In zh, this message translates to:
  /// **'The package has {count} resource files; this platform cannot restore them yet.'**
  String thePackageHasCountResourceFiles3(Object count);

  /// No description provided for @thePackageHasCountResourceFiles4.
  ///
  /// In zh, this message translates to:
  /// **'The package has {count} resource files and they will be restored to local storage.'**
  String thePackageHasCountResourceFiles4(Object count);

  /// No description provided for @countLandmarks2.
  ///
  /// In zh, this message translates to:
  /// **'{count} landmarks'**
  String countLandmarks2(Object count);

  /// No description provided for @countScreenshots2.
  ///
  /// In zh, this message translates to:
  /// **'{count} screenshots'**
  String countScreenshots2(Object count);

  /// No description provided for @nativeCameraFailedToInitializeError2.
  ///
  /// In zh, this message translates to:
  /// **'Native camera failed to initialize: {error}'**
  String nativeCameraFailedToInitializeError2(Object error);

  /// No description provided for @savingRecordStage.
  ///
  /// In zh, this message translates to:
  /// **'保存记录中...'**
  String get savingRecordStage;

  /// No description provided for @backingUpPilgrimagePhotoStage.
  ///
  /// In zh, this message translates to:
  /// **'备份巡礼照片中...'**
  String get backingUpPilgrimagePhotoStage;

  /// No description provided for @generatingComparisonImageStage.
  ///
  /// In zh, this message translates to:
  /// **'生成对比图中...'**
  String get generatingComparisonImageStage;

  /// No description provided for @updatingPointStatusStage.
  ///
  /// In zh, this message translates to:
  /// **'更新点位状态中...'**
  String get updatingPointStatusStage;

  /// No description provided for @savingRecordPleaseWait.
  ///
  /// In zh, this message translates to:
  /// **'正在保存记录，请稍候。'**
  String get savingRecordPleaseWait;

  /// No description provided for @confirmRecordTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认记录'**
  String get confirmRecordTitle;

  /// No description provided for @saveRecord.
  ///
  /// In zh, this message translates to:
  /// **'保存记录'**
  String get saveRecord;

  /// No description provided for @saveAndMarkComplete.
  ///
  /// In zh, this message translates to:
  /// **'保存并标记完成'**
  String get saveAndMarkComplete;

  /// No description provided for @savedAndMarkedComplete.
  ///
  /// In zh, this message translates to:
  /// **'已保存并标记完成'**
  String get savedAndMarkedComplete;

  /// No description provided for @recordSaved.
  ///
  /// In zh, this message translates to:
  /// **'记录已保存'**
  String get recordSaved;

  /// No description provided for @backupSavedToAlbumSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，并备份到相册'**
  String get backupSavedToAlbumSuffix;

  /// No description provided for @albumBackupFailedSuffix.
  ///
  /// In zh, this message translates to:
  /// **'；相册备份失败'**
  String get albumBackupFailedSuffix;

  /// Success message suffix with the next point name
  ///
  /// In zh, this message translates to:
  /// **'下一个：{name}'**
  String nextPointNameSuffix(String name);

  /// No description provided for @comparisonSavedToAlbumSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，对比图已保存到相册'**
  String get comparisonSavedToAlbumSuffix;

  /// No description provided for @referenceUnavailableComparisonSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，参考图不可用，未生成对比图'**
  String get referenceUnavailableComparisonSuffix;

  /// No description provided for @capturedUnavailableComparisonSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，巡礼图不可用，未生成对比图'**
  String get capturedUnavailableComparisonSuffix;

  /// No description provided for @comparisonGalleryFailedSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，对比图保存到相册失败'**
  String get comparisonGalleryFailedSuffix;

  /// No description provided for @comparisonRenderFailedSuffix.
  ///
  /// In zh, this message translates to:
  /// **'，对比图生成失败'**
  String get comparisonRenderFailedSuffix;

  /// No description provided for @saveToAlbum.
  ///
  /// In zh, this message translates to:
  /// **'保存到相册'**
  String get saveToAlbum;

  /// No description provided for @savedToAlbum.
  ///
  /// In zh, this message translates to:
  /// **'已保存到相册'**
  String get savedToAlbum;

  /// No description provided for @saveFailedRetry.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请稍后重试。'**
  String get saveFailedRetry;

  /// No description provided for @referenceModeLabel.
  ///
  /// In zh, this message translates to:
  /// **'参考模式'**
  String get referenceModeLabel;

  /// No description provided for @newArea.
  ///
  /// In zh, this message translates to:
  /// **'新建片区'**
  String get newArea;

  /// No description provided for @areaCreationFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区创建失败'**
  String get areaCreationFailed;

  /// No description provided for @renameArea.
  ///
  /// In zh, this message translates to:
  /// **'重命名片区'**
  String get renameArea;

  /// No description provided for @areaName.
  ///
  /// In zh, this message translates to:
  /// **'片区名称'**
  String get areaName;

  /// No description provided for @areaRenameFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区改名失败'**
  String get areaRenameFailed;

  /// No description provided for @sortOrderSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'排序方式保存失败'**
  String get sortOrderSaveFailed;

  /// No description provided for @recommendedRouteGenerationFailed.
  ///
  /// In zh, this message translates to:
  /// **'推荐路线生成失败'**
  String get recommendedRouteGenerationFailed;

  /// Auto-localized: {routeorderedPointslength} points · about
  ///
  /// In zh, this message translates to:
  /// **'{routeorderedPointslength} 个点位 · 约 '**
  String pointsAbout(String routeorderedPointslength);

  /// Auto-localized: {formatRouteDistanceroutetotalDistanceMeters} on foot
  ///
  /// In zh, this message translates to:
  /// **'{formatRouteDistanceroutetotalDistanceMeters} 步行'**
  String onFoot(String formatRouteDistanceroutetotalDistanceMeters);

  /// No description provided for @anchorSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'关键点保存失败'**
  String get anchorSaveFailed;

  /// No description provided for @deleteArea.
  ///
  /// In zh, this message translates to:
  /// **'删除片区'**
  String get deleteArea;

  /// Auto-localized: Delete "{groupname}"? {pointCount} points will be moved to ungrouped points.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{groupname}」吗？其中 {pointCount} 个点位会移入未分配点位。'**
  String deletePointsWillBeMovedToUngroupedPoints(
    String groupname,
    String pointCount,
  );

  /// No description provided for @areaDeletionFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区删除失败'**
  String get areaDeletionFailed;

  /// No description provided for @areaOrderSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'片区顺序保存失败'**
  String get areaOrderSaveFailed;

  /// No description provided for @ungroupedPoints.
  ///
  /// In zh, this message translates to:
  /// **'未分配点位'**
  String get ungroupedPoints;

  /// No description provided for @areaNameCannotBeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'片区名不能为空'**
  String get areaNameCannotBeEmpty;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// Auto-localized: {groupCount} areas · {planpointslength} points
  ///
  /// In zh, this message translates to:
  /// **'{groupCount} 个片区 · {planpointslength} 个点位'**
  String areasPoints(String groupCount, String planpointslength);

  /// No description provided for @manualOrder.
  ///
  /// In zh, this message translates to:
  /// **'手动排序'**
  String get manualOrder;

  /// Auto-localized: {pointCount} points · {anchorLabel} · {orderLabel}
  ///
  /// In zh, this message translates to:
  /// **'{pointCount} 点位 · {anchorLabel} · {orderLabel}'**
  String points(String pointCount, String anchorLabel, String orderLabel);

  /// No description provided for @areaActions.
  ///
  /// In zh, this message translates to:
  /// **'片区操作'**
  String get areaActions;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @setAnchor.
  ///
  /// In zh, this message translates to:
  /// **'设置关键点'**
  String get setAnchor;

  /// No description provided for @switchToUnordered.
  ///
  /// In zh, this message translates to:
  /// **'切换为无序'**
  String get switchToUnordered;

  /// No description provided for @switchToManualOrder.
  ///
  /// In zh, this message translates to:
  /// **'切换为手动排序'**
  String get switchToManualOrder;

  /// Auto-localized: {pointCount} points awaiting organization
  ///
  /// In zh, this message translates to:
  /// **'{pointCount} 个点位等待整理'**
  String pointsAwaitingOrganization(String pointCount);

  /// No description provided for @noAssignablePointsWithinTheCurrentDistance.
  ///
  /// In zh, this message translates to:
  /// **'当前距离内没有可分配点位'**
  String get noAssignablePointsWithinTheCurrentDistance;

  /// No description provided for @confirmRecentAssignment.
  ///
  /// In zh, this message translates to:
  /// **'确认最近分配'**
  String get confirmRecentAssignment;

  /// Auto-localized: Will assign {count} ungrouped points to the nearest area anchor, with a maximum distance of {formatDistancedistanceMeters}.
  ///
  /// In zh, this message translates to:
  /// **'将把 {count} 个未分组点位分配到最近的片区关键点，最大距离为 {formatDistancedistanceMeters}。'**
  String willAssignUngroupedPointsToTheNearestAreaAnchorWithAMaximumDistanceOf(
    String count,
    String formatDistancedistanceMeters,
  );

  /// Auto-localized: Assigned {count} points
  ///
  /// In zh, this message translates to:
  /// **'已分配 {count} 个点位'**
  String assignedPoints(String count);

  /// No description provided for @recentAssignmentFailed.
  ///
  /// In zh, this message translates to:
  /// **'最近分配失败'**
  String get recentAssignmentFailed;

  /// No description provided for @finishAreaAssignmentFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先完成片区分配'**
  String get finishAreaAssignmentFirst;

  /// No description provided for @createAnAreaFirst.
  ///
  /// In zh, this message translates to:
  /// **'请先创建片区'**
  String get createAnAreaFirst;

  /// No description provided for @noUngroupedPointsWithinTheBoxSelection.
  ///
  /// In zh, this message translates to:
  /// **'框选范围内没有未分组点位'**
  String get noUngroupedPointsWithinTheBoxSelection;

  /// No description provided for @confirmBoxSelectionAssignment.
  ///
  /// In zh, this message translates to:
  /// **'确认框选分配'**
  String get confirmBoxSelectionAssignment;

  /// Auto-localized: Will move {pointslength} ungrouped points to "{targetGroupname}".
  ///
  /// In zh, this message translates to:
  /// **'将把 {pointslength} 个未分组点位移动到「{targetGroupname}」。'**
  String willMoveUngroupedPointsTo(String pointslength, String targetGroupname);

  /// No description provided for @assign.
  ///
  /// In zh, this message translates to:
  /// **'分配'**
  String get assign;

  /// Auto-localized: Assigned {pointslength} points
  ///
  /// In zh, this message translates to:
  /// **'已分配 {pointslength} 个点位'**
  String assignedPoints2(String pointslength);

  /// No description provided for @boxSelectionAssignmentFailed.
  ///
  /// In zh, this message translates to:
  /// **'框选分配失败'**
  String get boxSelectionAssignmentFailed;

  /// No description provided for @selectArea.
  ///
  /// In zh, this message translates to:
  /// **'选择片区'**
  String get selectArea;

  /// No description provided for @boxSelect.
  ///
  /// In zh, this message translates to:
  /// **'框选'**
  String get boxSelect;

  /// No description provided for @endBoxSelect.
  ///
  /// In zh, this message translates to:
  /// **'结束框选'**
  String get endBoxSelect;

  /// Auto-localized: Selected {selectedCount} / ungrouped {ungroupedCount}
  ///
  /// In zh, this message translates to:
  /// **'已框选 {selectedCount} / 未分组 {ungroupedCount}'**
  String selectedUngrouped(String selectedCount, String ungroupedCount);

  /// No description provided for @assigning.
  ///
  /// In zh, this message translates to:
  /// **'分配中'**
  String get assigning;

  /// Auto-localized: Max distance {formatDistancedistanceMeters} · assignable {assignableCount}/{ungroupedCount}
  ///
  /// In zh, this message translates to:
  /// **'最大距离 {formatDistancedistanceMeters} · 可分配 {assignableCount}/{ungroupedCount}'**
  String maxDistanceAssignable(
    String formatDistancedistanceMeters,
    String assignableCount,
    String ungroupedCount,
  );

  /// No description provided for @ungroupedPointsAreAssignedToTheNearestAreaAnchorWithinTheMaximumDistance.
  ///
  /// In zh, this message translates to:
  /// **'未分组点位会分配到距离最近、且在最大距离范围内的片区关键点。'**
  String
  get ungroupedPointsAreAssignedToTheNearestAreaAnchorWithinTheMaximumDistance;

  /// No description provided for @noAvailableAreaAnchors.
  ///
  /// In zh, this message translates to:
  /// **'没有可用片区关键点'**
  String get noAvailableAreaAnchors;

  /// No description provided for @createAnAreaFirstYouCanUseSmartZoningToGenerateOne.
  ///
  /// In zh, this message translates to:
  /// **'请先创建片区（可用「智能分区」一键生成）'**
  String get createAnAreaFirstYouCanUseSmartZoningToGenerateOne;

  /// Auto-localized: Ungrouped {ungroupedCount} · tap a map point for details
  ///
  /// In zh, this message translates to:
  /// **'未分组 {ungroupedCount} 个 · 点击地图点位查看详情'**
  String ungroupedTapAMapPointForDetails(String ungroupedCount);

  /// No description provided for @outOfRangePoints.
  ///
  /// In zh, this message translates to:
  /// **'距离外点位'**
  String get outOfRangePoints;

  /// No description provided for @assignablePoints.
  ///
  /// In zh, this message translates to:
  /// **'可分配点位'**
  String get assignablePoints;

  /// No description provided for @importContent.
  ///
  /// In zh, this message translates to:
  /// **'导入内容'**
  String get importContent;

  /// No description provided for @selectImportContent.
  ///
  /// In zh, this message translates to:
  /// **'选择导入内容'**
  String get selectImportContent;

  /// No description provided for @importingWillNotModifyCurrentData.
  ///
  /// In zh, this message translates to:
  /// **'导入前不会修改当前数据。'**
  String get importingWillNotModifyCurrentData;

  /// No description provided for @planStructure.
  ///
  /// In zh, this message translates to:
  /// **'计划结构'**
  String get planStructure;

  /// No description provided for @worksAreasPointsCompletionStatusAndCurrentGoals.
  ///
  /// In zh, this message translates to:
  /// **'作品、片区、点位、完成状态和当前目标。'**
  String get worksAreasPointsCompletionStatusAndCurrentGoals;

  /// No description provided for @captureRecords.
  ///
  /// In zh, this message translates to:
  /// **'拍摄记录'**
  String get captureRecords;

  /// No description provided for @v1FilesDoNotIncludePhotoAssetsOnlyThePlanStructureIsImported.
  ///
  /// In zh, this message translates to:
  /// **'v1 文件不包含照片资源，仅导入计划结构。'**
  String get v1FilesDoNotIncludePhotoAssetsOnlyThePlanStructureIsImported;

  /// Auto-localized: {packagevisitRecordCount} records, including photo paths and color grading parameters.
  ///
  /// In zh, this message translates to:
  /// **'{packagevisitRecordCount} 条记录，包含照片路径和调色参数。'**
  String recordsIncludingPhotoPathsAndColorGradingParameters(
    String packagevisitRecordCount,
  );

  /// No description provided for @thisPackageHasNoCaptureRecords.
  ///
  /// In zh, this message translates to:
  /// **'这个包里没有拍摄记录。'**
  String get thisPackageHasNoCaptureRecords;

  /// No description provided for @imagesAndResourceFiles.
  ///
  /// In zh, this message translates to:
  /// **'图片和资源文件'**
  String get imagesAndResourceFiles;

  /// No description provided for @notesInPackage.
  ///
  /// In zh, this message translates to:
  /// **'包内提示'**
  String get notesInPackage;

  /// No description provided for @missingOrCompatibilityNotesRecordedDuringExport.
  ///
  /// In zh, this message translates to:
  /// **'导出时记录的缺失或兼容信息。'**
  String get missingOrCompatibilityNotesRecordedDuringExport;

  /// No description provided for @importSelectedContent.
  ///
  /// In zh, this message translates to:
  /// **'导入所选内容'**
  String get importSelectedContent;

  /// No description provided for @importing.
  ///
  /// In zh, this message translates to:
  /// **'导入中...'**
  String get importing;

  /// Auto-localized: Imported plan "{importedPlanname}"
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{importedPlanname}」'**
  String importedPlan(String importedPlanname);

  /// Auto-localized: Imported plan "{importedPlanname}", but some assets were not restored
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{importedPlanname}」，部分资源未恢复'**
  String importedPlanButSomeAssetsWereNotRestored(String importedPlanname);

  /// No description provided for @importFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get importFailed;

  /// No description provided for @thisPackageHasNoRecoverableAssetFiles.
  ///
  /// In zh, this message translates to:
  /// **'这个包里没有可恢复的资源文件。'**
  String get thisPackageHasNoRecoverableAssetFiles;

  /// No description provided for @thePackageRecordedAssetsButThereAreNoRecoverableAssetFiles.
  ///
  /// In zh, this message translates to:
  /// **'包内记录了资源，但没有可恢复的资源文件。'**
  String get thePackageRecordedAssetsButThereAreNoRecoverableAssetFiles;

  /// No description provided for @assets.
  ///
  /// In zh, this message translates to:
  /// **'资源'**
  String get assets;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// No description provided for @pointName.
  ///
  /// In zh, this message translates to:
  /// **'点位名'**
  String get pointName;

  /// No description provided for @subtitle.
  ///
  /// In zh, this message translates to:
  /// **'副标题'**
  String get subtitle;

  /// No description provided for @episodeScene.
  ///
  /// In zh, this message translates to:
  /// **'集数/场景'**
  String get episodeScene;

  /// No description provided for @sourceId.
  ///
  /// In zh, this message translates to:
  /// **'来源ID'**
  String get sourceId;

  /// No description provided for @referenceImageUrl.
  ///
  /// In zh, this message translates to:
  /// **'参考图URL'**
  String get referenceImageUrl;

  /// No description provided for @recordCount.
  ///
  /// In zh, this message translates to:
  /// **'记录数'**
  String get recordCount;

  /// No description provided for @no.
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes;

  /// No description provided for @gradedPhotoFileName.
  ///
  /// In zh, this message translates to:
  /// **'调色照片文件名'**
  String get gradedPhotoFileName;

  /// No description provided for @photoFileName.
  ///
  /// In zh, this message translates to:
  /// **'照片文件名'**
  String get photoFileName;

  /// No description provided for @colorGraded.
  ///
  /// In zh, this message translates to:
  /// **'是否调色'**
  String get colorGraded;

  /// No description provided for @recordId.
  ///
  /// In zh, this message translates to:
  /// **'记录ID'**
  String get recordId;

  /// No description provided for @customMaplibreStyleUrlMustUseHttpHttps.
  ///
  /// In zh, this message translates to:
  /// **'自定义 MapLibre style URL 需要使用 http/https。'**
  String get customMaplibreStyleUrlMustUseHttpHttps;

  /// No description provided for @thisWorkWasnTFoundInAnitabi.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 中没有找到这个作品'**
  String get thisWorkWasnTFoundInAnitabi;

  /// No description provided for @thisWorkHasNoAnitabiPointsYet.
  ///
  /// In zh, this message translates to:
  /// **'当前作品暂无 Anitabi 点位'**
  String get thisWorkHasNoAnitabiPointsYet;

  /// No description provided for @thisBangumiEntryHasNoMatchingWorkInAnitabiMapDataTryAddingAnAnimationOriginalWorkOrRelatedEntryWithTheSameName.
  ///
  /// In zh, this message translates to:
  /// **'这个 Bangumi 条目在 Anitabi 地图数据中没有对应作品。可以尝试添加同名动画、原作或其它关联条目。'**
  String
  get thisBangumiEntryHasNoMatchingWorkInAnitabiMapDataTryAddingAnAnimationOriginalWorkOrRelatedEntryWithTheSameName;

  /// No description provided for @thisWorkExistsInAnitabiButThereAreNoMapPointsAvailableToImportYet.
  ///
  /// In zh, this message translates to:
  /// **'Anitabi 中能找到这个作品，但当前还没有可导入的地图点位。'**
  String get thisWorkExistsInAnitabiButThereAreNoMapPointsAvailableToImportYet;

  /// Auto-localized: No importable Anitabi points for "{workTitle}" yet.
  ///
  /// In zh, this message translates to:
  /// **'「{workTitle}」暂无可导入的 Anitabi 点位。'**
  String noImportableAnitabiPointsForYet(String workTitle);

  /// No description provided for @workPilgrimage.
  ///
  /// In zh, this message translates to:
  /// **'<work> 巡礼'**
  String get workPilgrimage;

  /// No description provided for @areaN.
  ///
  /// In zh, this message translates to:
  /// **'片区 N'**
  String get areaN;

  /// No description provided for @loadingReferenceImage.
  ///
  /// In zh, this message translates to:
  /// **'参考图加载中'**
  String get loadingReferenceImage;

  /// No description provided for @referenceImageUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'参考图暂不可用'**
  String get referenceImageUnavailable;

  /// No description provided for @eGHttpsWwAnitabiCnMapBangumiid8290PidQdmnf6iqj.
  ///
  /// In zh, this message translates to:
  /// **'例如 https://ww.anitabi.cn/map?bangumiId=8290&pid=qdmnf6iqj'**
  String get eGHttpsWwAnitabiCnMapBangumiid8290PidQdmnf6iqj;

  /// No description provided for @anitripImage.
  ///
  /// In zh, this message translates to:
  /// **'anitrip 图片'**
  String get anitripImage;

  /// Auto-localized: {itempointCount} landmarks
  ///
  /// In zh, this message translates to:
  /// **'{itempointCount} 地标'**
  String landmarks(String itempointCount);

  /// Auto-localized: {itempointCount} screenshots
  ///
  /// In zh, this message translates to:
  /// **'{itempointCount} 截图'**
  String screenshots(String itempointCount);

  /// No description provided for @latestWorks.
  ///
  /// In zh, this message translates to:
  /// **'最新作品'**
  String get latestWorks;

  /// No description provided for @nPlaces.
  ///
  /// In zh, this message translates to:
  /// **'N 个地点'**
  String get nPlaces;

  /// No description provided for @imageViewerShareSubject.
  ///
  /// In zh, this message translates to:
  /// **'anitrip 图片'**
  String get imageViewerShareSubject;

  /// No description provided for @imageViewerShareText.
  ///
  /// In zh, this message translates to:
  /// **'anitrip 图片'**
  String get imageViewerShareText;

  /// No description provided for @mapMarkerPilgrimagePoint.
  ///
  /// In zh, this message translates to:
  /// **'巡礼点'**
  String get mapMarkerPilgrimagePoint;

  /// No description provided for @mapMapLibreUrlRequireHttp.
  ///
  /// In zh, this message translates to:
  /// **'自定义 MapLibre style URL 需要使用 http/https。'**
  String get mapMapLibreUrlRequireHttp;

  /// Auto-localized: {routeorderedPointslength} points · about
  ///
  /// In zh, this message translates to:
  /// **'{routeorderedPointslength} 个点位 · 约 '**
  String pointsAbout2(String routeorderedPointslength);

  /// Auto-localized: {formatRouteDistanceroutetotalDistanceMeters} on foot
  ///
  /// In zh, this message translates to:
  /// **'{formatRouteDistanceroutetotalDistanceMeters} 步行'**
  String onFoot2(String formatRouteDistanceroutetotalDistanceMeters);

  /// Auto-localized: Delete "{groupname}"? {pointCount} points will be moved to ungrouped points.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{groupname}」吗？其中 {pointCount} 个点位会移入未分配点位。'**
  String deletePointsWillBeMovedToUngroupedPoints2(
    String groupname,
    String pointCount,
  );

  /// Auto-localized: Will assign {count} ungrouped points to the nearest area anchor, with a maximum distance of {formatDistancedistanceMeters}.
  ///
  /// In zh, this message translates to:
  /// **'将把 {count} 个未分组点位分配到最近的片区关键点，最大距离为 {formatDistancedistanceMeters}。'**
  String willAssignUngroupedPointsToTheNearestAreaAnchorWithAMaximumDistanceOf2(
    String count,
    String formatDistancedistanceMeters,
  );

  /// No description provided for @startAssignment.
  ///
  /// In zh, this message translates to:
  /// **'开始分配'**
  String get startAssignment;

  /// Auto-localized: Assigned {count} points
  ///
  /// In zh, this message translates to:
  /// **'已分配 {count} 个点位'**
  String assignedPoints3(String count);

  /// Auto-localized: Will move {pointslength} ungrouped points to "{targetGroupname}".
  ///
  /// In zh, this message translates to:
  /// **'将把 {pointslength} 个未分组点位移动到「{targetGroupname}」。'**
  String willMoveUngroupedPointsTo2(
    String pointslength,
    String targetGroupname,
  );

  /// Auto-localized: Assigned {pointslength} points
  ///
  /// In zh, this message translates to:
  /// **'已分配 {pointslength} 个点位'**
  String assignedPoints4(String pointslength);

  /// Auto-localized: Imported plan "{importedPlanname}"
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{importedPlanname}」'**
  String importedPlan2(String importedPlanname);

  /// Auto-localized: Imported plan "{importedPlanname}", but some assets were not restored
  ///
  /// In zh, this message translates to:
  /// **'已导入计划「{importedPlanname}」，部分资源未恢复'**
  String importedPlanButSomeAssetsWereNotRestored2(String importedPlanname);

  /// No description provided for @colorMatchNatural.
  ///
  /// In zh, this message translates to:
  /// **'自然'**
  String get colorMatchNatural;

  /// No description provided for @colorMatchStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get colorMatchStandard;

  /// No description provided for @colorMatchStrong.
  ///
  /// In zh, this message translates to:
  /// **'强匹配'**
  String get colorMatchStrong;

  /// No description provided for @aspectRatioAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get aspectRatioAuto;

  /// No description provided for @aspectRatioNative.
  ///
  /// In zh, this message translates to:
  /// **'原生比例'**
  String get aspectRatioNative;

  /// No description provided for @themeCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义'**
  String get themeCustom;

  /// No description provided for @importPackageV2Data.
  ///
  /// In zh, this message translates to:
  /// **'v2 数据包'**
  String get importPackageV2Data;

  /// No description provided for @csvHeaderWork.
  ///
  /// In zh, this message translates to:
  /// **'作品'**
  String get csvHeaderWork;

  /// No description provided for @csvHeaderArea.
  ///
  /// In zh, this message translates to:
  /// **'片区'**
  String get csvHeaderArea;

  /// No description provided for @csvHeaderPointName.
  ///
  /// In zh, this message translates to:
  /// **'点位名'**
  String get csvHeaderPointName;

  /// No description provided for @csvHeaderSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'副标题'**
  String get csvHeaderSubtitle;

  /// No description provided for @csvHeaderLatitude.
  ///
  /// In zh, this message translates to:
  /// **'纬度'**
  String get csvHeaderLatitude;

  /// No description provided for @csvHeaderLongitude.
  ///
  /// In zh, this message translates to:
  /// **'经度'**
  String get csvHeaderLongitude;

  /// No description provided for @csvHeaderEpisodeScene.
  ///
  /// In zh, this message translates to:
  /// **'集数/场景'**
  String get csvHeaderEpisodeScene;

  /// No description provided for @csvHeaderSource.
  ///
  /// In zh, this message translates to:
  /// **'来源'**
  String get csvHeaderSource;

  /// No description provided for @csvHeaderSourceId.
  ///
  /// In zh, this message translates to:
  /// **'来源ID'**
  String get csvHeaderSourceId;

  /// No description provided for @csvHeaderRefImageUrl.
  ///
  /// In zh, this message translates to:
  /// **'参考图URL'**
  String get csvHeaderRefImageUrl;

  /// No description provided for @csvHeaderCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get csvHeaderCompleted;

  /// No description provided for @csvHeaderRecordCount.
  ///
  /// In zh, this message translates to:
  /// **'记录数'**
  String get csvHeaderRecordCount;

  /// No description provided for @csvHeaderRecordId.
  ///
  /// In zh, this message translates to:
  /// **'记录ID'**
  String get csvHeaderRecordId;

  /// No description provided for @csvHeaderCapturedAt.
  ///
  /// In zh, this message translates to:
  /// **'拍摄时间'**
  String get csvHeaderCapturedAt;

  /// No description provided for @csvHeaderRefMode.
  ///
  /// In zh, this message translates to:
  /// **'参考模式'**
  String get csvHeaderRefMode;

  /// No description provided for @csvHeaderColorGraded.
  ///
  /// In zh, this message translates to:
  /// **'是否调色'**
  String get csvHeaderColorGraded;

  /// No description provided for @csvHeaderPhotoFile.
  ///
  /// In zh, this message translates to:
  /// **'照片文件名'**
  String get csvHeaderPhotoFile;

  /// No description provided for @csvHeaderGradedPhotoFile.
  ///
  /// In zh, this message translates to:
  /// **'调色照片文件名'**
  String get csvHeaderGradedPhotoFile;

  /// No description provided for @refCacheNone.
  ///
  /// In zh, this message translates to:
  /// **'当前计划没有需要缓存的参考图'**
  String get refCacheNone;

  /// Auto-localized: Cached {succeeded}/{total} full reference images
  ///
  /// In zh, this message translates to:
  /// **'已缓存 \$succeeded/\$total 张完整参考图'**
  String refCacheDone(String succeeded, String total);

  /// Auto-localized: Cached {succeeded}/{total} full reference images, {failed} failed
  ///
  /// In zh, this message translates to:
  /// **'已缓存 \$succeeded/\$total 张完整参考图，失败 \$failed 张'**
  String refCacheDoneFailed(String succeeded, String total, String failed);

  /// Auto-localized: Caching {processed}/{total} full reference images, {succeeded} succeeded
  ///
  /// In zh, this message translates to:
  /// **'正在缓存完整参考图 \$processed/\$total，成功 \$succeeded'**
  String refCacheProgress(String processed, String total, String succeeded);

  /// No description provided for @anitabiUrlInvalidHttps.
  ///
  /// In zh, this message translates to:
  /// **'请输入有效的 HTTPS 地址'**
  String get anitabiUrlInvalidHttps;

  /// No description provided for @anitabiUrlNoAccount.
  ///
  /// In zh, this message translates to:
  /// **'地址不能包含账号、查询参数或片段'**
  String get anitabiUrlNoAccount;

  /// No description provided for @anitabiUrlNoLocal.
  ///
  /// In zh, this message translates to:
  /// **'不能使用本机或局域网地址'**
  String get anitabiUrlNoLocal;

  /// Auto-localized: {packageTotalAssetCount} asset files in the package will be restored to local storage.
  ///
  /// In zh, this message translates to:
  /// **'包内有 \${packageTotalAssetCount} 个资源文件，将恢复到本机存储。'**
  String packageAssetsRestoreLocal(String packageTotalAssetCount);

  /// Auto-localized: {packageTotalAssetCount} asset files in the package; restoring in-package assets is not supported on this platform yet.
  ///
  /// In zh, this message translates to:
  /// **'包内有 \${packageTotalAssetCount} 个资源文件；当前平台暂不支持恢复包内资源。'**
  String packageAssetsNoPlatformRestore(String packageTotalAssetCount);
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
