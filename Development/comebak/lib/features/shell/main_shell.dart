import 'package:flutter/material.dart';
import '../debug/ui_lab/5_catalog/comebak_home_flow.dart';

// ==============================================================================
// [SHELL] MainShell
// ------------------------------------------------------------------------------
// PURPOSE: The root shell for the authenticated app. It hosts the Home Flow.
// ARCHITECTURE: No bottom navigation. Profile is accessed via the top-right
// avatar in the Header. Stats is accessed by tapping the Streak Card.
// ==============================================================================
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComebakHomeFlow();
  }
}
