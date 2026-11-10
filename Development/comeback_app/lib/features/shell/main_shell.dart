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
  late bool _isDevMode;
  
  // [ISSUE-9] A notifier to tell the StatsScreen to refresh when the tab is tapped.
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
    // [ISSUE-9] If user taps Stats tab, trigger a refresh.
    if (index == 1) {
      _statsRefreshTrigger.value++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final tabs = [
      const HomeScreen(),
      StatsScreen(refreshTrigger: _statsRefreshTrigger), // [ISSUE-9] Passed here
      ProfileScreen(
        isDevMode: _isDevMode,
        onToggleDevMode: _toggleDevMode,
      ),
      if (kDebugMode && _isDevMode) const UiLabScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.background,
        body: IndexedStack(index: _currentIndex, children: tabs),
        bottomNavigationBar: isKeyboardOpen
            ? null
            : Padding(
                padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : AppSpacing.xs),
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  tabCount: tabs.length,
                  onTabSelected: _onTabTapped, // [ISSUE-9] Using new method
                ),
              ),
      ),
    );
  }
}