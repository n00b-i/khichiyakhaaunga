// ==============================================================================
// [MODEL] GameConfig
// ------------------------------------------------------------------------------
// PURPOSE: The immutable, single source of truth (SSOT) for a specific game mode.
// Every piece of text, timing, and HUD behavior is driven from this configuration.
// This ensures that the Home Screen, Game HUD, and Game Over screens never
// disagree on what a game is called or how it behaves.
// ==============================================================================
class GameConfig {
  /// The unique database identifier for this game (e.g., 'add_burst').
  /// Used by the GameRepository to log matches.
  final String gameId;

  /// Total duration of the gameplay session.
  final Duration duration;

  /// The pre-game countdown before the timer starts.
  final Duration countdown;

  /// If true, the GameTimerMixin will pause the timer if the app goes
  /// to the background or the phone is locked.
  final bool pauseOnBackground;

  /// The mathematical prefix shown before the target number in the HUD.
  /// Examples: '+' for Addition, '×' for Multiplication.
  final String hudOperationPrefix;

  /// The label shown underneath the target number in the HUD.
  /// Examples: 'SUM TO', 'PRODUCT'.
  /// [NULLABLE] Set to `null` if the game does not use a numerical target
  /// (e.g., BODMAS Burst, Number Hunt), which tells the HUD to hide the
  /// target pill entirely.
  final String? hudTargetLabel;

  /// The display name of the game (e.g., 'Add Burst').
  /// Used by the Home Screen cards, Game Over screen, and Game HUD.
  final String title;

  /// The one-sentence instruction shown to the user during the countdown.
  final String instructions;

  const GameConfig({
    required this.gameId,
    required this.duration,
    this.countdown = const Duration(seconds: 3),
    this.pauseOnBackground = true,
    this.hudOperationPrefix = '',
    this.hudTargetLabel = 'TARGET', // Default fallback for games with a target
    required this.title,
    required this.instructions,
  });
}
