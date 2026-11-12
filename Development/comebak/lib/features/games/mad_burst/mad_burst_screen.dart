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
import '../../../core/games/widgets/game_hud.dart';
import '../game_result_screen.dart';
import '../../../core/games/repository/game_repository.dart';
import '../../../core/games/models/game_config.dart';
import '../../../core/games/configs/game_configs.dart';
import '../../../core/games/mixins/game_timer_mixin.dart';

class MadBurstScreen extends StatefulWidget {
  final GameConfig config;
  final Color accentColor;
  const MadBurstScreen({super.key, required this.accentColor, this.config = MadBurstConfig.standard});

  @override
  State<MadBurstScreen> createState() => _MadBurstScreenState();
}

class _MadBurstScreenState extends State<MadBurstScreen>
    with SingleTickerProviderStateMixin, GameTimerMixin {
  final Random _random = Random();
  late GameRepository _gameRepo;
  String? _currentMatchId;

  int _score = 0;
  int _target = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hits = 0;
  int _misses = 0;
  bool _gameStarted = false;

  int _countdown = 3;
  bool _showCountdown = true;
  Timer? _countdownTimer;

  // [ISSUE-1] Isolated state for physics/paint.
  final BoardPaintState _board = BoardPaintState();
  late final BubblePainter _painter = BubblePainter(board: _board);
  
  // [ISSUE-1] Separate Listenable for HUD time.
  final ValueNotifier<Duration> _timeLeftListenable = ValueNotifier(Duration.zero);
  
  Bubble? _selectedBubble;
  Size _playAreaSize = Size.zero;

  @override
  GameConfig get config => widget.config;

  @override
  bool get isTimerActive => _gameStarted && !_showCountdown;

  @override
  void onTimerUpdate(Duration timeLeft) {
    _timeLeftListenable.value = timeLeft;
  }

  @override
  void onTimeUp() {
    _endGame();
  }

  @override
  void onTimerTick(double dt) {
    if (!mounted) return;
    
    // [ISSUE-30] Flow like air: Physics never stops.
    final bottomBound = _playAreaSize.height;
    for (final b in _board.bubbles) {
      b.update(dt, _playAreaSize, 0, bottomBound);
    }
    resolveBubbleCollisions(_board.bubbles);

    _board.floatingTexts.removeWhere((t) => t.opacity <= 0);
    for (final t in _board.floatingTexts) { t.update(dt); }

    _board.particles.removeWhere((p) => p.opacity <= 0);
    for (final p in _board.particles) { p.update(dt); }

    // [ISSUE-30] Process exit animations every tick.
    for (final b in _board.bubbles) {
      if (b.isExiting) b.updateExit(dt);
    }
    _board.bubbles.removeWhere((b) => b.isExiting && b.scale <= 0.0);

    _board.tickNotify();
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _gameRepo = GameRepository(Supabase.instance.client);
    _gameRepo.startMatch(widget.config.gameId).then((id) => _currentMatchId = id);
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

  void _spawnInitialBubbles() {
    final list = <Bubble>[for (int i = 0; i < 6; i++) _generateBubbleData()];
    _board.replaceBubbles(list);
    _target = _calculateTarget(_board.bubbles);
  }

  Bubble _generateBubbleData() {
    int value;
    do {
      value = _random.nextInt(9) + 1;
    } while (_board.bubbles.any((b) => b.value == value) && _board.bubbles.length < 9);

    final radius = 40.0;
    final bottomBound = _playAreaSize.height;
    final pos = Offset(
      radius + 20 + _random.nextDouble() * (_playAreaSize.width - radius * 2 - 40),
      radius + 10 + _random.nextDouble() * (bottomBound - radius * 2 - 20),
    );

    final vel = Offset((_random.nextDouble() - 0.5) * 150, (_random.nextDouble() - 0.5) * 150);
    return Bubble(value: value, position: pos, velocity: vel, radius: radius);
  }

  int _calculateTarget(List<Bubble> board) {
    // [ISSUE-30] Ignore bubbles that are animating out so they don't affect the math.
    final activeBoard = board.where((b) => !b.isExiting).toList();
    if (activeBoard.length < 2) return 10;
    final b1 = activeBoard[_random.nextInt(activeBoard.length)];
    Bubble b2;
    do {
      b2 = activeBoard[_random.nextInt(activeBoard.length)];
    } while (b2.id == b1.id);
    // [MAD-BURST] Multiplication logic
    return b1.value * b2.value;
  }

  void _handleTap(TapDownDetails details) {
    if (timeLeft <= Duration.zero || _showCountdown) return;

    final tapPos = details.localPosition;
    Bubble? tapped;
    for (var b in _board.bubbles) {
      // [ISSUE-30] You cannot tap a bubble that is currently shrinking away.
      if (!b.isExiting && (b.position - tapPos).distance <= (b.radius * b.scale)) {
        tapped = b;
        break;
      }
    }

    if (tapped == null) return;
    final activeTapped = tapped;

    setState(() {
      if (_selectedBubble == null) {
        _selectedBubble = activeTapped;
        activeTapped.isSelected = true;
      } else if (_selectedBubble!.id == activeTapped.id) {
        _selectedBubble!.isSelected = false;
        _selectedBubble = null;
      } else {
        final activeSelected = _selectedBubble!;
        final product = activeSelected.value * activeTapped.value;

        if (product == _target) {
          _hits++; _combo++;
          if (_combo > _bestCombo) _bestCombo = _combo;

          final points = 10 + ((_combo - 1) * 2).clamp(0, 20);
          _score += points;

          SystemSound.play(SystemSoundType.click);
          _addFx(activeTapped.position + const Offset(0, -40), '+$points', AppColors.primary, true);

          // [ISSUE-30] Start exit animation instead of instant removal
          activeSelected.startExiting();
          activeTapped.startExiting();

          // [ISSUE-30] Spawn new bubbles at scale 0.0 so they grow in
          final nextBubble1 = _generateBubbleData()..scale = 0.0;
          final nextBubble2 = _generateBubbleData()..scale = 0.0;
          
          // [ISSUE-30] Append new bubbles without deleting the old ones immediately.
          _board.replaceBubbles([..._board.bubbles, nextBubble1, nextBubble2]);
          
          // [ISSUE-30] Recalculate target, ignoring the dying bubbles.
          _target = _calculateTarget(_board.bubbles);
          _selectedBubble = null;

          // [ISSUE-30] Force immediate repaint so matched bubbles instantly turn green before the freeze.
          _board.tickNotify(); 


        } else {
          _misses++; _combo = 0; _score = _score - 5;
          Vibration.vibrate(duration: 100, amplitude: 255);
          activeTapped.isWrong = true;
          _addFx(activeTapped.position + const Offset(0, -40), '-5', AppColors.vibrantRed, false);

          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) setState(() => activeTapped.isWrong = false);
          });
          activeSelected.isSelected = false;
          _selectedBubble = null;
        }
      }
    });
  }

  void _addFx(Offset pos, String text, Color color, bool isBurst) {
    _board.floatingTexts.add(FloatingText(position: pos, text: text, color: color));
    if (isBurst) {
      for (int i = 0; i < 10; i++) {
        final angle = _random.nextDouble() * pi * 2;
        final speed = 50 + _random.nextDouble() * 100;
        _board.particles.add(Particle(
          position: pos,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: AppColors.vibrantGreen,
          size: 2 + _random.nextDouble() * 4,
        ));
      }
    }
  }

  void _endGame() async {
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0.0 : ((_hits / totalTaps) * 100.0);

    MatchResult? matchResult;
    if (_currentMatchId != null) {
      matchResult = await _gameRepo.endMatch(
        matchId: _currentMatchId!,
        gameId: widget.config.gameId,
        score: _score,
        accuracy: accuracy,
        durationSeconds: widget.config.duration.inSeconds,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          score: _score,
          accuracy: accuracy.round(),
          bestCombo: _bestCombo,
          isNewPB: matchResult?.isNewPB ?? false,
          previousPBBrokenAfter: matchResult?.previousPBBrokenAfter,
          gameBuilder: () => MadBurstScreen(accentColor: widget.accentColor, config: widget.config),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _timeLeftListenable.dispose();
    _board.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _playAreaSize = Size(constraints.maxWidth, constraints.maxHeight - 165);

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 105, bottom: 60, left: 0, right: 0,
                  child: GestureDetector(
                    onTapDown: _handleTap,
                    behavior: HitTestBehavior.opaque,
                    // [ISSUE-1] RepaintBoundary limits repaint scope. 
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _painter, child: const SizedBox.expand()),
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md, left: AppSpacing.md, right: AppSpacing.md,
                  // [ISSUE-1] Only the HUD listens to the clock.
                  child: ValueListenableBuilder<Duration>(
                    valueListenable: _timeLeftListenable,
                    builder: (context, timeLeftValue, child) {
                      return GameHud(
                        timeLeft: timeLeftValue.inMilliseconds / 1000.0,
                        maxTime: widget.config.duration.inSeconds,
                        target: _target,
                        score: _score,
                        operationPrefix: widget.config.hudOperationPrefix,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.xl, left: AppSpacing.lg, right: AppSpacing.lg,
                  child: Text(
                    widget.config.instructions, textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: AppColors.textPrimary.withValues(alpha: 0.6), fontSize: 14),
                  ),
                ),
                if (_showCountdown)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.background,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_countdown', style: AppTextStyles.display.copyWith(fontSize: 100)),
                            SizedBox(height: AppSpacing.lg),
                            Text(widget.config.title, style: AppTextStyles.hud.copyWith(color: widget.accentColor)),
                            SizedBox(height: AppSpacing.md),
                            Text(widget.config.instructions, style: AppTextStyles.body),
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