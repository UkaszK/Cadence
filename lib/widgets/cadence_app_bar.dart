import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class CadenceAppBar extends AppBar {
  CadenceAppBar({super.key, super.actions})
    : super(
        title: const Text('CADENCE'),
        actionsPadding: const EdgeInsets.only(right: 8),
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          shadows: const [Shadow(color: CadenceColors.accent, blurRadius: 24)],
        ),
        centerTitle: true,
        backgroundColor: CadenceColors.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: CadenceColors.border),
        ),
      );
}
