import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/games/widgets/game_hud.dart';
import '../game_result_screen.dart';
import 'widgets/custom_numpad.dart';
import '../../../core/games/repository/game_repository.dart';
import '../../../core/games/models/game_config.dart';
import '../../../core/games/configs/game_configs.dart';
import '../../../core/games/mixins/game_timer_mixin.dart';

// Renamed from MathBurstScreen to BodmasBurstScreen to match the UI and Category
class BodmasBurstScreen extends StatefulWidget {
  final GameConfig config;
  final Color accentColor;
  const BodmasBurstScreen({super.key, required this.accentColor, this.config = BodmasBurstConfig.standard});

  @override
  State<BodmasBurstScreen> createState() => _BodmasBurstScreenState();
}

class _BodmasBurstScreenState extends State<BodmasBurstScreen> with SingleTickerProviderStateMixin, GameTimerMixin {
  final Random _random = Random();

  // --- DATABASE INTEGRATION ---
  // [DB-1] Repository initialized to handle Supabase inserts
  late GameRepository _gameRepo;
  // [DB-2] Holds the UUID for the 'in_progress' match created on game start
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

  String _equation = '';
  String _input = '';
  int _correctAnswer = 0;
  bool _isWrongFlash = false;

  @override
  GameConfig get config => widget.config;

  @override
  bool get isTimerActive => _gameStarted && !_showCountdown;

  @override
  void onTimerUpdate(Duration timeLeft) {
    if (mounted) setState(() {});
  }

  @override
  void onTimeUp() {
    _endGame();
  }

  @override
  void onTimerTick(double dt) {
    // BODMAS is timer-only. No physics to update.
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // [DB-3] AC19: Start match in DB. 
    // We use 'bodmas_burst' as the strict game_id mapping for the Stats View.
    _gameRepo = GameRepository(Supabase.instance.client);
    _gameRepo.startMatch('bodmas_burst').then((id) => _currentMatchId = id);
  }

  void _startCountdown() {
    // AC (General): 3-second countdown before game starts
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _showCountdown = false;
          _gameStarted = true;
          _generateNewEquation();
          timer.cancel();
        }
      });
    });
  }

  void _generateNewEquation() {
    // AC (S-10): Progression logic based on current score.
    // 0-50: Basic Addition/Subtraction
    // 50-150: Multiplication
    // 150-250: BODMAS (a + b * c)
    // 250+: BODMAS (a * b - c ensuring positive)
    
    if (_score < 50) {
      final isAddition = _random.nextBool();
      if (isAddition) {
        final a = _random.nextInt(50) + 1;
        final b = _random.nextInt(50) + 1;
        _correctAnswer = a + b;
        _equation = '$a + $b';
      } else {
        final a = _random.nextInt(50) + 20;
        final b = _random.nextInt(20) + 1;
        _correctAnswer = a - b;
        _equation = '$a - $b';
      }
    } else if (_score < 150) {
      final a = _random.nextInt(12) + 2;
      final b = _random.nextInt(9) + 2;
      _correctAnswer = a * b;
      _equation = '$a × $b';
    } else if (_score < 250) {
      final a = _random.nextInt(20) + 1;
      final b = _random.nextInt(9) + 2;
      final c = _random.nextInt(9) + 2;
      _correctAnswer = a + (b * c);
      _equation = '$a + $b × $c';
    } else {
      final a = _random.nextInt(9) + 2;
      final b = _random.nextInt(9) + 2;
      final maxC = (a * b) - 1;
      final c = _random.nextInt(maxC) + 1;
      _correctAnswer = (a * b) - c;
      _equation = '$a × $b - $c';
    }
    
    _input = '';
    _isWrongFlash = false;
  }

  void _handleDigitTap(int digit) {
    // AC (S-10): Native keyboard is blocked; max 3 digits allowed
    if (!_gameStarted || _showCountdown || _isWrongFlash) return;
    if (_input.length >= 3) return; 
    
    setState(() {
      _input += digit.toString();
    });

    // AC (S-10): Auto-validation when input length matches answer length
    if (_input.length == _correctAnswer.toString().length) {
      _validateAnswer();
    }
  }

  void _validateAnswer() {
    final isCorrect = int.tryParse(_input) == _correctAnswer;
    
    if (isCorrect) {
      _hits++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;
      
      final points = 10 + ((_combo - 1) * 2).clamp(0, 20);
      _score += points;
      
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
      
      setState(() {
        _generateNewEquation();
      });
    } else {
      _misses++;
      _combo = 0;
      _score -= 5; // AC: Wrong answers deduct points
      
      Vibration.vibrate(duration: 100, amplitude: 255);
      HapticFeedback.heavyImpact();
      
      setState(() {
        _isWrongFlash = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isWrongFlash = false;
            _input = ''; // Clear input after wrong flash
          });
        }
      });
    }
  }

  void _handleBackspace() {
    if (_input.isNotEmpty && !_isWrongFlash) {
      setState(() {
        _input = _input.substring(0, _input.length - 1);
      });
    }
  }

  void _handleClear() {
    if (!_isWrongFlash) {
      setState(() {
        _input = '';
      });
    }
  }

  
  void _endGame() async {
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0.0 : ((_hits / totalTaps) * 100.0);

    // [DB-4] AC20: Save to DB. We fire-and-forget so the user instantly goes to Result Screen.
    MatchResult? matchResult;
    if (_currentMatchId != null) {
      matchResult = await _gameRepo.endMatch(
        matchId: _currentMatchId!,
        gameId: 'bodmas_burst', // Placeholder to be replaced
        score: _score,
        accuracy: (totalTaps == 0 ? 0.0 : (_hits / totalTaps) * 100.0),
        durationSeconds: widget.config.duration.inSeconds,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          score: _score,
          isNewPB: matchResult?.isNewPB ?? false,
          previousPBBrokenAfter: matchResult?.previousPBBrokenAfter,
          accuracy: accuracy.round(),
          bestCombo: _bestCombo,
          gameBuilder: () => BodmasBurstScreen(accentColor: widget.accentColor, config: widget.config),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // [UI-1] GameHud with showTarget: false (BODMAS doesn't use target pill)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: GameHud(
                    timeLeft: timeLeft.inMilliseconds / 1000.0,
                    maxTime: widget.config.duration.inSeconds,
                    target: 0, 
                    score: _score,
                    showTarget: false, 
                  ),
                ),
                // [UI-2] Equation Area
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_equation =',
                          style: AppTextStyles.display.copyWith(
                            fontSize: 48,
                            color: _isWrongFlash ? AppColors.vibrantRed : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _input.isEmpty ? '_' : _input,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 64,
                            color: _isWrongFlash ? AppColors.vibrantRed : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // [UI-3] Custom Numpad (No native keyboard)
                CustomNumpad(
                  onDigitTap: _handleDigitTap,
                  onBackspace: _handleBackspace,
                  onClear: _handleClear,
                ),
              ],
            ),
            // [UI-4] 3-Second Countdown Overlay
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
                        Text(widget.config.title, style: AppTextStyles.hud.copyWith(color: widget.accentColor)),
                        SizedBox(height: AppSpacing.md),
                        Text(widget.config.instructions, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}