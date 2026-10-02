import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/widgets/themed_svg_icon.dart';

class CadenceNavigationBar extends StatelessWidget {
  const CadenceNavigationBar({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  final void Function(int) onDestinationSelected;
  final int selectedIndex;

  Widget _buildNavItem({
    required Widget icon,
    required String label,
    required int index,
  }) {
    return _NavItem(
      icon: icon,
      label: label,
      selected: selectedIndex == index,
      onTap: () => onDestinationSelected(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),

        // Drop Shadow Container
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: CadenceColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CadenceColors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icon(Icons.dashboard),
                    label: 'DASHBOARD',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: ThemedSvgIcon('assets/icons/planner.svg'),
                    label: 'PLANNER',
                    index: 1,
                  ),

                  SizedBox(width: 50),

                  _buildNavItem(
                    icon: ThemedSvgIcon('assets/icons/analytics.svg'),
                    label: 'ANALYTICS',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icon(Icons.library_books),
                    label: 'LIBRARY',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: selected ? 1 : 0),
            duration: CadenceMotion.of(context, AnimationDurations.fast),
            curve: CadenceMotion.enter,
            builder: (context, t, child) {
              final color = Color.lerp(
                CadenceColors.textSecondary,
                CadenceColors.textPrimary,
                t,
              )!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1 + (0.1 * t),
                    child: IconTheme(
                      data: IconThemeData(color: color, size: 22),
                      child: child!,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 16 * t,
                    height: 2,
                    decoration: BoxDecoration(
                      color: CadenceColors.accent.withValues(alpha: t),
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: CadenceColors.accent.withValues(
                            alpha: 0.7 * t,
                          ),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            child: icon,
          ),
        ),
      ),
    );
  }
}
