import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/games/models/bubble.dart';
import '../../../core/games/models/game_fx.dart';
import '../../../core/games/models/board_paint_state.dart';
import '../../../core/games/widgets/bubble_painter.dart';
import '../../../core/games/utils/game_diagnostics.dart';
import '../../../core/games/repository/game_repository.dart';
import '../../../core/games/models/game_config.dart';
import '../../../core/games/configs/game_configs.dart';
import '../../../core/games/mixins/game_timer_mixin.dart';
// UI LAB IMPORTS: The new SSOT for HUD and Results
import '../../debug/ui_lab/5_catalog/game_flow/widgets/comebak_game_hud_widget.dart';
import '../../debug/ui_lab/5_catalog/game_flow/comebak_game_over_page.dart';

// ==============================================================================
// [SCREEN] NumberHuntScreen
// ------------------------------------------------------------------------------
// ARCHITECTURE:
// Number Hunt shares the same physics engine as Add/Mad Burst. The key
// difference is the win condition: the user must tap the SMALLEST number
// on the board, not a pair that matches a target.
//
// PERFORMANCE:
// The game loop mutates _board in place and calls _board.tickNotify() to
// repaint only the BubblePainter. The HUD is isolated via ValueListenableBuilder.
// ==============================================================================
class NumberHuntScreen extends StatefulWidget {
  final Color accentColor;
  final GameConfig config;

  const NumberHuntScreen({
    super.key,
    required this.accentColor,
    this.config = NumberHuntConfig.standard,
  });

  @override
  State<NumberHuntScreen> createState() => _NumberHuntScreenState();
}

