import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/providers/navigation_bar_providers.dart';
import 'package:cadence/screens/analytics_screen.dart';
import 'package:cadence/screens/dashboard_screen.dart';
import 'package:cadence/screens/library_screen.dart';
import 'package:cadence/screens/planner_screen.dart';
import 'package:cadence/screens/settings_screen.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/cadence_app_bar.dart';
import 'package:cadence/widgets/cadence_fab.dart';
import 'package:cadence/widgets/cadence_navigation_bar.dart';

class MainHomeScreen extends ConsumerStatefulWidget {
  const MainHomeScreen({super.key});

  static const List<Widget> _pages = [
    DashboardScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
    LibraryScreen(),
  ];

  @override
  ConsumerState<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends ConsumerState<MainHomeScreen> {
  final _scrollControllers = [
    for (final _ in MainHomeScreen._pages) ScrollController(),
  ];

  @override
  void dispose() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index != ref.read(navigationProvider)) {
      ref.read(navigationProvider.notifier).setIndex(index);
      return;
    }

    final controller = _scrollControllers[index];
    if (!controller.hasClients) return;

    final top = controller.position.minScrollExtent;
    final duration = CadenceMotion.of(context, AnimationDurations.medium);
    if (duration == Duration.zero) {
      controller.jumpTo(top);
    } else {
      controller.animateTo(
        top,
        duration: duration,
        curve: CadenceMotion.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      extendBody: true,
      appBar: CadenceAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: CadenceColors.textSecondary,
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: CadenceTabSwitcher(
        index: currentIndex,
        children: [
          for (var i = 0; i < MainHomeScreen._pages.length; i++)
            PrimaryScrollController(
              controller: _scrollControllers[i],
              automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
              child: MainHomeScreen._pages[i],
            ),
        ],
      ),
      bottomNavigationBar: CadenceNavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const CadenceFAB(),
    );
  }
}
