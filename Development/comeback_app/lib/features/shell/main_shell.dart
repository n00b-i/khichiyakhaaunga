import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';
import '../debug/ui_lab/ui_lab_screen.dart'; // Added for S-13
import 'widgets/floating_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // S-04 V4: Build tabs based on environment. Release has 3, Debug has 4.
    final tabs = [
      const HomeScreen(),
      const StatsScreen(),
      const ProfileScreen(),
      if (kDebugMode) const UiLabScreen(), // S-13 V1: Debug only
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: isKeyboardOpen
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  bottom: bottomInset > 0 ? bottomInset : AppSpacing.md,
                ),
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  tabCount: tabs.length,
                  onTabSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
      ),
    );
  }
}