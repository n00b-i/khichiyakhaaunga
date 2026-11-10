import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/ui/components/bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';
import '../debug/ui_lab/ui_lab_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late bool _isDevMode;

  // [FIX] Dummy trigger to satisfy current StatsScreen until Phase 5 refactor.
  final ValueNotifier<int> _statsRefreshTrigger = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _isDevMode = kDebugMode;
  }

  @override
  void dispose() {
    _statsRefreshTrigger.dispose();
    super.dispose();
  }

  void _toggleDevMode(bool value) {
    setState(() {
      _isDevMode = value;
      if (!_isDevMode && _currentIndex == 3) _currentIndex = 0;
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _statsRefreshTrigger.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final tabs = [
      const HomeScreen(),
      StatsScreen(refreshTrigger: _statsRefreshTrigger), // Removed const and null
      ProfileScreen(
        isDevMode: _isDevMode,
        onToggleDevMode: _toggleDevMode,
      ),
      if (kDebugMode && _isDevMode) const UiLabScreen(),
    ];

    // Build the nav items dynamically based on Dev Mode
    final navItems = [
      NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Stats'),
      NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
      if (kDebugMode && _isDevMode)
        NavItem(icon: Icons.science_outlined, activeIcon: Icons.science, label: 'UI'),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        extendBody: true, // Allows content to scroll under the nav bar
        backgroundColor: AppColors.canvas, // New background token
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: isKeyboardOpen
            ? null
            : BottomNavBar(
                currentIndex: _currentIndex,
                items: navItems,
                onTabSelected: _onTabTapped,
              ),
      ),
    );
  }
}
