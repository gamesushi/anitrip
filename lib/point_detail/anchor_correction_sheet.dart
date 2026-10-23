import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../app_theme.dart';
import '../data/pilgrimage_repository.dart';
import '../l10n/app_localizations.dart';
import '../plan/pilgrimage_models.dart';
import '../widgets/snackbar_helper.dart';

/// P0-1 — 报告位置错误 (anchor-location correction report).
///
/// Opened as a nested bottom sheet on top of [PointDetailSheet]. The user can
/// supply a corrected coordinate either by "use my current location" (the
/// realistic pilgrimage scenario: stand at the real spot and tap) or by typing
/// lat/lng manually, plus an optional photo and a free-text description. The
/// report is stored locally via [PilgrimageRepository.submitAnchorCorrection]
/// so it survives without a backend; the developer can later export/forward the
/// queue to the upstream data source.
class AnchorCorrectionSheet extends StatefulWidget {
  const AnchorCorrectionSheet({
    required this.point,
    required this.repository,
    this.planId,
    super.key,
  });

  final PilgrimagePoint point;
  final PilgrimageRepository repository;
  final String? planId;

  static Future<void> show(
    BuildContext context, {
    required PilgrimagePoint point,
    required PilgrimageRepository repository,
    String? planId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return AnchorCorrectionSheet(
          point: point,
          repository: repository,
          planId: planId,
        );
      },
    );
  }

  @override
  State<AnchorCorrectionSheet> createState() => _AnchorCorrectionSheetState();
}

class _AnchorCorrectionSheetState extends State<AnchorCorrectionSheet> {
  final _descriptionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  LatLng? _suggested;
  String? _photoPath;
  bool _isGettingLocation = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    if (_isGettingLocation) {
      return;
    }
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnack(AppLocalizations.of(context)!.gpsDisabled);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSnack(AppLocalizations.of(context)!.correctionLocationDenied);
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;
      _suggested = LatLng(position.latitude, position.longitude);
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
      setState(() {});
    } on TimeoutException {
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context)!.gpsTimeout);
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context)!.correctionLocationDenied);
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _onLatLngChanged() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    if (lat != null && lng != null && _isValidCoordinate(lat, lng)) {
      if (_suggested != LatLng(lat, lng)) {
        _suggested = LatLng(lat, lng);
        setState(() {});
      }
    } else if (_suggested != null) {
      _suggested = null;
      setState(() {});
    }
  }

  bool _isValidCoordinate(double lat, double lng) =>
      lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _photoPath = picked.path);
  }

  /// Straight-line distance in meters between the original anchor and the
  /// user-suggested coordinate; shown so the user can sanity-check their input.
  double get _offsetFromOriginal {
    final suggested = _suggested;
    if (suggested == null) {
      return 0;
    }
    return const Distance().as(
      LengthUnit.Meter,
      widget.point.position,
      suggested,
    );
  }

  bool get _hasDetail =>
      _descriptionController.text.trim().isNotEmpty || _photoPath != null;

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (!_hasDetail && _suggested == null) {
      _showSnack(AppLocalizations.of(context)!.correctionNeedDetail);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.repository.submitAnchorCorrection(
        AnchorCorrectionInput(
          planId: widget.planId,
          pointId: widget.point.id,
          workId: widget.point.work.id,
          workTitle: widget.point.work.title,
          pointName: widget.point.name,
          source: widget.point.source.name,
          sourceId: widget.point.sourceId,
          pointLatitude: widget.point.position.latitude,
          pointLongitude: widget.point.position.longitude,
          suggestedLatitude: _suggested?.latitude,
          suggestedLongitude: _suggested?.longitude,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          photoPath: _photoPath,
        ),
      );
      if (!mounted) return;
      _showSnack(
        AppLocalizations.of(context)!.correctionSuccessBody,
        duration: const Duration(seconds: 3),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      _showSnack(AppLocalizations.of(context)!.msgReplaceRefFailed);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showReplacingSnackBar(
      SnackBar(content: Text(message), duration: duration ?? const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final current = widget.point.position;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.correctionTitle,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.point.work.title} / ${widget.point.name}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: l10n.correctionCurrentLocation,
              value:
                  '${current.latitude.toStringAsFixed(5)}, ${current.longitude.toStringAsFixed(5)}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _useMyLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_outlined, size: 18),
                label: Text(
                  _isGettingLocation
                      ? l10n.correctionGettingLocation
                      : l10n.correctionUseMyLocation,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CoordinateField(
                    controller: _latController,
                    label: l10n.correctionLatitude,
                    onChanged: (_) => _onLatLngChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CoordinateField(
                    controller: _lngController,
                    label: l10n.correctionLongitude,
                    onChanged: (_) => _onLatLngChanged(),
                  ),
                ),
              ],
            ),
            if (_suggested != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.correctionSuggestedLocation} · '
                '${_offsetFromOriginal.toStringAsFixed(0)} m',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: l10n.correctionDescription,
                hintText: l10n.correctionDescriptionHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_photoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_photoPath!),
                  height: 96,
                  width: 96,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: Text(l10n.correctionAddPhoto),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? Text(l10n.correctionSubmitting)
                    : Text(l10n.correctionSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinateField extends StatelessWidget {
  const _CoordinateField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 19),
        const SizedBox(width: 8),
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
