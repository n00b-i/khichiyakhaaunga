import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/shell/main_shell.dart';

class ComebakApp extends StatelessWidget {
  const ComebakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'comebak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}
