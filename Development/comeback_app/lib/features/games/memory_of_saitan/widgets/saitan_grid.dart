import 'dart:math' as math; // 👈 ADDED HERE
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SaitanGrid extends StatelessWidget {
  final List<int> gridValues;
  final List<bool> cleared;
  final int gridSize;
  final int? firstSelectionIndex;
  final List<int> correctIndices;
  final List<int> wrongIndices;
  final Function(int) onTileTap;

  const SaitanGrid({
    super.key,
    required this.gridValues,
    required this.cleared,
    required this.gridSize,
    required this.firstSelectionIndex,
    required this.correctIndices,
    required this.wrongIndices,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = AppSpacing.xl;
        final totalSpacing = AppSpacing.sm * (gridSize - 1);
        
        final availableWidth = constraints.maxWidth - (padding * 2) - totalSpacing;
        final availableHeight = constraints.maxHeight - (padding * 2) - totalSpacing;
        
        // Use min to ensure tiles are perfectly square
        final tileSize = math.min(availableWidth / gridSize, availableHeight / gridSize);
        
        final gridWidth = (tileSize * gridSize) + totalSpacing;
        final gridHeight = (tileSize * gridSize) + totalSpacing;
        
        final offsetX = (constraints.maxWidth - gridWidth) / 2;
        final offsetY = (constraints.maxHeight - gridHeight) / 2;

        return Stack(
          children: [
            ...List.generate(gridValues.length, (index) {
              // DO NOT render if cleared or empty (-1)
              if (cleared[index] || gridValues[index] == -1) {
                return const SizedBox.shrink();
              }
              
              final col = index % gridSize;
              final row = index ~/ gridSize;
              
              final isSelected = firstSelectionIndex == index;
              final isCorrect = correctIndices.contains(index);
              final isWrong = wrongIndices.contains(index);

              return Positioned(
                left: offsetX + (col * (tileSize + AppSpacing.sm)),
                top: offsetY + (row * (tileSize + AppSpacing.sm)),
                width: tileSize,
                height: tileSize,
                child: GestureDetector(
                  onTap: () => onTileTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      // Color logic: Green if correct, Red if wrong, Primary if selected, else Surface
                      color: isCorrect 
                          ? AppColors.vibrantGreen 
                          : (isWrong 
                              ? AppColors.vibrantRed 
                              : (isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface)),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: isCorrect 
                            ? AppColors.vibrantGreen 
                            : (isWrong 
                                ? AppColors.vibrantRed 
                                : (isSelected ? AppColors.primary : AppColors.border)),
                        width: isSelected || isCorrect || isWrong ? 2 : 1,
                      ),
                      gradient: (isCorrect || isWrong || isSelected) ? null : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.surface, AppColors.background.withValues(alpha: 0.5)],
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12),
                      ] : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      gridValues[index].toString(),
                      style: AppTextStyles.hud.copyWith(
                        color: (isCorrect || isWrong) 
                            ? AppColors.background 
                            : (isSelected ? AppColors.primary : AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}