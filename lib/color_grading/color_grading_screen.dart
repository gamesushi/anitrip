import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';
import '../plan/pilgrimage_plan_controller.dart';
import '../records/visit_record_photo_stub.dart'
    if (dart.library.io) '../records/visit_record_photo_io.dart';
import '../widgets/snackbar_helper.dart';
import 'color_adjustment.dart';
import 'color_grading_params.dart';
import 'graded_photo_storage_stub.dart'
    if (dart.library.io) 'graded_photo_storage_io.dart';

class ColorGradingScreen extends StatefulWidget {
  const ColorGradingScreen({
    required this.record,
    required this.controller,
    this.fallbackReferenceImagePath,
    this.fallbackReferenceImageUrl,
    super.key,
  });

  final PilgrimageVisitRecord record;
  final PilgrimagePlanController controller;
  final String? fallbackReferenceImagePath;
  final String? fallbackReferenceImageUrl;

  @override
  State<ColorGradingScreen> createState() => _ColorGradingScreenState();
}

class _ColorGradingScreenState extends State<ColorGradingScreen> {
  var _loading = true;
  var _matching = false;
  var _saving = false;
  var _showOriginal = false;
  var _intensity = 1.0;
  var _selectedMode = ColorMatchMode.standard;
  Uint8List? _capturedBytes;
  Uint8List? _referenceBytes;
  ColorGradingParams? _targetParams;
  int? _beforeScore;
  int? _afterScore;
  Object? _loadError;
  var _resetPending = false;

  PilgrimageVisitRecord get _record => widget.record;

  ColorGradingParams get _activeParams {
    return ColorGradingParams.lerp(
      ColorGradingParams.defaults,
      _targetParams ?? ColorGradingParams.defaults,
      _intensity,
    );
  }

  int? get _currentToneScore {
    final before = _beforeScore;
    final after = _afterScore;
    if (before == null || after == null) {
      return null;
    }
    return (before + (after - before) * _intensity).round().clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _restoreSavedGrading();
    _loadImages();
  }

  void _restoreSavedGrading() {

    final savedMode = _record.colorGradingMode;
    if (savedMode != null) {
      _selectedMode = ColorMatchMode.values.firstWhere(
        (mode) => mode.name == savedMode,
        orElse: () => ColorMatchMode.standard,
      );
    }

    _intensity = (_record.colorGradingIntensity ?? 1).clamp(0.0, 1.0);
    final paramsJson = _record.colorGradingParamsJson;
    if (paramsJson == null || paramsJson.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(paramsJson);
      if (decoded is Map<String, Object?>) {
        _targetParams = ColorGradingParams.fromJson(decoded);
      }
    } catch (_) {}
  }

