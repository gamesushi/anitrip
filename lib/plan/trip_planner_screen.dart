import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import 'pilgrimage_models.dart';
import 'trip_itinerary.dart';

/// 多日行程 / 交通规划页（D2）。
///
/// 群里的真实痛点是「秩父一天走不完、三峰神社很远」——也就是**行程**而不是地图。
/// 这里不接路网 API（离线可用、零依赖），用「直线距离 × 绕行系数 ÷ 平均速度」
/// 估算站点间耗时，再按每天可用时长把巡礼点切成若干天，并给出当天时间线。
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({required this.plan, super.key});

  final PilgrimagePlan plan;

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  var _mode = TravelMode.walk;
  var _budgetHours = 8;
  var _spotMinutes = kDefaultSpotVisitMinutes;

  TripItinerary get _itinerary => buildTripItinerary(
        stops: itineraryStopsFromPlan(widget.plan),
        mode: _mode,
        spotVisitMinutes: _spotMinutes,
        dailyBudgetMinutes: _budgetHours * 60,
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final itinerary = _itinerary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.tripPlannerTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (itinerary.isEmpty)
            _TripEmptyCard(message: l10n.tripPlannerEmpty)
          else ...[
            _TripOverview(itinerary: itinerary),
            const SizedBox(height: 14),
            _TripControls(
              mode: _mode,
              budgetHours: _budgetHours,
              spotMinutes: _spotMinutes,
              onModeChanged: (mode) => setState(() => _mode = mode),
              onBudgetChanged: (hours) => setState(() => _budgetHours = hours),
              onSpotChanged: (minutes) => setState(() => _spotMinutes = minutes),
            ),
            const SizedBox(height: 14),
            for (final day in itinerary.days) ...[
              _TripDayCard(day: day, itinerary: itinerary),
              const SizedBox(height: 10),
            ],
            _TripNote(note: l10n.tripPlannerNote),
          ],
        ],
      ),
    );
  }
}

class _TripEmptyCard extends StatelessWidget {
  const _TripEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.route_outlined, color: AppColors.accentDark),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripOverview extends StatelessWidget {
  const _TripOverview({required this.itinerary});

  final TripItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tripPlannerOverview,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          _OverviewRow(
            icon: Icons.calendar_today_outlined,
            text: l10n.tripPlannerDaysNeeded(itinerary.dayCount),
          ),
          const SizedBox(height: 6),
          _OverviewRow(
            icon: Icons.straighten_outlined,
            text: l10n.tripPlannerTotalDistance(
              formatTripDistance(itinerary.totalDistanceMeters),
            ),
          ),
          const SizedBox(height: 6),
          _OverviewRow(
            icon: Icons.schedule_outlined,
            text: l10n.tripPlannerTotalDuration(
              formatTripDuration(itinerary.totalMinutes),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripControls extends StatelessWidget {
  const _TripControls({
    required this.mode,
    required this.budgetHours,
    required this.spotMinutes,
    required this.onModeChanged,
    required this.onBudgetChanged,
    required this.onSpotChanged,
  });

  final TravelMode mode;
  final int budgetHours;
  final int spotMinutes;
  final ValueChanged<TravelMode> onModeChanged;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<int> onSpotChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ControlLabel(text: l10n.tripPlannerModeLabel),
          SegmentedButton<TravelMode>(
            segments: [
              ButtonSegment(
                value: TravelMode.walk,
                icon: const Icon(Icons.directions_walk_outlined),
                label: Text(l10n.tripPlannerModeWalk),
              ),
              ButtonSegment(
                value: TravelMode.transit,
                icon: const Icon(Icons.directions_bus_outlined),
                label: Text(l10n.tripPlannerModeTransit),
              ),
              ButtonSegment(
                value: TravelMode.drive,
                icon: const Icon(Icons.directions_car_outlined),
                label: Text(l10n.tripPlannerModeDrive),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (values) => onModeChanged(values.first),
          ),
          const SizedBox(height: 12),
          _ControlLabel(text: l10n.tripPlannerBudgetLabel),
          SegmentedButton<int>(
            segments: [
              for (final hours in const [4, 6, 8, 10])
                ButtonSegment(
                  value: hours,
                  label: Text(l10n.tripPlannerBudgetOption(hours)),
                ),
            ],
            selected: {budgetHours},
            onSelectionChanged: (values) => onBudgetChanged(values.first),
          ),
          const SizedBox(height: 12),
          _ControlLabel(text: l10n.tripPlannerSpotLabel),
          SegmentedButton<int>(
            segments: [
              for (final minutes in const [15, 30, 45, 60])
                ButtonSegment(
                  value: minutes,
                  label: Text(l10n.tripPlannerSpotOption(minutes)),
                ),
            ],
            selected: {spotMinutes},
            onSelectionChanged: (values) => onSpotChanged(values.first),
          ),
        ],
      ),
    );
  }
}

class _ControlLabel extends StatelessWidget {
  const _ControlLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _TripDayCard extends StatelessWidget {
  const _TripDayCard({required this.day, required this.itinerary});

  final TripDay day;
  final TripItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final distance = formatTripDistance(day.distanceMeters);
    final duration = formatTripDuration(day.totalMinutes);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_outlined, color: AppColors.accentDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.tripPlannerDayTitle(day.index),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Text(
                '${tripDayLoadPercent(day, itinerary.dailyBudgetMinutes)}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tripPlannerDayMeta(day.pointCount, distance, duration),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.tripPlannerDeparture(_formatTime(context, day.startAt)),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          for (final stop in day.stops)
            _TripStopRow(stop: stop, mode: itinerary.mode),
        ],
      ),
    );
  }
}

class _TripStopRow extends StatelessWidget {
  const _TripStopRow({required this.stop, required this.mode});

  final TripDayStop stop;
  final TravelMode mode;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      if (stop.stop.workTitle.isNotEmpty) stop.stop.workTitle,
      if (stop.travelMinutes > 0 || stop.travelMeters > 0)
        '${formatTripDuration(stop.travelMinutes)} · ${formatTripDistance(stop.travelMeters)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Text(
              _formatTime(context, stop.arrivalAt),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.stop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripNote extends StatelessWidget {
  const _TripNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Text(
      note,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0,
      ),
    );
  }
}

String _formatTime(BuildContext context, DateTime time) {
  return TimeOfDay.fromDateTime(time).format(context);
}
