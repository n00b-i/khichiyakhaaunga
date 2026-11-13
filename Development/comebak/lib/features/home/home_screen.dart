import 'package:flutter/material.dart';
import '../debug/ui_lab/5_catalog/comebak_home_flow.dart';

// ==============================================================================
// [SCREEN] HomeScreen
// ------------------------------------------------------------------------------
// PURPOSE: Thin wrapper around ComebakHomeFlow for backward compatibility.
// The actual UI lives in the UI Lab component.
// ==============================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComebakHomeFlow();
  }
}
