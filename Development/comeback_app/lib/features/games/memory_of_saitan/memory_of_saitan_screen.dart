import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // [1] Supabase import
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/games/widgets/game_hud.dart';
import '../../../core/games/utils/game_diagnostics.dart';
import '../game_result_screen.dart';
import '../../../core/games/repository/game_repository.dart'; // [2] Repository import

class MemoryOfSaitanScreen extends StatefulWidget {
  final bool isMultiplication;
  final Color accentColor;

  const MemoryOfSaitanScreen({
    super.key, 
    this.isMultiplication = false,
    required this.accentColor,
  });

  @override
  State<MemoryOfSaitanScreen> createState() => _MemoryOfSaitanScreenState();
}

class _MemoryOfSaitanScreenState extends State<MemoryOfSaitanScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final Random _random = Random();

  // [3] DB Match Tracking Variables
  late GameRepository _gameRepo;
  String? _currentMatchId;

  int _score = 0; 
  int _combo = 0; 
  int _bestCombo = 0; 
  int _hits = 0; 
  int _misses = 0;
  bool _gameStarted = false; 
  double _timeLeft = 60.0;
  final ValueNotifier<double> _timeNotifier = ValueNotifier(60.0);
  
  int _countdown = 3; 
  bool _showCountdown = true; 
  Timer? _countdownTimer;

  int _level = 0;
  int _gridSize = 2;
  int _emptyCount = 0;
  List<int> _gridValues = [];
  List<bool> _cleared = []; 
  int _target = 0;
  int? _firstSelectionIndex;

  List<int> _correctIndices = [];
  List<int> _wrongIndices = [];
  bool _isLevelClearing = false;
  bool _showLevelUp = false;
  int _nextLevel = 1;

  bool _isMemorizing = false; 
  final ValueNotifier<Offset?> _fingerPos = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick)..start();
    _startCountdown();

    // [4] Initialize DB Match
    _gameRepo = GameRepository(Supabase.instance.client);
    final gameId = widget.isMultiplication ? 'saitan_mul' : 'saitan_add';
    _gameRepo.startMatch(gameId).then((id) => _currentMatchId = id);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ticker.muted = true;
    } else if (state == AppLifecycleState.resumed) {
      _ticker.muted = false;
      _lastElapsed = Duration.zero; 
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _showCountdown = false; 
          _gameStarted = true;
          _buildGrid();
          timer.cancel();
        }
      });
    });
  }

  void _buildGrid() {
    final name = widget.isMultiplication ? 'Saitan X' : 'Saitan +';
    GameDiagnostics.logGameStart(name);
    
    if (_level == 0) { _gridSize = 2; _emptyCount = 0; }
    else if (_level == 1) { _gridSize = 3; _emptyCount = 1; }
    else { _gridSize = 4; _emptyCount = 0; }

    _gridValues = [];
    _cleared = [];
    _firstSelectionIndex = null;
    _correctIndices = [];
    _wrongIndices = [];
    _isMemorizing = true; 
    
    int numCells = _gridSize * _gridSize;
    int numPairs = (numCells - _emptyCount) ~/ 2;
    
    for (int i = 0; i < numPairs; i++) {
      int a = _random.nextInt(8) + 2; 
      int b = _random.nextInt(8) + 2;
      _gridValues.add(a);
      _gridValues.add(b);
    }
    
    for (int i = 0; i < _emptyCount; i++) {
      _gridValues.add(-1);
    }
    
    _gridValues.shuffle();
    for (int i = 0; i < _gridValues.length; i++) {
      _cleared.add(_gridValues[i] == -1);
    }
    
    _pickNewTarget();

    // Dynamic memorize time: Base 500ms + 200ms per level
    final revealDuration = 500 + (_level * 200);
    
    Future.delayed(Duration(milliseconds: revealDuration), () {
      if (mounted) setState(() => _isMemorizing = false);
    });
  }

  void _pickNewTarget() {
    List<int> activeIndices = [];
    for (int i = 0; i < _cleared.length; i++) {
      if (!_cleared[i]) activeIndices.add(i);
    }

    if (activeIndices.length < 2) return; 

    activeIndices.shuffle();
    int a = _gridValues[activeIndices[0]];
    int b = _gridValues[activeIndices[1]];
    _target = widget.isMultiplication ? (a * b) : (a + b);
  }

  void _handleLevelClear() {
    _isLevelClearing = true;
    _nextLevel = _level + 1;
    
    setState(() => _showLevelUp = true);
    Vibration.vibrate(pattern: [0, 100, 50, 100]);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _showLevelUp = false;
        _level++;
        _isLevelClearing = false;
        _buildGrid(); 
      });
    });
  }

  void _onTick(Duration elapsed) {
    if (!mounted || !_gameStarted || _showCountdown || _isLevelClearing) return;
    
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    
    if (dt > 0.1) return; 
    
    _timeLeft -= dt;
    
    if (_timeLeft <= 0) { 
      _timeLeft = 0;
      _timeNotifier.value = 0; 
      _endGame(); 
      return; 
    }
    
    _timeNotifier.value = _timeLeft;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_gameStarted || _showCountdown || _isMemorizing || _isLevelClearing || _correctIndices.isNotEmpty || _wrongIndices.isNotEmpty) return;
    _fingerPos.value = event.localPosition;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_gameStarted || _showCountdown || _isMemorizing || _isLevelClearing || _correctIndices.isNotEmpty || _wrongIndices.isNotEmpty) return;
    _fingerPos.value = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    _fingerPos.value = null;
  }

  void _handleTileTap(int index) {
    if (!_gameStarted || _showCountdown || _isMemorizing || _isLevelClearing || _correctIndices.isNotEmpty || _wrongIndices.isNotEmpty) return;
    if (_cleared[index]) return;

    setState(() {
      if (_firstSelectionIndex == null) {
        _firstSelectionIndex = index;
        HapticFeedback.selectionClick();
      } else if (_firstSelectionIndex == index) {
        _firstSelectionIndex = null; 
        HapticFeedback.selectionClick();
      } else {
        int firstVal = _gridValues[_firstSelectionIndex!];
        int secondVal = _gridValues[index];
        
        int result = widget.isMultiplication ? (firstVal * secondVal) : (firstVal + secondVal);
        
        if (result == _target) {
          _hits++; _combo++;
          if (_combo > _bestCombo) _bestCombo = _combo;
          _score += 10;
          SystemSound.play(SystemSoundType.click);
          Vibration.vibrate(duration: 50, amplitude: 150);
          
          final firstIndex = _firstSelectionIndex!;
          final secondIndex = index;
          
          _correctIndices = [firstIndex, secondIndex];
          _firstSelectionIndex = null;
          _fingerPos.value = null; 
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              _cleared[firstIndex] = true; 
              _cleared[secondIndex] = true; 
              _correctIndices = []; 
              
              if (_cleared.every((c) => c)) {
                _handleLevelClear();
              } else {
                _pickNewTarget();
              }
            });
          });
        } else {
          _misses++; _combo = 0; _score -= 5;
          Vibration.vibrate(duration: 100, amplitude: 255);
          
          final firstIndex = _firstSelectionIndex!;
          final secondIndex = index;
          
          _wrongIndices = [firstIndex, secondIndex];
          _firstSelectionIndex = null;
          _fingerPos.value = null;
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              _wrongIndices = [];
            });
          });
        }
      }
    });
  }

  void _endGame() async {
    _ticker.stop();
    final totalTaps = _hits + _misses;
    final accuracy = totalTaps == 0 ? 0.0 : ((_hits / totalTaps) * 100.0);

    bool isNewPB = false;
    // [5] Save Match to DB
    if (_currentMatchId != null) {
      final gameId = widget.isMultiplication ? 'saitan_mul' : 'saitan_add';
      isNewPB = await _gameRepo.endMatch(
        matchId: _currentMatchId!,
        gameId: gameId,
        score: _score,
        accuracy: accuracy,
        durationSeconds: 60,
      );
    }
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => GameResultScreen(
      score: _score, 
      accuracy: accuracy.round(), 
      bestCombo: _bestCombo, 
      isNewPB: isNewPB,
      gameBuilder: () => MemoryOfSaitanScreen(
        isMultiplication: widget.isMultiplication,
        accentColor: widget.accentColor,
      )
    )));
  }

  @override
  void dispose() { 
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose(); 
    _countdownTimer?.cancel(); 
    _timeNotifier.dispose();
    _fingerPos.dispose();
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
                ValueListenableBuilder<double>(
                  valueListenable: _timeNotifier,
                  builder: (context, timeLeft, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: GameHud(
                        timeLeft: timeLeft, maxTime: 60, target: _target, score: _score,
                        operationPrefix: widget.isMultiplication ? 'x' : '+',
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    child: Stack(
                      children: [
                        // LAYER 1: The Actual Grid
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _gridSize,
                              crossAxisSpacing: AppSpacing.sm,
                              mainAxisSpacing: AppSpacing.sm,
                            ),
                            itemCount: _gridValues.length,
                            itemBuilder: (context, index) {
                              if (_cleared[index] || _gridValues[index] == -1) {
                                return const SizedBox.shrink();
                              }

                              return GestureDetector(
                                onTap: () => _handleTileTap(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [AppColors.surface, AppColors.background.withValues(alpha: 0.6)],
                                    ),
                                    borderRadius: BorderRadius.circular(AppRadius.card),
                                    border: Border.all(color: AppColors.border, width: 1),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _gridValues[index].toString(),
                                    style: AppTextStyles.hud,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // LAYER 2: The Pitch Black Mask (Flashlight)
                        if (!_isMemorizing && !_isLevelClearing)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ValueListenableBuilder<Offset?>(
                                valueListenable: _fingerPos,
                                builder: (context, pos, child) {
                                  if (pos == null) return Container(color: AppColors.saitanGrid);
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment(
                                          (pos.dx / MediaQuery.sizeOf(context).width) * 2 - 1,
                                          (pos.dy / (MediaQuery.sizeOf(context).height - 165)) * 2 - 1,
                                        ),
                                        radius: 0.4,
                                        colors: [
                                          Colors.transparent,
                                          AppColors.saitanGrid.withValues(alpha: 0.95),
                                          AppColors.saitanGrid,
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        // LAYER 3: The Overlays (Selected, Correct, Wrong)
                        IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _gridSize,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisSpacing: AppSpacing.sm,
                              ),
                              itemCount: _gridValues.length,
                              itemBuilder: (context, index) {
                                if (_cleared[index] || _gridValues[index] == -1) {
                                  return const SizedBox.shrink();
                                }
                                
                                final isSelected = _firstSelectionIndex == index;
                                final isCorrect = _correctIndices.contains(index);
                                final isWrong = _wrongIndices.contains(index);

                                if (!isSelected && !isCorrect && !isWrong) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: isSelected 
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [AppColors.surface, AppColors.primary.withValues(alpha: 0.3)],
                                          )
                                        : null,
                                    color: isCorrect 
                                        ? AppColors.vibrantGreen 
                                        : (isWrong 
                                            ? AppColors.vibrantRed 
                                            : null),
                                    borderRadius: BorderRadius.circular(AppRadius.card),
                                    border: Border.all(
                                      color: isCorrect 
                                          ? AppColors.vibrantGreen 
                                          : (isWrong 
                                              ? AppColors.vibrantRed 
                                              : AppColors.primary),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isCorrect 
                                            ? AppColors.vibrantGreen.withValues(alpha: 0.5)
                                            : (isWrong 
                                                ? AppColors.vibrantRed.withValues(alpha: 0.5)
                                                : AppColors.primary.withValues(alpha: 0.4)),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _gridValues[index].toString(),
                                    style: AppTextStyles.hud.copyWith(
                                      color: (isCorrect || isWrong) 
                                          ? AppColors.background 
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.lg,
              child: Text(
                'Slide to reveal. Tap 2 tiles to match target.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),

            if (_showLevelUp)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showLevelUp ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        'LEVEL $_nextLevel',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 72,
                          color: widget.accentColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (_showCountdown)
              Positioned.fill(child: Container(color: AppColors.background, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$_countdown', style: AppTextStyles.display.copyWith(fontSize: 100)),
                SizedBox(height: AppSpacing.lg),
                Text(
                  widget.isMultiplication ? 'Saitan X' : 'Saitan +', 
                  style: AppTextStyles.hud.copyWith(color: widget.accentColor),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  widget.isMultiplication ? 'Memorize the grid. Multiply to target.' : 'Memorize the grid. Add to target.', 
                  style: AppTextStyles.body,
                ),
              ])))),
          ],
        ),
      ),
    );
  }
}