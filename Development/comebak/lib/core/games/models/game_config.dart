// Immutable configuration for a specific game mode.
class GameConfig {
  final String gameId;
  final Duration duration;
  final Duration countdown;
  final bool pauseOnBackground;
  final String hudOperationPrefix;
  final String title;
  final String instructions;

  const GameConfig({
    required this.gameId,
    required this.duration,
    this.countdown = const Duration(seconds: 3),
    this.pauseOnBackground = true,
    this.hudOperationPrefix = '',
    required this.title,
    required this.instructions,
  });
}
