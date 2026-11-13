// ==============================================================================
// [DEBUG MODEL] StreakDebugPayload
// ------------------------------------------------------------------------------
// PURPOSE: Allows QA to inject arbitrary data into the Home Streak Card
// without needing to modify the database or wait for specific real-world times.
// This is only active when passed explicitly via the Debug Panel.
// ==============================================================================
class StreakDebugPayload {
  final int totalGames;
  final int totalXp;
  final int streak;
  final String? lastPlayedAt; // ISO8601 string
  final int deltaXpToday;
  final int deltaXpYesterday;
  final String? debugNow; // ISO8601 string to override DateTime.now()

  const StreakDebugPayload({
    required this.totalGames,
    required this.totalXp,
    required this.streak,
    this.lastPlayedAt,
    this.deltaXpToday = 0,
    this.deltaXpYesterday = 0,
    this.debugNow,
  });

  /// Parses a JSON map. Throws [FormatException] on invalid data so the
  /// Debug Panel can show an error without crashing the app.
  factory StreakDebugPayload.fromJson(Map<String, dynamic> json) {
    return StreakDebugPayload(
      totalGames: json['totalGames'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] as String?,
      deltaXpToday: json['deltaXpToday'] as int? ?? 0,
      deltaXpYesterday: json['deltaXpYesterday'] as int? ?? 0,
      debugNow: json['debugNow'] as String?,
    );
  }

  /// Converts back to JSON for the "Copy" button in the Debug Panel.
  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'totalXp': totalXp,
      'streak': streak,
      if (lastPlayedAt != null) 'lastPlayedAt': lastPlayedAt,
      if (deltaXpToday != 0) 'deltaXpToday': deltaXpToday,
      if (deltaXpYesterday != 0) 'deltaXpYesterday': deltaXpYesterday,
      if (debugNow != null) 'debugNow': debugNow,
    };
  }
}
