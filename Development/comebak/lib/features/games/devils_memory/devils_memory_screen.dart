import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/games/widgets/game_chrome.dart';
import '../../../core/games/utils/game_diagnostics.dart';
import '../../../core/games/repository/game_repository.dart';
import '../../../core/games/models/game_config.dart';
import '../../../core/games/configs/game_configs.dart';
import '../../../core/games/mixins/game_timer_mixin.dart';
// UI LAB IMPORTS: The new SSOT for HUD and Results
import '../../debug/ui_lab/5_catalog/game_flow/widgets/comebak_game_hud_widget.dart';
import '../../debug/ui_lab/5_catalog/game_flow/comebak_game_over_page.dart';

// ==============================================================================
// [SCREEN] DevilsMemoryScreen
// ------------------------------------------------------------------------------
// ARCHITECTURE:
// Devils Memory is a grid-based card matching game, not a physics simulation.
// The core loop is:
// 1. Generate a grid of number pairs.
// 2. Show all numbers for a brief 'memorize' window (500ms + level * 200ms).
// 3. Hide numbers behind a 'flashlight' mask that follows the user's finger.
// 4. User taps two tiles. If their sum/product matches the target, they clear.
// 5. Clear the entire board to level up.
//
// PERFORMANCE:
// The timer is isolated via ValueNotifier<double> (_timeNotifier) so the
// grid doesn't rebuild every tick. The flashlight mask uses a separate
// ValueNotifier<Offset?> (_fingerPos) to avoid rebuilding the grid on pan.
// ==============================================================================
class DevilsMemoryScreen extends StatefulWidget {
  final GameConfig config;
  final bool isMultiplication;
  final Color accentColor;

  const DevilsMemoryScreen({
    super.key,
    this.config = DevilsMemoryConfig.addition,
    this.isMultiplication = false,
    required this.accentColor,
  });

  @override
  State<DevilsMemoryScreen> createState() => _DevilsMemoryScreenState();
}

