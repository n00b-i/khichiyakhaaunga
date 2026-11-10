import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';
import '../debug/ui_lab/ui_lab_screen.dart';
import 'widgets/floating_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  // [1] Dev mode state (Defaults to true in debug, false in release)
  late bool _isDevMode;

  @override
  void initState() {
    super.initState();
    _isDevMode = kDebugMode;
  }

  // [2] Toggle handler for the Profile screen switch
  void _toggleDevMode(bool value) {
    setState(() {
      _isDevMode = value;
      // If turning off dev mode while on the UI tab, kick back to Home
      if (!_isDevMode && _currentIndex == 3) {
        _currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // [3] Build tabs dynamically based on Dev Mode
    final tabs = [
      const HomeScreen(),
      const StatsScreen(),
      ProfileScreen(
        isDevMode: _isDevMode,
        onToggleDevMode: _toggleDevMode,
      ),
      // UI tab only exists if in Debug AND Dev Mode is toggled ON
      if (kDebugMode && _isDevMode) const UiLabScreen(),
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
                  bottom: bottomInset > 0 ? bottomInset : AppSpacing.xs,
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