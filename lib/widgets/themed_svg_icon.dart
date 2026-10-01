import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cadence/theme/cadence_colors.dart';

class ThemedSvgIcon extends StatelessWidget {
  final String assetPath;

  const ThemedSvgIcon(this.assetPath, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? CadenceColors.textPrimary;
    return SvgPicture.asset(
      assetPath,
      width: 18,
      height: 18,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
