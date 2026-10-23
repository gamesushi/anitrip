import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import 'legal_documents.dart';

/// Read-only full-screen view of a legal document.
///
/// Uses the same Markdown styling language as the plan memo editor so both
/// surfaces stay visually consistent.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({required this.document, super.key});

  final LegalDocument document;

  static Future<void> open(BuildContext context, LegalDocument document) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (context) {
      return LegalDocumentScreen(document: document);
    }));
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    final source = LegalDocumentContent.markdown(document, locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(LegalDocumentContent.title(document, locale)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: source,
                selectable: true,
                softLineBreak: true,
                styleSheet: _styleSheet(context),
                onTapLink: (_, href, _) => _openLink(href),
              ),
              const SizedBox(height: 24),
              Text(
                LegalDocumentContent.revisionDateLabel(locale),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 16),
              _PublicLink(document: document, label: l10n.legalViewOnline),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(String? href) async {
    if (href == null || href.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(href);
    if (uri == null) {
      return;
    }
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static MarkdownStyleSheet _styleSheet(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    const body = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 15,
      height: 1.6,
      letterSpacing: 0,
    );
    return base.copyWith(
      p: body,
      a: body.copyWith(
        color: AppColors.accentDark,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.underline,
      ),
      listBullet: body.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
      listBulletPadding: EdgeInsets.zero,
      blockquote: body.copyWith(color: AppColors.textSecondary),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
      tableBorder: TableBorder.all(color: AppColors.border, width: 1),
      tableColumnWidth: const FlexColumnWidth(),
      tableHead: body.copyWith(fontWeight: FontWeight.w800),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      h1: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 23,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: 0,
      ),
      h2: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: 0,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
    );
  }
}

/// Small footer link that opens the latest online version of [document] in the
/// system browser. Renders nothing when the document has no public mirror.
class _PublicLink extends StatelessWidget {
  const _PublicLink({required this.document, required this.label});

  final LegalDocument document;
  final String label;

  @override
  Widget build(BuildContext context) {
    final url = LegalDocumentContent.publicUrl(document);
    if (url == null) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.open_in_new, size: 16),
        label: Text(label),
        onPressed: () async {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
