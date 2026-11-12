import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/debug/ui_lab/1_foundations/tokens/ui_lab_tokens.dart';
import 'features/debug/ui_lab/5_catalog/catalog_home.dart'; // [UPDATED IMPORT]

// ==============================================================================
// [ENTRY POINT] UI Lab
// ==============================================================================
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ComebakColors.canvas,
        fontFamily: GoogleFonts.urbanist().fontFamily,
        primaryColor: ComebakColors.neonGreen,
      ),
      // [NAVIGATION] Starts at the Catalog Index.
      home: const ComebakCatalogHome(),
    );
  }
}