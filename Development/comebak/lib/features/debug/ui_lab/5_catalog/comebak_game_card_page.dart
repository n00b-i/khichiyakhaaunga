import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';
import '../1_foundations/ui_lab_copy.dart';
import '../2_atoms/comebak_add_burst_icon.dart';
import '../2_atoms/comebak_mad_burst_icon.dart';
import '../2_atoms/comebak_bodmas_burst_icon.dart';
import '../2_atoms/comebak_small_burst_icon.dart';
import '../2_atoms/comebak_saitan_icon.dart';
import '../3_molecules/comebak_game_card.dart';

class ComebakGameCardPage extends StatelessWidget {
  const ComebakGameCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ComebakColors.canvas,
      appBar: AppBar(
        backgroundColor: ComebakColors.surface,
        title: Text(ComebakCopy.catalogGameCardPage, style: ComebakTypography.titleLarge),
        iconTheme: const IconThemeData(color: ComebakColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ComebakLayout.spaceXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('2-COLUMN GRID LAYOUT'),
            const SizedBox(height: ComebakLayout.spaceLg),

            // ROW 1
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ComebakGameCard(
                    title: ComebakCopy.gameAddTitle,
                    subtitle: ComebakCopy.gameAddDesc,
                    accentColor: ComebakColors.neonOrange,
                    onTap: () {},
                    iconWidget: ComebakAddBurstIcon(size: ComebakLayout.gameIconSize),
                  ),
                ),
                const SizedBox(width: ComebakLayout.spaceLg),
                Expanded(
                  child: ComebakGameCard(
                    title: ComebakCopy.gameMadTitle,
                    subtitle: ComebakCopy.gameMadDesc,
                    accentColor: ComebakColors.neonGreen,
                    onTap: () {},
                    iconWidget: ComebakMadBurstIcon(size: ComebakLayout.gameIconSize),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ComebakLayout.spaceLg),

            // ROW 2
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ComebakGameCard(
                    title: ComebakCopy.gameBodmasTitle,
                    subtitle: ComebakCopy.gameBodmasDesc,
                    accentColor: ComebakColors.neonPurple,
                    onTap: () {},
                    iconWidget: ComebakBodmasBurstIcon(size: ComebakLayout.gameIconSize),
                  ),
                ),
                const SizedBox(width: ComebakLayout.spaceLg),
                Expanded(
                  child: ComebakGameCard(
                    title: ComebakCopy.gameSmallTitle,
                    subtitle: ComebakCopy.gameSmallDesc,
                    accentColor: ComebakColors.neonBlue,
                    onTap: () {},
                    iconWidget: ComebakSmallBurstIcon(size: ComebakLayout.gameIconSize),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ComebakLayout.spaceLg),

            // ROW 3
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ComebakGameCard(
                    title: ComebakCopy.gameSaitanTitle,
                    subtitle: ComebakCopy.gameSaitanDesc,
                    accentColor: ComebakColors.vibrantPink,
                    onTap: () {},
                    iconWidget: ComebakSaitanIcon(size: ComebakLayout.gameIconSize),
                  ),
                ),
                const SizedBox(width: ComebakLayout.spaceLg),
                // LOCKED GAME FILLER
                Expanded(
                  child: ComebakGameCard(
                    title: 'Locked Game',
                    subtitle: 'Coming soon to Comebak.',
                    accentColor: ComebakColors.textSecondary,
                    isLocked: true,
                    onTap: () {},
                    iconWidget: const SizedBox(), // Icon is replaced by lock internally
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ComebakTypography.sectionTitle),
        const SizedBox(height: ComebakLayout.spaceXs),
        Container(height: ComebakLayout.borderThin, width: ComebakLayout.spaceXxl, color: ComebakColors.neonGreen),
      ],
    );
  }
}