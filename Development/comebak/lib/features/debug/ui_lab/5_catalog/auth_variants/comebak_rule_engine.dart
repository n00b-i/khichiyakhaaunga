import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==============================================================================
// [SERVICE] ComebakRuleEngine
// ------------------------------------------------------------------------------
// PURPOSE: Pick a rule from the pool, persist which rules have been seen, and
//   guarantee no-repeat until all rules are exhausted.
// NOW: 1 hardcoded rule.
// LATER: 200 rules in `_rules`. Zero other code changes required — the pool
//   logic, prefs persistence, and cycle reset all handle N=1 and N=200 the
//   same way.
// STORAGE KEYS:
//   comebak_seen_rules   — List<String> (JSON array of rule IDs)
//   comebak_cycle_id     — int (increments when all rules seen)
// FAILURE MODE: If SharedPreferences read fails, returns rule[0] and does
//   NOT crash. The user sees a rule; persistence is skipped for that open.
// ==============================================================================

class ComebakRule {
  /// Stable ID — used for tracking seen rules across sessions.
  final String id;

  /// 1–2 word ALL-CAPS hook. Examples: "LISTEN", "ALWAYS REMEMBER", "NOW".
  final String hook;

  /// The one-liner. 8–18 words. Sentence case.
  final String line;

  /// Category — for authoring organization only. Not used in logic.
  final String category;

  /// Weight 1–3. 3 = 3× more likely to be picked. Used later for distribution.
  final int weight;

  const ComebakRule({
    required this.id,
    required this.hook,
    required this.line,
    required this.category,
    this.weight = 1,
  });
}

class ComebakRuleEngine {
  static const String _seenKey = 'comebak_seen_rules';
  static const String _cycleKey = 'comebak_cycle_id';

  // ===========================================================================
  // THE RULE POOL.
  // Right now: 1 hardcoded rule the user explicitly asked to remember.
  // Later: 200 rules. No other code changes.
  // ===========================================================================
  static const List<ComebakRule> _rules = <ComebakRule>[
    ComebakRule(
      id: 'rule_001',
      hook: 'ALWAYS REMEMBER',
      line: 'Giving up is not in the blood, sir!',
      category: 'resilience',
      weight: 3,
    ),
  ];

  /// Pick a rule that hasn't been shown in this cycle.
  /// Returns a non-null rule always (falls back to _rules.first on prefs error).
  Future<ComebakRule> pickRule() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read seen IDs and current cycle
      final seenJson = prefs.getString(_seenKey);
      final seen = seenJson == null
          ? <String>{}
          : (jsonDecode(seenJson) as List).cast<String>().toSet();

      // Pool = rules not yet seen
      final pool = _rules.where((r) => !seen.contains(r.id)).toList();

      // Cycle exhausted → reset
      if (pool.isEmpty) {
        seen.clear();
        final nextCycle = (prefs.getInt(_cycleKey) ?? 0) + 1;
        await prefs.setInt(_cycleKey, nextCycle);
        pool.addAll(_rules);
      }

      // Weighted random pick from pool
      final picked = _weightedPick(pool);

      // Persist
      seen.add(picked.id);
      await prefs.setString(_seenKey, jsonEncode(seen.toList()));

      return picked;
    } catch (e) {
      // Never block the splash on persistence failure.
      debugPrint('ComebakRuleEngine: prefs failure — $e');
      return _rules.first;
    }
  }

  ComebakRule _weightedPick(List<ComebakRule> pool) {
    final total = pool.fold<int>(0, (sum, r) => sum + r.weight);
    if (total <= 0) return pool.first;

    var roll = (DateTime.now().microsecondsSinceEpoch % total).toInt();
    for (final r in pool) {
      roll -= r.weight;
      if (roll < 0) return r;
    }
    return pool.last;
  }

  /// Debug only — reset history. Useful in UI Lab to test cycle reset.
  Future<void> resetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenKey);
    await prefs.remove(_cycleKey);
  }
}