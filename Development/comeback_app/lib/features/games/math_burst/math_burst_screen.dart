import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/games/widgets/game_hud.dart';
import '../game_result_screen.dart';
import 'widgets/custom_numpad.dart';

class MathBurstScreen extends StatefulWidget {
  final Color accentColor;
  const MathBurstScreen({super.key, required this.accentColor});

  @override
  State<MathBurstScreen> createState() => _MathBurstScreenState();
}

class _MathBurstScreenState extends State<MathBurstScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final Random _random = Random();

  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hits = 0;
  int _misses = 0;
  bool _gameStarted = false;
  double _exactTimeLeft = 60.0;
  
  int _countdown = 3;
  bool _showCountdown = true;
  Timer? _countdownTimer;

  String _equation = '';
  String _input = '';
  int _correctAnswer = 0;
  bool _isWrongFlash = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _startCountdown();
  }

  void _startCountdown() {
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
    });
  }

  void _handleDigitTap(int digit) {
    if (!_gameStarted || _showCountdown || _isWrongFlash) return;
    if (_input.length >= 3) return; 
    
    setState(() {
      _input += digit.toString();
    });

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
      _score -= 5;
      
      Vibration.vibrate(duration: 100, amplitude: 255);
      HapticFeedback.heavyImpact();
      
      setState(() {
        _isWrongFlash = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isWrongFlash = false;
            _input = '';
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

  void _endGame() {
    _ticker.stop();
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0 : ((_hits / totalTaps) * 100).round();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameResultScreen(
          score: _score,
          accuracy: accuracy,
          bestCombo: _bestCombo,
          gameBuilder: () => MathBurstScreen(accentColor: widget.accentColor),
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
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: GameHud(
                    timeLeft: _exactTimeLeft,
                    maxTime: 60,
                    target: 0, 
                    score: _score,
                    showTarget: false, 
                  ),
                ),
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
                CustomNumpad(
                  onDigitTap: _handleDigitTap,
                  onBackspace: _handleBackspace,
                  onClear: _handleClear,
                ),
              ],
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
                        Text('BODMAS Burst', style: AppTextStyles.hud.copyWith(color: widget.accentColor)),
                        SizedBox(height: AppSpacing.md),
                        Text('Solve maximum BODMAS problems', style: AppTextStyles.body),
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