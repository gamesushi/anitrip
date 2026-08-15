import 'package:flutter/material.dart';

import '../../app_theme.dart';

/// Full-width rounded search bar for the Explore tab (and reusable on the map).
///
/// In its default (collapsed) state it is a tappable affordance: tapping invokes
/// [onTap].  When [isActive] is `true` it expands into an active [TextField]
/// backed by a [TextEditingController]; changes are reported via
/// [onQueryChanged] and the user can exit via the leading back/close icon.
class ExploreSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const ExploreSearchBar({
    required this.hintText,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.isActive = false,
    this.queryController,
    this.onQueryChanged,
    this.onClear,
    this.onClose,
    super.key,
  });

  final String hintText;
  final VoidCallback onTap;

  /// Outer margin. Pass [EdgeInsets.zero] when the parent already insets the
  /// bar (e.g. the map overlay column).
  final EdgeInsetsGeometry padding;

  /// When `true` the bar renders as an active text field instead of a
  /// tappable affordance.
  final bool isActive;

  /// External controller so the parent can read / reset the query text.
  /// If null an internal one is created.
  final TextEditingController? queryController;

  /// Called whenever the query text changes while [isActive] is true.
  final ValueChanged<String>? onQueryChanged;

  /// Called when the user taps the trailing clear (×) icon — clears the query
  /// text but keeps the search overlay open so results stay visible.
  final VoidCallback? onClear;

  /// Called when the user taps the leading back arrow — fully exits search.
  final VoidCallback? onClose;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  late TextEditingController _controller;

  TextEditingController get _effectiveController =>
      widget.queryController ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.queryController ?? TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ExploreSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.queryController != oldWidget.queryController &&
        widget.queryController != null) {
      // Parent supplied a new controller; discard our internal one.
      _controller.dispose();
      _controller = widget.queryController!;
    }
  }

  @override
  void dispose() {
    if (_controller != widget.queryController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(widget.isActive ? 12 : 28),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: widget.isActive ? _buildActive() : _buildCollapsed(),
      ),
    );
  }

  /// Collapsed (default) appearance – tappable bar.
  Widget _buildCollapsed() {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.search, size: 22, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  /// Expanded appearance – active TextField with back/clear icons.
  Widget _buildActive() {
    return TextField(
        controller: _effectiveController,
        autofocus: true,
        style: const TextStyle(fontSize: 15, letterSpacing: 0),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.arrow_back, size: 22),
            onPressed: () => _handleClose(),
          ),
          suffixIcon: _effectiveController.text.isNotEmpty
              ? IconButton(
                  icon:
                      Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => _handleClear(),
                )
              : Icon(Icons.search, size: 22, color: AppColors.accent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: widget.onQueryChanged,
        onSubmitted: (_) => _handleSubmit(),
      );
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onClear?.call();
  }

  /// Keyboard "Search"/"Done" action: keep the search overlay open and just
  /// dismiss the keyboard so the results stay on screen.
  void _handleSubmit() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  }

  /// Leading back arrow: fully exit the in-app search.
  void _handleClose() {
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    widget.onClose?.call();
  }
}
