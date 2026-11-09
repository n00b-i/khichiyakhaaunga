import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/floating_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // S-04 I7: IndexedStack preserves the state (scroll position, form drafts)
  // of each tab when switching between them.
  final List<Widget> _tabs = const [
    HomeScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // S-04 I8: Hide the island when the keyboard is open.
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    
    // S-04 E1/E2: Dynamic safe area padding for devices with gesture nav or notches.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      // S-04 I4/I5: Android system back behavior.
      // If we are on the Home tab, allow the app to close (canPop: true).
      // If we are on Stats or Profile, intercept the back action.
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          // Redirect back to Home tab instead of closing the app.
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        // Allows the tab content to scroll underneath the floating island.
        extendBody: true,
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
        bottomNavigationBar: isKeyboardOpen
            ? null
            : Padding(
                // Floating margin: 8px if no inset, else respect the device inset.
                padding: EdgeInsets.only(
                  bottom: bottomInset > 0 ? bottomInset : AppSpacing.xs,
                ),
                child: FloatingNavBar(
                  currentIndex: _currentIndex,
                  onTabSelected: (index) {
                    // S-04 I2: Haptic is intentionally OFF here (reserved for games).
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
      ),
    );
  }
}