class _DevilsMemoryScreenState extends State<DevilsMemoryScreen>
    with SingleTickerProviderStateMixin, GameTimerMixin {
  final Random _random = Random();
  late GameRepository _gameRepo;
  String? _currentMatchId;

  // ============================================================================
  // [STATE] Core Game Logic
  // ============================================================================
  int _score = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int _hits = 0;
  int _misses = 0;
  bool _gameStarted = false;

  // [ISSUE-1] ValueNotifier for HUD to avoid full screen rebuilds.
  final ValueNotifier<double> _timeNotifier = ValueNotifier(60.0);

  int _countdown = 3;
  bool _showCountdown = true;
  Timer? _countdownTimer;

  // ============================================================================
  // [STATE] Grid & Level Progression
  // ============================================================================
  int _level = 0;
  int _gridSize = 2; // 2x2, 3x3, 4x4
  int _emptyCount = 0; // Blind slots in the grid
  List<int> _gridValues = []; // -1 = empty slot
  List<bool> _cleared = [];
  int _target = 0;
  int? _firstSelectionIndex;

  List<int> _correctIndices = []; // Indices flashing green
  List<int> _wrongIndices = []; // Indices flashing red
  bool _isLevelClearing = false;
  bool _showLevelUp = false;
  int _nextLevel = 1;

  // ============================================================================
  // [STATE] Flashlight Mask
  // ----------------------------------------------------------------------------
  // _isMemorizing: When true, the flashlight mask is disabled and all tiles
  // are visible. When false, the mask covers everything except the finger.
  // ============================================================================
  bool _isMemorizing = false;
  final ValueNotifier<Offset?> _fingerPos = ValueNotifier(null);

  // ============================================================================
  // [TIMER MIXIN OVERRIDES]
  // ============================================================================
  @override
  GameConfig get config => widget.config;

  // [ISSUE-15] Pause timer during countdown and level transitions.
  @override
  bool get isTimerActive =>
      _gameStarted && !_showCountdown && !_isLevelClearing;

  @override
  void onTimerUpdate(Duration timeLeft) {
    // Isolated HUD update.
    _timeNotifier.value = timeLeft.inMilliseconds / 1000.0;
  }

  @override
  void onTimeUp() {
    _endGame();
  }

  @override
  void onTimerTick(double dt) {
    // DevilsMemory is driven by taps, not per-frame physics.
  }

  // ============================================================================
  // [LIFECYCLE]
  // ============================================================================
  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Initialize Supabase match to track stats.
    _gameRepo = GameRepository(Supabase.instance.client);
    _gameRepo
        .startMatch(widget.config.gameId)
        .then((id) => _currentMatchId = id);
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        return;
      }
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

  // ============================================================================
  // [GRID GENERATION]
  // ----------------------------------------------------------------------------
  // Level 0: 2x2 grid, 0 empty slots.
  // Level 1: 3x3 grid, 1 empty slot.
  // Level 2+: 4x4 grid, 0 empty slots.
  //
  // The values are 2-9. The target is the SUM (or PRODUCT) of the first
  // two non-cleared tiles. This forces the user to hunt for pairs.
  // ============================================================================
  void _buildGrid() {
    GameDiagnostics.logGameStart(widget.config.title);

    if (_level == 0) {
      _gridSize = 2;
      _emptyCount = 0;
    } else if (_level == 1) {
      _gridSize = 3;
      _emptyCount = 1;
    } else {
      _gridSize = 4;
      _emptyCount = 0;
    }

    _gridValues = [];
    _cleared = [];
    _firstSelectionIndex = null;
    _correctIndices = [];
    _wrongIndices = [];
    _isMemorizing = true; // Show all numbers for the memorize window.

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

    // Memorize window scales with level.
    final revealDuration = 500 + (_level * 200);
    Future.delayed(Duration(milliseconds: revealDuration), () {
      if (mounted) {
        setState(() => _isMemorizing = false);
      }
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

  // ============================================================================
  // [LEVEL PROGRESSION]
  // ============================================================================
  void _handleLevelClear() {
    _isLevelClearing = true;
    _nextLevel = _level + 1;

    setState(() => _showLevelUp = true);
    Vibration.vibrate(pattern: [0, 100, 50, 100]);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showLevelUp = false;
        _level++;
        _isLevelClearing = false;
        _buildGrid();
      });
    });
  }

  // ============================================================================
  // [FLASHLIGHT INPUT]
  // ============================================================================
  void _onPointerDown(PointerDownEvent event) {
    if (!_gameStarted ||
        _showCountdown ||
        _isMemorizing ||
        _isLevelClearing ||
        _correctIndices.isNotEmpty ||
        _wrongIndices.isNotEmpty) {
      return;
    }
    _fingerPos.value = event.localPosition;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_gameStarted ||
        _showCountdown ||
        _isMemorizing ||
        _isLevelClearing ||
        _correctIndices.isNotEmpty ||
        _wrongIndices.isNotEmpty) {
      return;
    }
    _fingerPos.value = event.localPosition;
  }

  void _onPointerUp(PointerUpEvent event) {
    _fingerPos.value = null;
  }

  // ============================================================================
  // [TILE TAP HANDLING]
  // ============================================================================
  void _handleTileTap(int index) {
    if (!_gameStarted ||
        _showCountdown ||
        _isMemorizing ||
        _isLevelClearing ||
        _correctIndices.isNotEmpty ||
        _wrongIndices.isNotEmpty) {
      return;
    }
    if (_cleared[index]) return;

    setState(() {
      if (_firstSelectionIndex == null) {
        // First tile selected.
        _firstSelectionIndex = index;
        HapticFeedback.selectionClick();
      } else if (_firstSelectionIndex == index) {
        // Deselect.
        _firstSelectionIndex = null;
        HapticFeedback.selectionClick();
      } else {
        // Second tile selected. Check match.
        int firstVal = _gridValues[_firstSelectionIndex!];
        int secondVal = _gridValues[index];

        int result = widget.isMultiplication
            ? (firstVal * secondVal)
            : (firstVal + secondVal);

        if (result == _target) {
          // --- MATCH ---
          _hits++;
          _combo++;
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
            if (!mounted) {
              return;
            }
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
          // --- MISS ---
          _misses++;
          _combo = 0;
          _score -= 5;
          Vibration.vibrate(duration: 100, amplitude: 255);

          final firstIndex = _firstSelectionIndex!;
          final secondIndex = index;

          _wrongIndices = [firstIndex, secondIndex];
          _firstSelectionIndex = null;
          _fingerPos.value = null;

          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) {
              return;
            }
            setState(() {
              _wrongIndices = [];
            });
          });
        }
      }
    });
  }

  // ============================================================================
  // [END GAME] Routing to UI Lab Results
  // ============================================================================
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

    if (!mounted) {
      return;
    }

    // Calculate XP change (mock logic, can be moved to repository later).
    final xpChange = _score > 0 ? (_score / 10).round() : 0;
    final brokenAfterString = _formatDuration(
      matchResult?.previousPBBrokenAfter,
    );

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
          gameBuilder: () => DevilsMemoryScreen(
            config: widget.config,
            isMultiplication: widget.isMultiplication,
            accentColor: widget.accentColor,
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
    _timeNotifier.dispose();
    _fingerPos.dispose();
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
        child: Stack(
          children: [
            Column(
              children: [
                // 1. HUD (isolated via ValueListenableBuilder)
                ValueListenableBuilder<double>(
                  valueListenable: _timeNotifier,
                  builder: (context, timeLeft, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: ComebakGameHudWidget(
                        timeLeft: timeLeft,
                        maxTime: widget.config.duration.inSeconds,
                        target: _target,
                        score: _score,
                        targetLabel: widget.config.hudTargetLabel,
                      ),
                    );
                  },
                ),

                // 2. The Grid + Flashlight
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                      colors: [
                                        AppColors.surface,
                                        AppColors.background.withValues(
                                          alpha: 0.6,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.card,
                                    ),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
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
                                  if (pos == null) {
                                    return Container(
                                      color: AppColors.devilsMemoryGrid,
                                    );
                                  }
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment(
                                          (pos.dx /
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).width) *
                                                  2 -
                                              1,
                                          (pos.dy /
                                                      (MediaQuery.sizeOf(
                                                            context,
                                                          ).height -
                                                          165)) *
                                                  2 -
                                              1,
                                        ),
                                        radius: 0.4,
                                        colors: [
                                          Colors.transparent,
                                          AppColors.devilsMemoryGrid.withValues(
                                            alpha: 0.95,
                                          ),
                                          AppColors.devilsMemoryGrid,
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridSize,
                                    crossAxisSpacing: AppSpacing.sm,
                                    mainAxisSpacing: AppSpacing.sm,
                                  ),
                              itemCount: _gridValues.length,
                              itemBuilder: (context, index) {
                                if (_cleared[index] ||
                                    _gridValues[index] == -1) {
                                  return const SizedBox.shrink();
                                }

                                final isSelected =
                                    _firstSelectionIndex == index;
                                final isCorrect = _correctIndices.contains(
                                  index,
                                );
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
                                            colors: [
                                              AppColors.surface,
                                              AppColors.primary.withValues(
                                                alpha: 0.3,
                                              ),
                                            ],
                                          )
                                        : null,
                                    color: isCorrect
                                        ? AppColors.vibrantGreen
                                        : (isWrong
                                              ? AppColors.vibrantRed
                                              : null),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.card,
                                    ),
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
                                            ? AppColors.vibrantGreen.withValues(
                                                alpha: 0.5,
                                              )
                                            : (isWrong
                                                  ? AppColors.vibrantRed
                                                        .withValues(alpha: 0.5)
                                                  : AppColors.primary
                                                        .withValues(
                                                          alpha: 0.4,
                                                        )),
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

            // 3. Instruction Bar
            GameInstructionBar(text: widget.config.instructions),

            // 4. Level Up Overlay
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

            // 5. Countdown Overlay
            if (_showCountdown)
              GameCountdownOverlay(
                count: _countdown,
                title: widget.config.title,
                instructions: widget.config.instructions,
                accentColor: widget.accentColor,
              ),
          ],
        ),
      ),
    );
  }
}
