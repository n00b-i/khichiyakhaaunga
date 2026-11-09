import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/splash_screen.dart';

class ComebakApp extends StatelessWidget {
  const ComebakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'comebak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // We now start at the SplashScreen. 
      // Once Auth is fully wired, Splash will route to MainShell if logged in.
      home: const SplashScreen(),
    );
  }
}