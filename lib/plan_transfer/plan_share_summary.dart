import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';

/// 一份计划的「对外呈现」摘要——用于分享文案与分享卡片。
///
/// 只依赖 [PilgrimagePlan] 与打卡记录，不碰 BuildContext / 仓储，
/// 便于纯 Dart 单测（与 `buildPlanExportV2Package` 同样的取舍）。
class PlanShareSummary {
  const PlanShareSummary({
    required this.planName,
    required this.area,
    required this.workCount,
    required this.pointCount,
    required this.groupCount,
    required this.completedCount,
    required this.recordCount,
  });

  final String planName;
  final String area;
  final int workCount;
  final int pointCount;
  final int groupCount;
  final int completedCount;
  final int recordCount;

  /// 打卡进度百分比（0–100）。没有巡礼点时按 0 处理，避免出现除零。
  int get progressPercent {
    if (pointCount <= 0) {
      return 0;
    }
    final percent = (completedCount * 100) / pointCount;
    return percent.clamp(0, 100).round();
  }

  /// 没有任何巡礼点时不值得分享。
  bool get isEmpty => pointCount == 0;

  /// 已打卡数不会超过总点数（历史数据里可能存在残留的 completedPointIds）。
  bool get hasProgress => completedCount > 0;
}

/// 从计划与打卡记录推导分享摘要。
///
/// [completedPointIds] 里可能残留已删除的点 id，这里只统计仍然存在的点，
/// 保证「已打卡 X/M」不会出现 X > M 的怪值。
PlanShareSummary buildPlanShareSummary({
  required PilgrimagePlan plan,
  List<PilgrimageVisitRecord> visitRecords = const <PilgrimageVisitRecord>[],
}) {
  final pointIds = plan.points.map((point) => point.id).toSet();
  final completedCount = pointIds.where(plan.completedPointIds.contains).length;
  final workCount = plan.works.isNotEmpty
      ? plan.works.length
      : plan.points.map((point) => point.work.id).toSet().length;

  return PlanShareSummary(
    planName: plan.name,
    area: plan.area.trim(),
    workCount: workCount,
    pointCount: plan.points.length,
    groupCount: plan.groups.length,
    completedCount: completedCount,
    recordCount: visitRecords.length,
  );
}

/// 生成可直接粘贴到群聊 / 社交平台的分享文案。
///
/// [l10n] 直接传入而非 BuildContext，保持纯函数（测试里可用
/// `lookupAppLocalizations` 构造）。
String buildPlanShareMessage(
  AppLocalizations l10n,
  PlanShareSummary summary,
) {
  final lines = <String>[
    l10n.planShareTitle(summary.planName),
    l10n.planShareStats(summary.workCount, summary.pointCount),
  ];
  if (summary.area.isNotEmpty) {
    lines.add(l10n.planShareArea(summary.area));
  }
  if (summary.hasProgress) {
    lines.add(
      l10n.planShareProgress(
        summary.completedCount,
        summary.pointCount,
        summary.progressPercent,
      ),
    );
  }
  if (summary.recordCount > 0) {
    lines.add(l10n.planShareRecords(summary.recordCount));
  }
  lines.add(l10n.planShareFooter);
  return lines.join('\n');
}

/// 分享时附带的主题行（邮件 / 部分社交平台会用到）。
String buildPlanShareSubject(AppLocalizations l10n, PlanShareSummary summary) {
  return l10n.planShareTitle(summary.planName);
}

/// 空计划时的兜底提示，避免分享出一份没有内容的清单。
String planShareEmptyMessage(AppLocalizations l10n) {
  return l10n.planShareEmpty;
}

/// 便于测试在无 widget 树时取得中文 l10n（与导出模块同一回退策略）。
AppLocalizations planShareFallbackLocalizations() {
  return lookupAppLocalizations(const Locale('zh'));
}
