import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import 'pilgrimage_models.dart';
import 'plan_completion_summary.dart';

/// Single-plan "did I finish it?" view.
///
/// The underlying data (`completedPointIds`) has existed for a long time, but
/// was only ever surfaced as a one-line subtext. This page turns it into a
/// visible achievement: headline ring, per-group bars, and the visited /
/// remaining split that makes "what's left" obvious before heading out.
class PlanCompletionScreen extends StatelessWidget {
  const PlanCompletionScreen({required this.plan, super.key});

  final PilgrimagePlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = PlanCompletionSummary.of(plan);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.planCompletionTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _CompletionHero(summary: summary, planName: plan.name),
          const SizedBox(height: 14),
          if (summary.groups.isNotEmpty) ...[
            _SectionTitle(title: l10n.planCompletionGroupSection),
            const SizedBox(height: 8),
            for (final group in summary.groups)
              _GroupProgressBar(
                name: group.isUngrouped ? l10n.labelUngrouped : group.name,
                group: group,
              ),
            const SizedBox(height: 14),
          ],
          _SectionTitle(
            title: l10n.planCompletionRemainingSection,
            trailing: summary.remainingPoints.isEmpty
                ? null
                : l10n.planCompletionRemainingCount(summary.remaining),
          ),
          const SizedBox(height: 8),
          if (summary.remainingPoints.isEmpty)
            Text(
              summary.isEmpty ? l10n.planCompletionEmptyPoints : l10n.planCompletionAllDone,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0,
              ),
            )
          else
            for (final point in summary.remainingPoints)
              _PointTile(point: point, done: false),
          const SizedBox(height: 14),
          _SectionTitle(
            title: l10n.planCompletionVisitedSection,
            trailing: summary.visitedPoints.isEmpty
                ? null
                : '${summary.completed}',
          ),
          const SizedBox(height: 8),
          if (summary.visitedPoints.isEmpty)
            Text(
              l10n.planCompletionEmptyVisited,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0,
              ),
            )
          else
            for (final point in summary.visitedPoints) _PointTile(point: point, done: true),
        ],
      ),
    );
  }
}

class _CompletionHero extends StatelessWidget {
  const _CompletionHero({required this.summary, required this.planName});

  final PlanCompletionSummary summary;
  final String planName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.accent;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: summary.ratio,
                  strokeWidth: 9,
                  backgroundColor: AppColors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.percent}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(
                      '${summary.completed}/${summary.total}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.planCompletionSummary(summary.completed, summary.total),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    letterSpacing: 0,
                  ),
                ),
                if (summary.isComplete) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 16, color: accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.planCompletionAllDone,
                          style: TextStyle(
                            fontSize: 12,
                            color: accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupProgressBar extends StatelessWidget {
  const _GroupProgressBar({required this.name, required this.group});

  final String name;
  final PlanGroupCompletion group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                '${group.completed}/${group.total}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: group.total == 0 ? 0 : group.completed / group.total,
              minHeight: 6,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  const _PointTile({required this.point, required this.done});

  final PilgrimagePoint point;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final subtitle = point.subtitle.trim().isNotEmpty
        ? point.subtitle
        : point.work.title;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );
  }
}
