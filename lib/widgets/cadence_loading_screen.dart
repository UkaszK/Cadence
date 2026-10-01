import 'package:flutter/material.dart';
import 'package:cadence/theme/cadence_colors.dart';

class CadenceLoadingScreen extends StatelessWidget {
  const CadenceLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: CadenceColors.accent),
      ),
    );
  }
}
