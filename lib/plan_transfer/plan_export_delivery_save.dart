import 'dart:typed_data';

import 'package:file_selector/file_selector.dart' as file_selector;

import 'plan_export_delivery_result.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<PreparedPlanExportDestination?> preparePlanExportDestinationImpl({
  required BuildContext context,
  required String fileName,
  required String mimeType,
  required String extension,
}) async {
  final location = await _getSaveLocation(
    context: context,
    fileName: fileName,
    mimeType: mimeType,
    extension: extension,
  );
  if (location == null) {
    throw const PlanExportCanceledException();
  }
  return _FileSelectorPreparedDestination(
    location: location,
    fileName: fileName,
    mimeType: mimeType,
  );
}

Future<PlanExportDeliveryResult> deliverPlanExportImpl({
  required BuildContext context,
  required List<int> bytes,
  required String fileName,
  required String mimeType,
  required String shareSubject,
  required String shareText,
  required String extension,
}) async {
  final location = await _getSaveLocation(
    context: context,
    fileName: fileName,
    mimeType: mimeType,
    extension: extension,
  );
  if (location == null) {
    return const PlanExportDeliveryResult(PlanExportDeliveryAction.canceled);
  }

  return _FileSelectorPreparedDestination(
    location: location,
    fileName: fileName,
    mimeType: mimeType,
  ).save(bytes);
}

Future<file_selector.FileSaveLocation?> _getSaveLocation({
  required String fileName,
  required String mimeType,
  required String extension,
  required BuildContext context,
}) {
  return file_selector.getSaveLocation(
    acceptedTypeGroups: [
      file_selector.XTypeGroup(
        label: 'anitrip data package',
        extensions: [extension],
        mimeTypes: [mimeType],
      ),
    ],
    suggestedName: fileName,
    confirmButtonText: AppLocalizations.of(context)!.btnSave,
  );
}

class _FileSelectorPreparedDestination
    implements PreparedPlanExportDestination {
  const _FileSelectorPreparedDestination({
    required this.location,
    required this.fileName,
    required this.mimeType,
  });

  final file_selector.FileSaveLocation location;
  final String fileName;
  final String mimeType;

  @override
  Future<PlanExportDeliveryResult> save(List<int> bytes) async {
    final file = file_selector.XFile.fromData(
      Uint8List.fromList(bytes),
      mimeType: mimeType,
      name: fileName,
    );
    await file.saveTo(location.path);
    return PlanExportDeliveryResult(
      PlanExportDeliveryAction.saved,
      path: location.path,
    );
  }
}
