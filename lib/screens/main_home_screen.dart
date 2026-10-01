import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/providers/navigation_bar_providers.dart';
import 'package:cadence/screens/analytics_screen.dart';
import 'package:cadence/screens/dashboard_screen.dart';
import 'package:cadence/screens/library_screen.dart';
import 'package:cadence/screens/planner_screen.dart';
import 'package:cadence/widgets/achievements_screen/achievement_unlock_listener.dart';
import 'package:cadence/widgets/cadence_app_bar.dart';
import 'package:cadence/widgets/cadence_fab.dart';
import 'package:cadence/widgets/cadence_navigation_bar.dart';

class MainHomeScreen extends ConsumerWidget {
  const MainHomeScreen({super.key});

  static const List<Widget> _pages = [
    DashboardScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final notifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      extendBody: true,
      appBar: CadenceAppBar(),
      body: AchievementUnlockListener(
        child: IndexedStack(index: currentIndex, children: _pages),
      ),
      bottomNavigationBar: CadenceNavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: notifier.setIndex,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const CadenceFAB(),
    );
  }
}
