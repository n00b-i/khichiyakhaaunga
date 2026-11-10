import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/foss_theme.dart';
import 'auth_gate.dart';

class ComebakApp extends StatelessWidget {
  const ComebakApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [ISSUE: fossui-adaptation] Wrap the app in FossTheme and FossToaster.
    // FossTheme makes context.fossTheme available to every fossui widget.
    // FossToaster hosts toast overlays — must be mounted once near root.
    return FossTheme(
      data: FossAppTheme.dark,
      child: FossToaster(
        child: MaterialApp(
          title: 'comebak',
          debugShowCheckedModeBanner: false,
          // [DUAL THEME] MaterialTheme still feeds Material widgets (until migrated).
          // FossTheme feeds fossui widgets via context.fossTheme.
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const AuthGate(),
        ),
      ),
    );
  }
}