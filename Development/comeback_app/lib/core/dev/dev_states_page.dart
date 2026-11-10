import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../ui/components/comebak_card.dart';
import '../ui/components/comebak_button.dart';
import 'dev_screen_registry.dart';

// Dev-only page listing every registered screen state as tappable buttons.
// Reached via app.dart home: override while reviewing states.
class DevStatesPage extends StatelessWidget {
  const DevStatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = DevScreenRegistry.screens;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: const Text('Dev States', style: AppTextStyles.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.space16),
        children: [
          for (final group in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.space16, bottom: AppSpacing.space8),
              child: Text(group.key, style: AppTextStyles.titleMedium),
            ),
            ComebakCard(
              padding: const EdgeInsets.all(AppSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final state in group.value.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.space8),
                      child: ComebakButton(
                        text: state.key,
                        variant: ComebakButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: state.value),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
