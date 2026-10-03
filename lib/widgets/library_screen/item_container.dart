import 'package:flutter/material.dart';
import 'package:cadence/theme/cadence_colors.dart';

class ItemContainer extends StatelessWidget {
  const ItemContainer({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        border: Border.all(color: color, width: 0.5),
      ),
      child: child,
    );
  }
}
