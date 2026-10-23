import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anitrip/l10n/app_localizations.dart';
import 'package:anitrip/settings/legal_document_screen.dart';
import 'package:anitrip/settings/legal_documents.dart';

void main() {
  Widget buildSubject(LegalDocument document, {Locale locale = const Locale('zh')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LegalDocumentScreen(document: document),
    );
  }

  testWidgets('renders the privacy policy headings and body', (tester) async {
    await tester.pumpWidget(buildSubject(LegalDocument.privacyPolicy));
    await tester.pumpAndSettle();

    expect(find.byType(LegalDocumentScreen), findsOneWidget);
    expect(find.textContaining('隐私政策'), findsWidgets);
    // Section headings must actually render (guards against Markdown breakage).
    expect(find.byType(MarkdownBody), findsOneWidget);
  });

  testWidgets('renders the terms of service', (tester) async {
    await tester.pumpWidget(buildSubject(LegalDocument.termsOfService));
    await tester.pumpAndSettle();

    expect(find.textContaining('服务条款'), findsWidgets);
  });

  testWidgets('falls back to English for non-Chinese locales', (tester) async {
    final subject = MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LegalDocumentScreen(document: LegalDocument.privacyPolicy),
    );
    await tester.pumpWidget(subject);
    await tester.pumpAndSettle();

    expect(LegalDocumentContent.title(LegalDocument.privacyPolicy,
        const Locale('en')), 'Privacy Policy');
    expect(
      LegalDocumentContent.title(LegalDocument.privacyPolicy,
          const Locale('zh')),
      '隐私政策',
    );
  });

  testWidgets('links to the latest online version', (tester) async {
    await tester.pumpWidget(
      buildSubject(LegalDocument.privacyPolicy, locale: const Locale('en')),
    );
    await tester.pumpAndSettle();

    // Resolve the label from the same delegate the widget used, so the
    // assertion is locale-independent (en in the app, zh template in fallback).
    final element = tester.element(find.byType(LegalDocumentScreen));
    final l10n = AppLocalizations.of(element)!;
    expect(find.text(l10n.legalViewOnline), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });

  test('documents expose contacts and a revision label', () {
    for (final document in LegalDocument.values) {
      expect(
        LegalDocumentContent.markdown(document, const Locale('zh')),
        contains('bilyhurington@gmail.com'),
      );
    }
    expect(
      LegalDocumentContent.revisionDateLabel(const Locale('zh')),
      startsWith('最近更新'),
    );
  });

  test('publicUrl points at the deployed GitHub Pages site', () {
    expect(
      LegalDocumentContent.publicUrl(LegalDocument.privacyPolicy),
      'https://gamesushi.github.io/anitrip/privacy_policy.html',
    );
    expect(
      LegalDocumentContent.publicUrl(LegalDocument.termsOfService),
      'https://gamesushi.github.io/anitrip/terms_of_service.html',
    );
  });
}
