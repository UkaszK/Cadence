import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_duration_hours_and_minutes.dart';

/// HH:MM duration input. Reports the parsed duration in minutes, or null when
/// the text is incomplete or zero.
class FormDurationField extends StatefulWidget {
  const FormDurationField({
    super.key,
    required this.minutes,
    required this.onChange,
  });

  final int? minutes;
  final void Function(int?) onChange;

  static String format(int minutes) {
    final (h, m) = getDurationHoursAndMinutes(minutes);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static int? parse(String text) {
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(text);
    if (match == null) return null;
    final hours = int.parse(match.group(1)!);
    final minutes = int.parse(match.group(2)!);
    if (minutes > 59) return null;
    final total = hours * 60 + minutes;
    return total == 0 ? null : total;
  }

  @override
  State<FormDurationField> createState() => _FormDurationFieldState();
}

class _FormDurationFieldState extends State<FormDurationField> {
  late final TextEditingController _controller;

  final _timeFormatter = MaskTextInputFormatter(
    mask: '##:##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.minutes == null
          ? ''
          : FormDurationField.format(widget.minutes!),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInvalid =
        _controller.text.isNotEmpty &&
        FormDurationField.parse(_controller.text) == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DURATION (HH:MM)',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isInvalid
                  ? CadenceColors.danger
                  : CadenceColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [_timeFormatter],
            cursorColor: CadenceColors.textSecondary,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textPrimary,
              fontSize: 12,
            ),
            autocorrect: false,
            onChanged: (text) {
              setState(() {});
              widget.onChange(FormDurationField.parse(text));
            },
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.timer_outlined,
                size: 20,
                color: CadenceColors.textSecondary,
              ),
              hintText: '01:00',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textSecondary,
                fontSize: 12,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
