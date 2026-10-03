import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cadence/screens/main_home_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CadenceColors.background,
        splashColor: CadenceColors.accent.withValues(alpha: 0.14),
        highlightColor: CadenceColors.accent.withValues(alpha: 0.06),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CadencePageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CadencePageTransitionsBuilder(),
            TargetPlatform.windows: CadencePageTransitionsBuilder(),
            TargetPlatform.fuchsia: CadencePageTransitionsBuilder(),
          },
        ),
      ),
      home: const MainHomeScreen(),
    );
  }
}
