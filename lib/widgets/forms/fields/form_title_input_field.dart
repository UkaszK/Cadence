import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormTitleInputField extends StatelessWidget {
  const FormTitleInputField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TITLE',
          style: GoogleFonts.jetBrainsMono(
            color: CadenceColors.textSecondary,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: CadenceColors.textSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: controller,
            maxLength: 25,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textPrimary,
              fontSize: 12,
            ),
            autocorrect: false,
            cursorColor: CadenceColors.textSecondary,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter a title...',
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
