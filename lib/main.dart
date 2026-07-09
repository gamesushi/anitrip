import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'app_shell.dart';
import 'app_theme.dart';
import 'data/local/sqlite_pilgrimage_repository.dart';
import 'data/pilgrimage_repository.dart';
import 'data/localized_pilgrimage_repository.dart';
import 'data/sample_pilgrimage_repository.dart';
import 'desktop/desktop_pilgrimage_repository.dart';
import 'desktop/tauri_bridge.dart';
import 'widgets/copyable_text.dart';
import 'plan/pilgrimage_models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final repository = await _createDefaultRepository();
  final settings = await repository.loadAppSettings();
  runApp(MiriaGoApp(repository: repository, initialSettings: settings));
}

class MiriaGoApp extends StatefulWidget {
  const MiriaGoApp({this.repository, this.initialSettings, super.key});

  final PilgrimageRepository? repository;
  final AppSettings? initialSettings;

  @override
  State<MiriaGoApp> createState() => _MiriaGoAppState();
}

class _MiriaGoAppState extends State<MiriaGoApp> {
  late final ValueNotifier<AppSettings> _settingsNotifier;

  @override
  void initState() {
    super.initState();
    _settingsNotifier = ValueNotifier<AppSettings>(
      widget.initialSettings ?? const AppSettings(),
    );
  }

  @override
  void dispose() {
    _settingsNotifier.dispose();
    super.dispose();
  }

  Locale? _getLocale(String language) {
    if (language == 'system') return null;
    if (language == 'zh') return const Locale('zh');
    if (language == 'zh_Hant') {
      return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    if (language == 'en') return const Locale('en');
    if (language == 'fr') return const Locale('fr');
    if (language == 'ko') return const Locale('ko');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activeRepository = LocalizedPilgrimageRepository(
      widget.repository ??
          (kIsWeb
              ? SamplePilgrimageRepository()
              : SqlitePilgrimageRepository()),
    );

    return ValueListenableBuilder<AppSettings>(
      valueListenable: _settingsNotifier,
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'MiriaGo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            palette: settings.themePalette,
            customAccentValue: settings.customThemeColorValue,
          ),
          navigatorObservers: [copyOverlayNavigatorObserver],
          locale: _getLocale(settings.language),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppShell(
            repository: activeRepository,
            settings: settings,
            onSettingsChanged: (newSettings) {
              _settingsNotifier.value = newSettings;
            },
          ),
        );
      },
    );
  }
}

Future<PilgrimageRepository> _createDefaultRepository() async {
  if (!kIsWeb) {
    return SqlitePilgrimageRepository();
  }
  if (isTauriLauncherAvailable) {
    return DesktopPilgrimageRepository.create();
  }
  return SamplePilgrimageRepository();
}
