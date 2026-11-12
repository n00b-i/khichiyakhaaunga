import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/tokens/ui_lab_colors.dart';
import 'features/debug/ui_lab/ui_lab_screen.dart';

// [ENTRY POINT] This is the custom entry point for the UI Lab.
// Flutter requires a void main() function to boot the root isolate.
void main() {
  runApp(const UiLabApp());
}

class UiLabApp extends StatelessWidget {
  const UiLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comebak UI Lab',
      debugShowCheckedModeBanner: false,
      // [THEME] Isolated theme setup so we don't touch the main app's MaterialApp.
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: UiLabColors.canvas,
        // [TYPOGRAPHY] Urbanist is a modern geometric sans-serif.
        // We assign it via fontFamily to bypass the material_ui TextTheme conflict.
        fontFamily: GoogleFonts.urbanist().fontFamily,
        primaryColor: UiLabColors.neonGreen,
      ),
      home: const UiLabScreen(),
    );
  }
}