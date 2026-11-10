import 'package:flutter/material.dart';
import 'package:fossui/fossui.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/lab_titles.dart';

// [COMPONENT] Layout: Card, ListTile, Separator, Avatar, Text.
class LayoutSection extends StatelessWidget {
  const LayoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [COMPONENT] FossCard — replaces Stats _StatTile.
        // [TOKEN MAPPING] surface -> colors.card; border -> colors.border; radius -> radii.md.
        const LabSubTitle('FossCard'),
        FossCard(
          title: const Text('Total Games'),
          description: const Text('Across all sessions.'),
          content: const FossText(
            '128',
            size: FossTextSize.xl2,
            weight: FossTextWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const FossCard(
          content: FossText(
            'Content-only card. Full inset on all sides.',
            size: FossTextSize.sm,
          ),
        ),

        // [COMPONENT] FossListTile + FossSeparator — replaces Stats _PbRow.
        const LabSubTitle('FossListTile + FossSeparator'),
        const FossCard(
          content: Column(
            children: [
              FossListTile(
                title: Text('Add Burst'),
                subtitle: Text('Personal best'),
                trailing: FossText(
                  '400',
                  size: FossTextSize.lg,
                  weight: FossTextWeight.bold,
                ),
                variant: FossListTileVariant.plain,
              ),
              FossSeparator(),
              FossListTile(
                title: Text('BODMAS Burst'),
                subtitle: Text('Personal best'),
                trailing: FossText(
                  '310',
                  size: FossTextSize.lg,
                  weight: FossTextWeight.bold,
                ),
                variant: FossListTileVariant.plain,
              ),
              FossSeparator(),
              FossListTile(
                title: Text('Saitan X'),
                subtitle: Text('Personal best'),
                trailing: FossText(
                  '—',
                  size: FossTextSize.lg,
                  weight: FossTextWeight.bold,
                  color: FossTextColor.mutedForeground,
                ),
                variant: FossListTileVariant.plain,
              ),
            ],
          ),
        ),

        // [COMPONENT] FossAvatar — profile image with initial fallback.
        const LabSubTitle('FossAvatar'),
        const Row(
          children: [
            FossAvatar(fallback: Text('D'), size: FossAvatarSize.xs),
            SizedBox(width: AppSpacing.sm),
            FossAvatar(fallback: Text('D'), size: FossAvatarSize.md),
            SizedBox(width: AppSpacing.sm),
            FossAvatar(fallback: Text('D'), size: FossAvatarSize.xl2),
          ],
        ),

        // [COMPONENT] FossText — six type steps.
        const LabSubTitle('FossText'),
        const FossText(
          'Display — xl2 / bold',
          size: FossTextSize.xl2,
          weight: FossTextWeight.bold,
        ),
        const FossText(
          'Heading — xl / semibold',
          size: FossTextSize.xl,
          weight: FossTextWeight.semibold,
        ),
        const FossText('Body — base / regular', size: FossTextSize.base),
        const FossText(
          'Caption — xs / muted',
          size: FossTextSize.xs,
          color: FossTextColor.mutedForeground,
        ),
      ],
    );
  }
}