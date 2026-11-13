import '../models/game_config.dart';

// ==============================================================================
// [CONFIGS] Game Configurations
// ------------------------------------------------------------------------------
// [ISSUE-27] GameConfig is the single source of truth for all game metadata.
// Titles, instructions, HUD prefixes, and HUD labels here are used by BOTH
// the Home Screen and the Game Screens. Do not hardcode strings in the UI.
// ==============================================================================

class AddBurstConfig {
  static const standard = GameConfig(
    gameId: 'add_burst',
    duration: Duration(seconds: 60),
    // [HUD] We show a '+' prefix and the label 'SUM TO' (e.g., +15).
    hudOperationPrefix: '+',
    hudTargetLabel: 'SUM',
    title: 'Add Burst',
    instructions: 'Tap bubbles adding to sum',
  );
}

class MadBurstConfig {
  static const standard = GameConfig(
    gameId: 'mad_burst',
    duration: Duration(seconds: 60),
    // [HUD] We show a 'x' prefix and the label 'PRODUCT' (e.g., x24).
    hudOperationPrefix: 'x',
    hudTargetLabel: 'PRODUCT',
    title: 'Mad Burst',
    instructions: 'Tap bubbles matching the product',
  );
}

class NumberHuntConfig {
  static const standard = GameConfig(
    gameId: 'small_burst',
    duration: Duration(seconds: 60),
    // [HUD] Number Hunt has no mathematical target. We hide both the
    // prefix and the label.
    hudOperationPrefix: '',
    hudTargetLabel: null,
    title: 'Small Burst',
    instructions: 'Tap the smallest number',
  );
}

class BodmasBurstConfig {
  static const standard = GameConfig(
    gameId: 'bodmas_burst',
    duration: Duration(seconds: 60),
    // [HUD] BODMAS uses a custom numpad and the equation is the focal point.
    // No target pill is shown.
    hudOperationPrefix: '',
    hudTargetLabel: null,
    title: 'School Math',
    instructions: 'Try to solve maximum problems',
  );
}

class DevilsMemoryConfig {
  static const addition = GameConfig(
    gameId: 'devils_memory_add',
    duration: Duration(seconds: 60),
    // [HUD] Addition variant. Shows '+' and 'SUM' (e.g., +15).
    hudOperationPrefix: '+',
    hudTargetLabel: 'SUM',
    title: 'Devil\'s Memory',
    instructions: 'Test your memory.\nDon\'t blink!',
  );

  static const multiplication = GameConfig(
    gameId: 'devils_memory_mul',
    duration: Duration(seconds: 60),
    // [HUD] Multiplication variant. Shows 'x' and 'PRODUCT' (e.g., x24).
    hudOperationPrefix: 'x',
    hudTargetLabel: 'PRODUCT',
    title: 'Devil\'s Memory',
    instructions: 'Test your memory.\nDon\'t blink!',
  );
}