  Future<void> _loadImages() async {
    try {
      final sourcePhotoPath = resolveVisitRecordSourcePhotoPath(_record);
      if (sourcePhotoPath == null) {
        throw const FileSystemException('Visit record photo is unavailable');
      }
      final capturedBytes = await File(sourcePhotoPath).readAsBytes();
      final referenceBytes = await _loadReferenceBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _capturedBytes = capturedBytes;
        _referenceBytes = referenceBytes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<Uint8List?> _loadReferenceBytes() async {
    for (final path in [
      _record.referenceImagePath,
      widget.fallbackReferenceImagePath,
    ].whereType<String>()) {
      final file = File(path);
      if (file.existsSync()) {
        return file.readAsBytes();
      }
    }

    final url = _record.referenceImageUrl ?? widget.fallbackReferenceImageUrl;
    if (url == null || url.isEmpty) {
      return null;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    return null;
  }

  Future<void> _runAutoMatch() async {
    final l10n = AppLocalizations.of(context)!;
    final captured = _capturedBytes;
    final reference = _referenceBytes;
    final messenger = ScaffoldMessenger.of(context);
    if (captured == null) {
      messenger.showReplacingSnackBar(SnackBar(content: Text(l10n.failedToReadPilgrimagePhoto2)));
      return;
    }
    if (reference == null) {
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(l10n.noReferenceImageAvailableForAuto2)),
      );
      return;
    }
    if (_matching) {
      return;
    }

    setState(() => _matching = true);
    final result = await autoMatchColorTone(
      capturedBytes: captured,
      referenceBytes: reference,
      mode: _selectedMode,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _matching = false;
      if (result != null) {
        _targetParams = result.targetParams;
        _selectedMode = result.mode;
        _beforeScore = result.beforeScore;
        _afterScore = result.afterScore;
        _intensity = 1.0;
        _resetPending = false;
      }
    });

    messenger.showReplacingSnackBar(
      SnackBar(content: Text(result == null ? l10n.autoColorMatchFailed2 : l10n.autoColorParametersGenerated2)),
    );
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final captured = _capturedBytes;
    final targetParams = _targetParams;
    final messenger = ScaffoldMessenger.of(context);
    if (captured == null || _saving) {
      return;
    }
    if (_resetPending) {
      setState(() => _saving = true);
      final updated = await widget.controller.clearVisitRecordColorGrading(
        record: _record,
      );
      if (!mounted) {
        return;
      }

      setState(() => _saving = false);
      messenger.showReplacingSnackBar(SnackBar(content: Text(l10n.revertedToOriginalPhoto2)));
      Navigator.of(context).pop(updated);
      return;
    }
    if (targetParams == null) {
      messenger.showReplacingSnackBar(
        SnackBar(content: Text(l10n.matchTheColorToneAutomaticallyFirst2)),
      );
      return;
    }

    setState(() => _saving = true);
    final bytes = await renderGradedJpeg(
      imageBytes: captured,
      params: _activeParams,
    );
    final path = await saveGradedPhoto(bytes: bytes, recordId: _record.id);
    if (path == null) {
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      messenger.showReplacingSnackBar(SnackBar(content: Text(l10n.imageViewerSaveFailed)));
      return;
    }

    final updated = await widget.controller.updateVisitRecordColorGrading(
      record: _record,
      originalPhotoPath:
          resolveVisitRecordSourcePhotoPath(_record) ?? _record.sourcePhotoPath,
      gradedPhotoPath: path,
      colorGradingMode: _selectedMode.name,
      colorGradingParamsJson: jsonEncode(targetParams.toJson()),
      colorGradingIntensity: _intensity,
    );
    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    messenger.showReplacingSnackBar(SnackBar(content: Text(l10n.colorGradingResultSaved2)));
    Navigator.of(context).pop(updated);
  }

  void _reset() {
    setState(() {
      _targetParams = null;
      _beforeScore = null;
      _afterScore = null;
      _intensity = 1.0;
      _showOriginal = false;
      _resetPending = _record.hasColorGrading;
    });
  }

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordDetailAutoGrading),
        actions: [TextButton(onPressed: _reset, child: Text(l10n.tooltipReset))],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_loadError != null || _capturedBytes == null) {
      return Center(child: Text(l10n.failedToReadPhoto2));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _StackedPreview(
          referenceBytes: _referenceBytes,
          capturedBytes: _capturedBytes!,
          activeParams: _activeParams,
          showOriginal: _showOriginal || _targetParams == null,
        ),
        SizedBox(height: 12),
        _OriginalHoldButton(
          enabled: _targetParams != null,
          showOriginal: _showOriginal,
          onChanged: (showOriginal) {
            setState(() => _showOriginal = showOriginal);
          },
        ),
        SizedBox(height: 12),
        _ModeSelector(
          selectedMode: _selectedMode,
          onChanged: (mode) {
            setState(() {
              _selectedMode = mode;
              _targetParams = null;
              _beforeScore = null;
              _afterScore = null;
              _intensity = 1.0;
              _resetPending = false;
            });
          },
        ),
        SizedBox(height: 12),
        _ScorePanel(
          hasSavedParams: _targetParams != null,
          beforeScore: _beforeScore,
          currentToneScore: _currentToneScore,
          afterScore: _afterScore,
        ),
        SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _matching ? null : _runAutoMatch,
          icon: _matching
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.auto_fix_high_outlined, size: 18),
          label: Text(_matching ? l10n.matching2 : l10n.autoMatchTone2),
        ),
        if (_targetParams != null) ...[
          SizedBox(height: 12),
          _IntensityControl(
            value: _intensity,
            onChanged: (value) => setState(() => _intensity = value),
          ),
          SizedBox(height: 12),
          _ParameterSummary(activeParams: _activeParams),
        ],
        SizedBox(height: 12),
        _SavePanel(saving: _saving, onSave: _save),
      ],
    );
  }
}

