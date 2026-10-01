import 'package:flutter/material.dart';
import 'package:cadence/screens/main_home_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CadenceColors.background,
      ),
      home: const MainHomeScreen(),
    );
  }
}