class _NumberHuntScreenState extends State<NumberHuntScreen>
    with SingleTickerProviderStateMixin, GameTimerMixin {
  // ============================================================================
  // [STATE] Game Engine & Logic
  // ============================================================================
  final Random _random = Random();
  late GameRepository _gameRepo;
  String? _currentMatchId;

  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hits = 0;
  int _misses = 0;
  bool _gameStarted = false;

  int _countdown = 3;
  bool _showCountdown = true;
  Timer? _countdownTimer;

  // ============================================================================
  // [STATE] Render Isolation (Crucial for 60fps)
  // ----------------------------------------------------------------------------
  // We do NOT use setState for the game loop. If we did, the entire widget
  // tree would rebuild 60 times a second. Instead, we mutate _board in place
  // and notify the _painter. For the HUD clock, we use a ValueNotifier.
  // ============================================================================
  final BoardPaintState _board = BoardPaintState();
  late final BubblePainter _painter = BubblePainter(board: _board);
  final ValueNotifier<Duration> _timeLeftListenable = ValueNotifier(
    Duration.zero,
  );

  Size _playAreaSize = Size.zero;

  // ============================================================================
  // [TIMER MIXIN OVERRIDES]
  // ============================================================================
  @override
  GameConfig get config => widget.config;

  @override
  bool get isTimerActive => _gameStarted && !_showCountdown;

  @override
  void onTimerUpdate(Duration timeLeft) {
    // Updates only the HUD, not the physics board.
    _timeLeftListenable.value = timeLeft;
  }

  @override
  void onTimeUp() {
    _endGame();
  }

  // ============================================================================
  // [PHYSICS ENGINE TICK]
  // ----------------------------------------------------------------------------
  // Fires every frame (60fps). Updates positions, handles collisions, and
  // removes dead bubbles without triggering a Flutter widget rebuild.
  // ============================================================================
  @override
  void onTimerTick(double dt) {
    if (!mounted) return;

    final bottomBound = _playAreaSize.height;

    // 1. Move bubbles
    for (final b in _board.bubbles) {
      b.update(dt, _playAreaSize, 0, bottomBound);
    }

    // 2. Resolve collisions (bounce off walls/each other)
    resolveBubbleCollisions(_board.bubbles);

    // 3. Update floating texts (+10, -5)
    _board.floatingTexts.removeWhere((t) => t.opacity <= 0);
    for (final t in _board.floatingTexts) {
      t.update(dt);
    }

    // 4. Update particles (explosions)
    _board.particles.removeWhere((p) => p.opacity <= 0);
    for (final p in _board.particles) {
      p.update(dt);
    }

    // 5. Handle exit animations (matched bubbles shrinking)
    for (final b in _board.bubbles) {
      if (b.isExiting) b.updateExit(dt);
    }
    _board.bubbles.removeWhere((b) => b.isExiting && b.scale <= 0.0);

    // 6. Trigger repaint
    _board.tickNotify();
  }

  // ============================================================================
  // [LIFECYCLE] Init & Countdown
  // ============================================================================
  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Initialize the Supabase match to track stats
    _gameRepo = GameRepository(Supabase.instance.client);
    _gameRepo.startMatch('small_burst').then((id) => _currentMatchId = id);
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _showCountdown = false;
          _gameStarted = true;
          _spawnInitialBubbles();
          timer.cancel();
        }
      });
    });
  }

  // ============================================================================
  // [GAME MECHANICS]
  // ============================================================================
  void _spawnInitialBubbles() {
    GameDiagnostics.logGameStart('Small Burst');
    GameDiagnostics.printMaxScore('Small Burst', 60, 10);

    // Spawn 8 bubbles with random values 1-99
    for (int i = 0; i < 8; i++) {
      _board.bubbles.add(_generateBubbleData());
    }
  }

  Bubble _generateBubbleData() {
    int value;
    do {
      value = _random.nextInt(99) + 1;
    } while (_board.bubbles.any((b) => b.value == value) &&
        _board.bubbles.length < 20);

    final radius = 40.0;
    final bottomBound = _playAreaSize.height;
    final pos = Offset(
      radius +
          20 +
          _random.nextDouble() * (_playAreaSize.width - radius * 2 - 40),
      radius + 10 + _random.nextDouble() * (bottomBound - radius * 2 - 20),
    );

    final vel = Offset(
      (_random.nextDouble() - 0.5) * 150,
      (_random.nextDouble() - 0.5) * 150,
    );
    return Bubble(value: value, position: pos, velocity: vel, radius: radius);
  }

  // ============================================================================
  // [INPUT HANDLING] Tap to Hunt
  // ============================================================================
  void _handleTap(TapDownDetails details) {
    if (timeLeft <= Duration.zero || _showCountdown) return;

    final tapPos = details.localPosition;
    Bubble? tapped;

    // Find if user tapped a bubble
    for (var b in _board.bubbles) {
      if ((b.position - tapPos).distance <= b.radius) {
        tapped = b;
        break;
      }
    }

    if (tapped == null) return;

    final activeTapped = tapped;

    // Find the smallest number on the board
    int minValue = _board.bubbles
        .where((b) => !b.isExiting)
        .map((b) => b.value)
        .reduce(min);

    setState(() {
      if (activeTapped.value == minValue) {
        // --- CORRECT: Tapped the smallest number ---
        _hits++;
        _combo++;
        if (_combo > _bestCombo) _bestCombo = _combo;

        final points = 10 + ((_combo - 1) * 2).clamp(0, 20);
        _score += points;

        SystemSound.play(SystemSoundType.click);
        _addFx(activeTapped.position, '+$points', AppColors.primary, true);

        activeTapped.startExiting();
        final nextBubble = _generateBubbleData()..scale = 0.0;
        _board.replaceBubbles([..._board.bubbles, nextBubble]);
        _board.tickNotify();
      } else {
        // --- WRONG: Tapped a larger number ---
        _misses++;
        _combo = 0;
        _score -= 5;
        Vibration.vibrate(duration: 100, amplitude: 255);
        activeTapped.isWrong = true;
        _addFx(
          activeTapped.position + const Offset(0, -40),
          '-5',
          AppColors.vibrantRed,
          false,
        );

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => activeTapped.isWrong = false);
        });
      }
    });
  }

  void _addFx(Offset pos, String text, Color color, bool isBurst) {
    _board.floatingTexts.add(
      FloatingText(position: pos, text: text, color: color),
    );
    if (isBurst) {
      for (int i = 0; i < 10; i++) {
        final angle = _random.nextDouble() * pi * 2;
        final speed = 50 + _random.nextDouble() * 100;
        _board.particles.add(
          Particle(
            position: pos,
            velocity: Offset(cos(angle) * speed, sin(angle) * speed),
            color: AppColors.vibrantGreen,
            size: 2 + _random.nextDouble() * 4,
          ),
        );
      }
    }
  }

  // ============================================================================
  // [END GAME] Routing to UI Lab Results
  // ============================================================================
  void _endGame() async {
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0.0 : ((_hits / totalTaps) * 100.0);

    // Save match to DB
    MatchResult? matchResult;
    if (_currentMatchId != null) {
      matchResult = await _gameRepo.endMatch(
        matchId: _currentMatchId!,
        gameId: 'small_burst',
        score: _score,
        accuracy: accuracy,
        durationSeconds: widget.config.duration.inSeconds,
      );
    }

    if (!mounted) return;

    // Calculate XP change (mock logic, can be moved to repository later)
    final xpChange = _score > 0 ? (_score / 10).round() : 0;
    final brokenAfterString = _formatDuration(
      matchResult?.previousPBBrokenAfter,
    );

    // Route to the production Game Over screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ComebakGameOverPage(
          score: _score,
          accuracy: accuracy.round(),
          bestCombo: _bestCombo,
          xpChange: xpChange,
          isNewPb: matchResult?.isNewPB ?? false,
          previousPBBrokenAfter: brokenAfterString,
          gameName: widget.config.title,
          gameBuilder: () => NumberHuntScreen(
            accentColor: widget.accentColor,
            config: widget.config,
          ),
        ),
      ),
    );
  }

  String? _formatDuration(Duration? duration) {
    if (duration == null) return null;
    if (duration.inMinutes < 60) return '${duration.inMinutes} minutes';
    if (duration.inHours < 24) return '${duration.inHours} hours';
    return '${duration.inDays} days';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timeLeftListenable.dispose();
    _board.dispose();
    super.dispose();
  }

  // ============================================================================
  // [BUILD]
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _playAreaSize = Size(
              constraints.maxWidth,
              constraints.maxHeight - 165,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Game Canvas (isolated from HUD rebuilds)
                Positioned(
                  top: 105,
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTapDown: _handleTap,
                    behavior: HitTestBehavior.opaque,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _painter,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // 2. HUD (isolated via ValueListenableBuilder)
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: _timeLeftListenable,
                    builder: (context, timeLeftValue, child) {
                      return ComebakGameHudWidget(
                        timeLeft: timeLeftValue.inMilliseconds / 1000.0,
                        maxTime: widget.config.duration.inSeconds,
                        target: 0,
                        score: _score,
                        showTarget: false, // Number Hunt has no target
                      );
                    },
                  ),
                ),

                // 3. Instruction Text
                Positioned(
                  bottom: AppSpacing.xl,
                  left: AppSpacing.lg,
                  child: Text(
                    'Tap the smallest number',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),

                // 4. Countdown Overlay
                if (_showCountdown)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.background,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$_countdown',
                              style: AppTextStyles.display.copyWith(
                                fontSize: 100,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              widget.config.title,
                              style: AppTextStyles.hud.copyWith(
                                color: widget.accentColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              widget.config.instructions,
                              style: AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
