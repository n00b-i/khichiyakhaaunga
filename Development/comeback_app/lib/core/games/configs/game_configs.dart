import '../models/game_config.dart';

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
    hudOperationPrefix: '+',
    title: 'Mad Burst',
    instructions: 'Add two numbers to hit the target. Bubbles move faster.',
  );
}

class NumberHuntConfig {
  static const standard = GameConfig(
    gameId: 'number_hunt',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '',
    title: 'Number Hunt',
    instructions: 'Find the target number.',
  );
}

class BodmasBurstConfig {
  static const standard = GameConfig(
    gameId: 'bodmas_burst',
    duration: Duration(seconds: 60),
    title: 'BODMAS Burst',
    instructions: 'Solve maximum BODMAS problems.',
  );
}

class SaitanConfig {
  static const addition = GameConfig(
    gameId: 'saitan_add',
    duration: Duration(seconds: 60),
    hudOperationPrefix: '+',
    title: 'Saitan +',
    instructions: 'Memorize the grid. Add to target.',
  );

  static const multiplication = GameConfig(
    gameId: 'saitan_mul',
    duration: Duration(seconds: 60),
    hudOperationPrefix: 'x',
    title: 'Saitan X',
    instructions: 'Memorize the grid. Multiply to target.',
  );
}
