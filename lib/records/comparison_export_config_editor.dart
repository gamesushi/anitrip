import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../l10n/app_localizations.dart';
import 'comparison_export_config.dart';

class ComparisonExportConfigEditor extends StatelessWidget {
  const ComparisonExportConfigEditor({
    required this.config,
    required this.pilgrimNameController,
    required this.onChanged,
    super.key,
  });

  final ComparisonExportConfig config;
  final TextEditingController pilgrimNameController;
  final ValueChanged<ComparisonExportConfig> onChanged;

  static List<Color> get borderColorOptions => <Color>[
    Colors.white,
    Colors.black,
    AppColors.accent,
  ];

  

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComparisonAppearanceSection(
          config: config,
          borderColorOptions: borderColorOptions,
          borderColorLabels: [AppLocalizations.of(context)!.comparisonBorderColorWhite, AppLocalizations.of(context)!.comparisonBorderColorBlack, AppLocalizations.of(context)!.comparisonBorderColorTheme],
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
        ComparisonMetadataSection(
          config: config,
          pilgrimNameController: pilgrimNameController,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

String comparisonExportConfigSummary(BuildContext context, ComparisonExportConfig config) {
  final labels = <String>[
    AppLocalizations.of(context)!.comparisonWidthLabel(config.outputWidth.getLocalizedLabel(context)),
    config.borderWidthPercent == 0 ? AppLocalizations.of(context)!.comparisonNoBorder : AppLocalizations.of(context)!.comparisonBorderPercent(config.borderWidthPercent.toStringAsFixed(1)),
    config.showLabels ? AppLocalizations.of(context)!.comparisonShowLabels : AppLocalizations.of(context)!.comparisonHideLabels,
  ];
  if (config.showPilgrimName && config.pilgrimName.trim().isNotEmpty) {
    labels.add(AppLocalizations.of(context)!.comparisonPilgrimName(config.pilgrimName.trim()));
  }
  return labels.join(' / ');
}

class ComparisonAppearanceSection extends StatelessWidget {
  const ComparisonAppearanceSection({
    required this.config,
    required this.borderColorOptions,
    required this.borderColorLabels,
    required this.onChanged,
    super.key,
  });

  final ComparisonExportConfig config;
  final List<Color> borderColorOptions;
  final List<String> borderColorLabels;
  final ValueChanged<ComparisonExportConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(AppLocalizations.of(context)!.comparisonSectionAppearance),
        const SizedBox(height: 8),
        Row(
          children: [
            _FieldLabel(AppLocalizations.of(context)!.comparisonFieldBorderWidth),
            const Spacer(),
            Text(
              config.borderWidthPercent == 0
                  ? AppLocalizations.of(context)!.comparisonBorderWidthNone
                  : '${config.borderWidthPercent.toStringAsFixed(1)}%',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: config.borderWidthPercent,
          min: 0,
          max: 3.0,
          divisions: 30,
          onChanged: (v) => onChanged(config.copyWith(borderWidthPercent: v)),
        ),
        const SizedBox(height: 12),
        _FieldLabel(AppLocalizations.of(context)!.comparisonFieldBorderColor),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            for (var i = 0; i < borderColorOptions.length; i += 1)
              _ColorOption(
                color: borderColorOptions[i],
                label: borderColorLabels[i],
                selected: config.borderColor == borderColorOptions[i],
                onTap: () => onChanged(
                  config.copyWith(borderColor: borderColorOptions[i]),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _FieldLabel(AppLocalizations.of(context)!.comparisonFieldOutputWidth),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ComparisonOutputWidth.values
              .map((ow) {
                return _OptionChip(
                  label: ow.getLocalizedLabel(context),
                  selected: config.outputWidth == ow,
                  onSelected: () => onChanged(config.copyWith(outputWidth: ow)),
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.comparisonLabelShowLabel,
              style: TextStyle(fontSize: 14, letterSpacing: 0),
            ),
            const Spacer(),
            Switch(
              value: config.showLabels,
              onChanged: (v) => onChanged(config.copyWith(showLabels: v)),
            ),
          ],
        ),
      ],
    );
  }
}

class ComparisonMetadataSection extends StatelessWidget {
  const ComparisonMetadataSection({
    required this.config,
    required this.pilgrimNameController,
    required this.onChanged,
    super.key,
  });

  final ComparisonExportConfig config;
  final TextEditingController pilgrimNameController;
  final ValueChanged<ComparisonExportConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(AppLocalizations.of(context)!.comparisonSectionMetadata),
        const SizedBox(height: 8),
        TextFormField(
          controller: pilgrimNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.comparisonFieldPilgrimName,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => onChanged(config.copyWith(pilgrimName: value)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.comparisonShowPilgrimRight,
                style: TextStyle(fontSize: 14, letterSpacing: 0),
              ),
            ),
            Switch(
              value: config.showPilgrimName,
              onChanged: (v) => onChanged(config.copyWith(showPilgrimName: v)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.comparisonShowGradingBottom,
                style: TextStyle(fontSize: 14, letterSpacing: 0),
              ),
            ),
            Switch(
              value: config.showColorGradingParams,
              onChanged: (v) =>
                  onChanged(config.copyWith(showColorGradingParams: v)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth >= 360
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 8,
              runSpacing: 2,
              children: ComparisonMetadataField.values
                  .map((field) {
                    final selected = config.metadataFields.contains(field);
                    return SizedBox(
                      width: itemWidth,
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (_) {
                              final updated = Set<ComparisonMetadataField>.from(
                                config.metadataFields,
                              );
                              if (selected) {
                                updated.remove(field);
                              } else {
                                updated.add(field);
                              }
                              onChanged(
                                config.copyWith(metadataFields: updated),
                              );
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Expanded(
                            child: Text(
                              field.getLocalizedLabel(context),
                              style: const TextStyle(
                                fontSize: 14,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surfaceMuted,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) => onSelected(),
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? (color == AppColors.accent
                          ? AppColors.textPrimary
                          : AppColors.accent)
                    : color == Colors.white
                    ? AppColors.border
                    : Colors.transparent,
                width: selected ? 3 : 1,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: color.computeLuminance() > 0.55
                        ? AppColors.textPrimary
                        : Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
