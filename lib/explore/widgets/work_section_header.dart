import 'package:flutter/material.dart';

import '../../app_theme.dart';

/// Section title on the Explore tab (e.g. "最新作品", "京阿尼名作选").
class WorkSectionHeader extends StatelessWidget {
  const WorkSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
