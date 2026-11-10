import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // [1] Supabase import
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/games/models/bubble.dart';
import '../../../core/games/models/game_fx.dart';
import '../../../core/games/widgets/bubble_painter.dart';
import '../../../core/games/widgets/game_hud.dart';
import '../game_result_screen.dart';
import '../../../core/games/repository/game_repository.dart'; // [2] Repository import

class MadBurstScreen extends StatefulWidget {
  final Color accentColor;
  const MadBurstScreen({super.key, required this.accentColor});

  @override
  State<MadBurstScreen> createState() => _MadBurstScreenState();
}

class _MadBurstScreenState extends State<MadBurstScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final Random _random = Random();

  // [3] DB Match Tracking Variables
  late GameRepository _gameRepo;
  String? _currentMatchId;

  int _score = 0;
  int _target = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hits = 0;
  int _misses = 0;
  bool _gameStarted = false;
  bool _isFrozen = false;
  double _exactTimeLeft = 60.0;
  
  int _countdown = 3;
  bool _showCountdown = true;
  Timer? _countdownTimer;

  final List<Bubble> _bubbles = [];
  final List<FloatingText> _floatingTexts = [];
  final List<Particle> _particles = [];
  Bubble? _selectedBubble;

  Size _playAreaSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _startCountdown();

    // [4] Initialize DB Match
    _gameRepo = GameRepository(Supabase.instance.client);
    _gameRepo.startMatch('mad_burst').then((id) => _currentMatchId = id);
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
    for (int i = 0; i < 6; i++) {
      _bubbles.add(_generateBubbleData());
    }
    _target = _calculateTarget(_bubbles);
  }

  Bubble _generateBubbleData() {
    int value;
    do {
      value = _random.nextInt(9) + 1;
    } while (_bubbles.any((b) => b.value == value) && _bubbles.length < 9);

    final radius = 40.0;
    final bottomBound = _playAreaSize.height;
    final pos = Offset(
      radius + 20 + _random.nextDouble() * (_playAreaSize.width - radius * 2 - 40),
      radius + 10 + _random.nextDouble() * (bottomBound - radius * 2 - 20),
    );
    
    final vel = Offset(
      (_random.nextDouble() - 0.5) * 150,
      (_random.nextDouble() - 0.5) * 150,
    );

    return Bubble(value: value, position: pos, velocity: vel, radius: radius);
  }

  int _calculateTarget(List<Bubble> board) {
    if (board.length < 2) return 10;
    final b1 = board[_random.nextInt(board.length)];
    Bubble b2;
    do {
      b2 = board[_random.nextInt(board.length)];
    } while (b2.id == b1.id);
    return b1.value * b2.value; // Multiplication logic
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_gameStarted || _showCountdown) return;
    
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt > 0.1) return; 

    final currentElapsed = elapsed.inMilliseconds / 1000.0;
    final remaining = 60.0 - currentElapsed;
    
    if (remaining <= 0) {
      _exactTimeLeft = 0;
      _endGame();
      return;
    }

    setState(() {
      _exactTimeLeft = remaining;
      
      if (!_isFrozen) {
        final bottomBound = _playAreaSize.height;
        for (var b in _bubbles) {
          b.update(dt, _playAreaSize, 0, bottomBound);
        }
        resolveBubbleCollisions(_bubbles);
      }

      _floatingTexts.removeWhere((t) => t.opacity <= 0);
      for (var t in _floatingTexts) { t.update(dt); }
      
      _particles.removeWhere((p) => p.opacity <= 0);
      for (var p in _particles) { p.update(dt); }
    });
  }

  void _handleTap(TapDownDetails details) {
    if (_isFrozen || _exactTimeLeft <= 0 || _showCountdown) return;

    final tapPos = details.localPosition;
    Bubble? tapped;
    for (var b in _bubbles) {
      if ((b.position - tapPos).distance <= b.radius) {
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
          _hits++;
          _combo++;
          if (_combo > _bestCombo) _bestCombo = _combo;
          
          final points = 10 + ((_combo - 1) * 2).clamp(0, 20);
          _score += points;
          
          SystemSound.play(SystemSoundType.click);
          _addFx(activeTapped.position, '+$points', AppColors.primary, true);
          
          final survivors = _bubbles.where((b) => b.id != activeSelected.id && b.id != activeTapped.id).toList();
          final nextBubble1 = _generateBubbleData();
          final nextBubble2 = _generateBubbleData();
          final nextBoardState = [...survivors, nextBubble1, nextBubble2];
          final nextTarget = _calculateTarget(nextBoardState);
          
          _bubbles.clear();
          _bubbles.addAll(nextBoardState);
          _target = nextTarget;
          _selectedBubble = null;
          
          _isFrozen = true;
          _ticker.muted = true;
          Future.delayed(const Duration(milliseconds: 180), () {
            if (mounted) {
              setState(() => _isFrozen = false);
              _ticker.muted = false;
            }
          });
        } else {
          _misses++;
          _combo = 0;
          _score = _score - 5; 
          
          Vibration.vibrate(duration: 100, amplitude: 255); 
          
          activeTapped.isWrong = true;
          _addFx(activeTapped.position, '-5', AppColors.vibrantRed, false);

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
    _floatingTexts.add(FloatingText(position: pos, text: text, color: color));
    if (isBurst) {
      for (int i = 0; i < 10; i++) {
        final angle = _random.nextDouble() * pi * 2;
        final speed = 50 + _random.nextDouble() * 100;
        _particles.add(Particle(
          position: pos,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: AppColors.vibrantGreen,
          size: 2 + _random.nextDouble() * 4,
        ));
      }
    }
  }

  void _endGame() {
    _ticker.stop();
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0.0 : ((_hits / totalTaps) * 100.0);

    // [5] Save Match to DB
    if (_currentMatchId != null) {
      _gameRepo.endMatch(
        matchId: _currentMatchId!,
        gameId: 'mad_burst',
        score: _score,
        accuracy: accuracy,
        durationSeconds: 60,
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          score: _score,
          accuracy: accuracy.round(),
          bestCombo: _bestCombo,
          gameBuilder: () => MadBurstScreen(accentColor: widget.accentColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

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
                Positioned(
                  top: 105,
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTapDown: _handleTap,
                    behavior: HitTestBehavior.opaque,
                    child: CustomPaint(
                      painter: BubblePainter(
                        bubbles: _bubbles,
                        floatingTexts: _floatingTexts,
                        particles: _particles,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  child: GameHud(
                    timeLeft: _exactTimeLeft,
                    maxTime: 60,
                    target: _target,
                    score: _score,
                    operationPrefix: 'x',
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.xl,
                  left: AppSpacing.lg,
                  child: Text(
                    'Tap 2 bubbles with product as target',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
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
                            Text(
                              '$_countdown',
                              style: AppTextStyles.display.copyWith(fontSize: 100),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text('Mad Burst', style: AppTextStyles.hud.copyWith(color: widget.accentColor)),
                            SizedBox(height: AppSpacing.md),
                            Text('Multiply two numbers to hit the target.', style: AppTextStyles.body),
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