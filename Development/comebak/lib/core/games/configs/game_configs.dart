import '../models/game_config.dart';

// [ISSUE-27] GameConfig is the single source of truth for all game metadata.
// Titles and instructions here are used by BOTH the Home Screen and the Game Screens.
// Do not hardcode strings in the UI widgets.

class AddBurstConfig {
  static const standard = GameConfig(
    gameId: 'add_burst',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '+',
    title: 'Add Burst',
    instructions: 'Add two numbers to hit the target.',
  );
}

class MadBurstConfig {
  static const standard = GameConfig(
    gameId: 'mad_burst',
    duration: Duration(seconds: 60),
    // [ISSUE-27] Fixed prefix from '+' to 'x' to match multiplication logic.
    hudOperationPrefix: 'x',
    title: 'Mad Burst',
    // [ISSUE-27] Fixed stale instruction. Now matches the home screen and game logic.
    instructions: 'Multiply two numbers to hit the target.',
  );
}

class NumberHuntConfig {
  static const standard = GameConfig(
    gameId: 'small_burst',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '',
    title: 'Small Burst',
    // [ISSUE-27] Aligned with home screen text.
    instructions: 'Find the smallest number.',
  );
}

class BodmasBurstConfig {
  static const standard = GameConfig(
    gameId: 'bodmas_burst',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '',
    title: 'BODMAS Burst',
    instructions: 'Solve maximum BODMAS problems.',
  );
}

class DevilsMemoryConfig {
  static const addition = GameConfig(
    gameId: 'devils_memory_add',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '+',
    title: 'DevilsMemory +',
    instructions: 'Memorize the grid. Add to target.',
  );

  static const multiplication = GameConfig(
    gameId: 'devils_memory_mul',
    duration: Duration(seconds: 60),
    hudOperationPrefix: 'x',
    title: 'DevilsMemory X',
    instructions: 'Memorize the grid. Multiply to target.',
  );
}