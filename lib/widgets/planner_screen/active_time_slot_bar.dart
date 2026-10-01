import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cadence/data/time_slot.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/widgets/reusables/cadence_button.dart';

class ActiveTimeSlotBar extends StatefulWidget {
  const ActiveTimeSlotBar({
    super.key,
    required this.timeSlot,
    required this.onReset,
    required this.pendingItemName,
    required this.onSave,
    required this.onClearItem,
    required this.hasOverlap,
    required this.isEditingExistingItem,
    required this.onDelete,
    required this.onUpdateTimeSlot,
    required this.onClickAddItem,
    required this.onEditDetails,
    this.canEditDetails = true,
  });

  final TimeSlot timeSlot;
  final VoidCallback onReset;
  final String pendingItemName;
  final VoidCallback onSave;
  final VoidCallback onClearItem;
  final bool hasOverlap;
  final bool isEditingExistingItem;
  final VoidCallback onDelete;
  final void Function(TimeSlot) onUpdateTimeSlot;
  final VoidCallback onClickAddItem;
  final VoidCallback onEditDetails;
  final bool canEditDetails;

  @override
  State<ActiveTimeSlotBar> createState() => _ActiveTimeSlotBarState();
}

class _ActiveTimeSlotBarState extends State<ActiveTimeSlotBar> {
  bool expanded = true;

  late TextEditingController _startController;
  late TextEditingController _endController;
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();

  final _timeFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String? _validationError;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: widget.timeSlot.startTime.toHHMM(),
    );
    _endController = TextEditingController(
      text: widget.timeSlot.endTime.toHHMM(),
    );
  }

  @override
  void didUpdateWidget(covariant ActiveTimeSlotBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeSlot.startTime != widget.timeSlot.startTime &&
        !_startFocus.hasFocus) {
      _startController.text = widget.timeSlot.startTime.toHHMM();
    }
    if (oldWidget.timeSlot.endTime != widget.timeSlot.endTime &&
        !_endFocus.hasFocus) {
      _endController.text = widget.timeSlot.endTime.toHHMM();
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    super.dispose();
  }

  (int hour, int minute)? _parseTime(String text) {
    if (text.length != 5) return null;
    final parts = text.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;
    return (hour, minute);
  }

  void _validateAndUpdate() {
    final startText = _startController.text;
    final endText = _endController.text;

    if (startText.length < 5) {
      setState(() {
        _validationError = 'INVALID START TIME';
      });
      return;
    }

    final startParsed = _parseTime(startText);
    if (startParsed == null) {
      setState(() {
        _validationError = 'INVALID START TIME';
      });
      return;
    }

    if (endText.length < 5) {
      setState(() {
        _validationError = 'INVALID END TIME';
      });
      return;
    }

    final endParsed = _parseTime(endText);
    if (endParsed == null) {
      setState(() {
        _validationError = 'INVALID END TIME';
      });
      return;
    }

    final startMinutes = startParsed.$1 * 60 + startParsed.$2;
    final endMinutes = endParsed.$1 * 60 + endParsed.$2;

    if (endMinutes <= startMinutes) {
      setState(() {
        _validationError = 'END TIME MUST BE AFTER START TIME';
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    final newStart = DateTime(
      widget.timeSlot.startTime.year,
      widget.timeSlot.startTime.month,
      widget.timeSlot.startTime.day,
      startParsed.$1,
      startParsed.$2,
    );
    final newEnd = DateTime(
      widget.timeSlot.endTime.year,
      widget.timeSlot.endTime.month,
      widget.timeSlot.endTime.day,
      endParsed.$1,
      endParsed.$2,
    );

    if (newStart != widget.timeSlot.startTime ||
        newEnd != widget.timeSlot.endTime) {
      widget.onUpdateTimeSlot((startTime: newStart, endTime: newEnd));
    }
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required MaskTextInputFormatter formatter,
  }) {
    return Container(
      width: 58,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        border: Border.all(
          color: _validationError != null
              ? CadenceColors.danger
              : CadenceColors.accent.withValues(alpha: 0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        inputFormatters: [formatter],
        onChanged: (_) => _validateAndUpdate(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          color: CadenceColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 4),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasInvalidTime = _validationError != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        border: const Border(
          bottom: BorderSide(width: 1, color: CadenceColors.accent),
        ),
        boxShadow: [
          BoxShadow(
            color: CadenceColors.accent.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: CadenceColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SLOT:',
                        style: GoogleFonts.jetBrainsMono(
                          color: CadenceColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTimeField(
                        controller: _startController,
                        focusNode: _startFocus,
                        formatter: _timeFormatter,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '-',
                          style: GoogleFonts.jetBrainsMono(
                            color: CadenceColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildTimeField(
                        controller: _endController,
                        focusNode: _endFocus,
                        formatter: _timeFormatter,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onReset,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: CadenceColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),

            if (_validationError != null) ...[
              const SizedBox(height: 6),
              Text(
                _validationError!,
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.danger,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Divider(height: 1),

            const SizedBox(height: 6),

            if (widget.pendingItemName.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          (widget.hasOverlap || hasInvalidTime)
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          size: 16,
                          color: (widget.hasOverlap || hasInvalidTime)
                              ? CadenceColors.danger
                              : CadenceColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.pendingItemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              color: (widget.hasOverlap || hasInvalidTime)
                                  ? CadenceColors.danger
                                  : CadenceColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (widget.isEditingExistingItem &&
                            widget.canEditDetails) ...[
                          InkWell(
                            onTap: widget.onEditDetails,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: CadenceColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  CadenceButton(
                    primaryColor: CadenceColors.accent,
                    onPress: widget.onSave,
                    disabled: widget.hasOverlap || hasInvalidTime,
                    label: 'SAVE',
                    prefixIcon: Icons.check,
                  ),
                  const SizedBox(width: 8),
                  if (widget.isEditingExistingItem)
                    InkWell(
                      onTap: widget.onDelete,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: CadenceColors.danger,
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: widget.onClearItem,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: CadenceColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),

              if (widget.hasOverlap && !hasInvalidTime) ...[
                const SizedBox(height: 4),
                Text(
                  'OVERLAPS AN EXISTING BLOCK',
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: CadenceButton(
                  primaryColor: CadenceColors.accent,
                  label: 'ADD TO SLOT',
                  prefixIcon: Icons.add,
                  onPress: widget.onClickAddItem,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
