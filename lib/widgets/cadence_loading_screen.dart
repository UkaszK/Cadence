import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class CadenceLoadingScreen extends StatefulWidget {
  const CadenceLoadingScreen({super.key});

  @override
  State<CadenceLoadingScreen> createState() => _CadenceLoadingScreenState();
}

class _CadenceLoadingScreenState extends State<CadenceLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      return;
    }
    if (!_controller.isAnimating) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final pulse = reduced
                ? 0.0
                : (math.sin(_controller.value * math.pi * 2) + 1) / 2;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CadenceColors.accent.withValues(
                          alpha: 0.12 + (0.28 * pulse),
                        ),
                        blurRadius: 10 + (18 * pulse),
                      ),
                    ],
                  ),
                  child: child,
                ),
                const SizedBox(height: 16),
                Text(
                  'LOADING',
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            );
          },
          child: const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: CadenceColors.accent,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}
