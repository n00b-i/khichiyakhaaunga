import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'auth_gate.dart';

class ComebakApp extends StatelessWidget {
  const ComebakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ComeBak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // AuthGate handles routing based on login state
      home: const AuthGate(),
    );
  }
}