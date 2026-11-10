
import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/foss_theme.dart';
import 'auth_gate.dart';

/// Root application widget for Comebak.
///
/// Responsibilities:
/// - Initialize the application-wide FossUI theme.
/// - Configure the Material application and its dark theme.
/// - Mount the FossUI toast host within the MaterialApp environment.
/// - Provide the authentication gate as the application entry point.
///
/// Architectural note:
/// FossTheme must remain above MaterialApp so FossUI components
/// throughout the application can access the shared FossUI theme.
/// FossToaster is mounted through MaterialApp.builder so its overlay
/// belongs to the application's widget environment.
class ComebakApp extends StatelessWidget {
  const ComebakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FossTheme(
      // Centralized FossUI design configuration.
      data: FossAppTheme.dark,

      child: MaterialApp(
        // Application identity and debug configuration.
        title: 'comebak',
        debugShowCheckedModeBanner: false,

        // Material theme configuration.
        // Material widgets use AppTheme, while FossUI widgets
        // obtain their design configuration through FossTheme.
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // Application-wide overlay integration.
        //
        // FossToaster must be mounted once above the application
        // screens that need to display notifications.
        //
        // Placing it here gives the toaster access to the
        // MaterialApp-provided widget environment.
        builder: (context, child) {
          return FossToaster(
            child: child ?? const SizedBox.shrink(),
          );
        },

        // Authentication determines the initial application flow.
        // AuthGate handles the transition between authenticated
        // and unauthenticated application states.
        home: const AuthGate(),
      ),
    );
  }
}
