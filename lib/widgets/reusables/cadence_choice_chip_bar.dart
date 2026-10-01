import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

enum CadenceChoiceChipBarStyle { filled, outlined }

class CadenceChoiceChipBar<T> extends StatefulWidget {
  CadenceChoiceChipBar({
    super.key,
    required this.options,
    required this.selection,
    required this.onChange,
    required this.labelOf,
    this.iconOf,
    Color Function(T)? primaryColorOf,
    this.style = CadenceChoiceChipBarStyle.filled,
  }) : primaryColorOf = primaryColorOf ?? ((_) => CadenceColors.accent);

  final List<T> options;
  final T selection;
  final void Function(T) onChange;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final Color Function(T) primaryColorOf;
  final CadenceChoiceChipBarStyle style;

  @override
  State<CadenceChoiceChipBar<T>> createState() =>
      _CadenceChoiceChipBarState<T>();
}

class _CadenceChoiceChipBarState<T> extends State<CadenceChoiceChipBar<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollPosition();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final shouldShow = currentScroll < (maxScroll - 5);

    if (shouldShow != _showRightIndicator) {
      setState(() {
        _showRightIndicator = shouldShow;
      });
    }
  }

  ({Color textColor, Color backgroundColor, Color borderColor})
  _getOptionColors(bool isSelected, Color primaryColor) {
    if (widget.style == CadenceChoiceChipBarStyle.filled) {
      return (
        textColor: isSelected
            ? CadenceColors.black
            : CadenceColors.textSecondary,
        backgroundColor: isSelected ? primaryColor : CadenceColors.surface,
        borderColor: isSelected ? primaryColor : CadenceColors.border,
      );
    }

    return (
      textColor: isSelected ? primaryColor : CadenceColors.textSecondary,
      backgroundColor: CadenceColors.background,
      borderColor: isSelected ? primaryColor : CadenceColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          physics: ScrollPhysics(parent: ClampingScrollPhysics()),
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 8,
            children: [
              for (final option in widget.options) ...[
                Builder(
                  builder: (context) {
                    final colors = _getOptionColors(
                      option == widget.selection,
                      widget.primaryColorOf(option),
                    );
                    return _OptionContainer(
                      label: widget.labelOf(option),
                      icon: widget.iconOf?.call(option),
                      onSelect: () => widget.onChange(option),
                      textColor: colors.textColor,
                      backgroundColor: colors.backgroundColor,
                      borderColor: colors.borderColor,
                    );
                  },
                ),
              ],
            ],
          ),
        ),

        if (_showRightIndicator)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CadenceColors.background.withValues(alpha: 0),
                    CadenceColors.background.withValues(alpha: 0.8),
                    CadenceColors.background,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: CadenceColors.textSecondary,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionContainer<T> extends StatelessWidget {
  const _OptionContainer({
    required this.label,
    this.icon,
    required this.onSelect,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onSelect;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(3),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            color: backgroundColor,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: textColor),
                const SizedBox(width: 5),
              ],

              Text(
                label.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