class _StackedPreview extends StatelessWidget {
  const _StackedPreview({
    required this.referenceBytes,
    required this.capturedBytes,
    required this.activeParams,
    required this.showOriginal,
  });

  final Uint8List? referenceBytes;
  final Uint8List capturedBytes;
  final ColorGradingParams activeParams;
  final bool showOriginal;

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _PreviewPane(
            label: l10n.reference2,
            child: referenceBytes == null
                ? Center(child: Text(l10n.noReferenceImage2))
                : Image.memory(referenceBytes!, fit: BoxFit.contain),
          ),
          SizedBox(height: 8),
          _PreviewPane(
            label: showOriginal ? l10n.original2 : l10n.graded3,
            child: showOriginal
                ? Image.memory(capturedBytes, fit: BoxFit.contain)
                : ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      activeParams.toColorMatrix(),
                    ),
                    child: Image.memory(capturedBytes, fit: BoxFit.contain),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: ColoredBox(
          color: AppColors.surfaceMuted,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(child: child),
              Positioned(
                left: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OriginalHoldButton extends StatelessWidget {
  const _OriginalHoldButton({
    required this.enabled,
    required this.showOriginal,
    required this.onChanged,
  });

  final bool enabled;
  final bool showOriginal;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    return Listener(
      onPointerDown: enabled ? (_) => onChanged(true) : null,
      onPointerUp: enabled ? (_) => onChanged(false) : null,
      onPointerCancel: enabled ? (_) => onChanged(false) : null,
      child: OutlinedButton.icon(
        onPressed: enabled ? () {} : null,
        icon: Icon(showOriginal ? Icons.visibility : Icons.visibility_outlined),
        label: Text(showOriginal ? l10n.showingOriginal2 : l10n.holdToShowOriginal2),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selectedMode, required this.onChanged});

  final ColorMatchMode selectedMode;
  final ValueChanged<ColorMatchMode> onChanged;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.matchMode2,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in ColorMatchMode.values)
                ChoiceChip(
                  label: Text(mode.getLocalizedLabel(context)),
                  selected: selectedMode == mode,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(mode),
                  selectedColor: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: selectedMode == mode
                        ? AppColors.accent
                        : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: selectedMode == mode
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({
    required this.hasSavedParams,
    required this.beforeScore,
    required this.currentToneScore,
    required this.afterScore,
  });

  final bool hasSavedParams;
  final int? beforeScore;
  final int? currentToneScore;
  final int? afterScore;

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
      child: beforeScore == null || afterScore == null
          ? Row(
              children: [
                Icon(Icons.auto_fix_high_outlined, color: AppColors.accent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasSavedParams ? l10n.restoredLastColorGradingParameters2 : l10n.saveTheGradedResultAfterAuto2,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.toneMatching2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _ScoreValue(label: l10n.original2, score: beforeScore!),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    _ScoreValue(label: l10n.statusCurrent, score: currentToneScore ?? 0),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    _ScoreValue(label: '100%', score: afterScore!),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ScoreValue extends StatelessWidget {
  const _ScoreValue({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Column(
        children: [
          Text(
            '$score',
            style: TextStyle(
              color: AppColors.accentDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntensityControl extends StatelessWidget {
  const _IntensityControl({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    final percent = (value * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.gradingIntensity2,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ParameterSummary extends StatelessWidget {
  const _ParameterSummary({required this.activeParams});

  final ColorGradingParams activeParams;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.gradingParameters2,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showParameterSheet(context),
                icon: Icon(Icons.tune, size: 18),
                label: Text(l10n.btnView),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            l10n.showsTheParametersActuallyAppliedAt2,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _showParameterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _ParameterSheet(activeParams: activeParams),
    );
  }
}

class _ParameterSheet extends StatelessWidget {
  const _ParameterSheet({required this.activeParams});

  final ColorGradingParams activeParams;

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;
    final items = <_ParameterItem>[
      _ParameterItem(l10n.gradingBrightness, activeParams.brightness, -0.25, 0.25),
      _ParameterItem(l10n.gradingExposure, activeParams.exposure, -1.0, 1.0),
      _ParameterItem(l10n.contrast2, activeParams.contrast, 0.7, 1.4),
      _ParameterItem(l10n.saturation2, activeParams.saturation, 0.5, 1.6),
      _ParameterItem(l10n.gradingTemperature, activeParams.temperature, -1.0, 1.0),
      _ParameterItem(l10n.gradingTint, activeParams.tint, -1.0, 1.0),
      _ParameterItem(l10n.gradingHighlights, activeParams.highlights, -1.0, 1.0),
      _ParameterItem(l10n.gradingShadows, activeParams.shadows, -1.0, 1.0),
      _ParameterItem(l10n.redShadows2, activeParams.redShadowCurve, -1.0, 1.0),
      _ParameterItem(l10n.redMidtones2, activeParams.redMidCurve, -1.0, 1.0),
      _ParameterItem(l10n.redHighlights2, activeParams.redHighlightCurve, -1.0, 1.0),
      _ParameterItem(l10n.greenShadows2, activeParams.greenShadowCurve, -1.0, 1.0),
      _ParameterItem(l10n.greenMidtones2, activeParams.greenMidCurve, -1.0, 1.0),
      _ParameterItem(l10n.greenHighlights2, activeParams.greenHighlightCurve, -1.0, 1.0),
      _ParameterItem(l10n.blueShadows2, activeParams.blueShadowCurve, -1.0, 1.0),
      _ParameterItem(l10n.blueMidtones2, activeParams.blueMidCurve, -1.0, 1.0),
      _ParameterItem(l10n.blueHighlights2, activeParams.blueHighlightCurve, -1.0, 1.0),
    ];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.74,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: items.length + 1,
          separatorBuilder: (_, index) => index == 0
              ? SizedBox(height: 10)
              : Divider(height: 18),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text(
                l10n.gradingParameters2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              );
            }
            return _ParameterRow(item: items[index - 1]);
          },
        ),
      ),
    );
  }
}

class _ParameterItem {
  const _ParameterItem(this.label, this.value, this.min, this.max);

  final String label;
  final double value;
  final double min;
  final double max;
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({required this.item});

  final _ParameterItem item;

  @override
  Widget build(BuildContext context) {

    final activeT = ((item.value - item.min) / (item.max - item.min))
        .clamp(0.0, 1.0)
        .toDouble();
    final activeText = item.value.toStringAsFixed(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Text(
              activeText,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: activeT,
            minHeight: 7,
            backgroundColor: AppColors.surfaceMuted,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

class _SavePanel extends StatelessWidget {
  const _SavePanel({required this.saving, required this.onSave});

  final bool saving;
  final VoidCallback onSave;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.saveResult2,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 6),
          Text(
            l10n.afterSavingTheRecordDetailAnd2,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(Icons.save_outlined, size: 18),
            label: Text(saving ? l10n.saving2 : l10n.saveColorGrading2),
          ),
        ],
      ),
    );
  }
}
