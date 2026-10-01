import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class LibraryEmptyNote extends StatefulWidget {
  const LibraryEmptyNote({
    super.key,
    this.title = 'LIBRARY EMPTY',
    this.subtitle = 'NOTHING HERE YET',
    this.hint = 'ADD YOUR FIRST ITEM',
  });

  final String title;
  final String subtitle;
  final String hint;

  @override
  State<StatefulWidget> createState() => LibraryEmptyNoteState();
}

class LibraryEmptyNoteState extends State<LibraryEmptyNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CadenceColors.border),
                ),
                child: Icon(
                  Icons.radar,
                  size: 48,
                  color: CadenceColors.border,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                widget.title,
                style: GoogleFonts.jetBrainsMono(
                  letterSpacing: 3,
                  color: CadenceColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                widget.subtitle,
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 64),

          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animation.value),
                child: child,
              );
            },
            child: Column(
              children: [
                Text(
                  widget.hint,
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 16),

                const Icon(
                  Icons.arrow_downward_rounded,
                  color: CadenceColors.accent,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
