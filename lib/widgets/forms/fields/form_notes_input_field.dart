import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormNotesInputField extends StatelessWidget {
  const FormNotesInputField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          'Title',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: CadenceColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLength: 100,
            minLines: 5,
            maxLines: 5,
            textAlignVertical: TextAlignVertical.top,
            cursorColor: CadenceColors.textSecondary,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textPrimary,
              fontSize: 16,
            ),
            autocorrect: false,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Add notes here...',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: CadenceColors.textSecondary,
                fontSize: 16,
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
