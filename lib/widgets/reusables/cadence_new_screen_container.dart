import 'package:flutter/material.dart';
import 'package:cadence/widgets/cadence_app_bar.dart';
import 'package:cadence/widgets/reusables/cadence_screen_container.dart';

class CadenceNewScreenContainer extends StatelessWidget {
  const CadenceNewScreenContainer({
    super.key,
    required this.children,
    this.spacing = 0.0,
    this.fab,
    this.fabPosition = FloatingActionButtonLocation.centerDocked,
  });

  final List<Widget> children;
  final double spacing;
  final Widget? fab;
  final FloatingActionButtonLocation? fabPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CadenceAppBar(),
      floatingActionButton: fab,
      floatingActionButtonLocation: fabPosition,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CadenceScreenContainer(spacing: spacing, children: children),
      ),
    );
  }
}
