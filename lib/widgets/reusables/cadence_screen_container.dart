import 'package:flutter/material.dart';

class CadenceScreenContainer extends StatelessWidget {
  const CadenceScreenContainer({
    super.key,
    required this.children,
    this.spacing = 0.0,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing,
        children: children,
      ),
    );
  }
}
