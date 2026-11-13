import 'dart:convert';
import 'package:flutter/material.dart';
import '../../1_foundations/tokens/ui_lab_tokens.dart';
import 'streak_debug_payload.dart';

// ==============================================================================
// [DEBUG UI] StreakDebugPanel
// ------------------------------------------------------------------------------
// PURPOSE: Allows QA to inject arbitrary data into the Home Streak Card via
// an interactive form, preset dropdowns, and raw JSON.
// ==============================================================================
Future<StreakDebugPayload?> showStreakDebugPanel(
  BuildContext context,
  StreakDebugPayload? currentPayload,
) {
  return showModalBottomSheet<StreakDebugPayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _StreakDebugPanel(initialPayload: currentPayload),
  );
}

class _StreakDebugPanel extends StatefulWidget {
  final StreakDebugPayload? initialPayload;
  const _StreakDebugPanel({this.initialPayload});

  @override
  State<_StreakDebugPanel> createState() => _StreakDebugPanelState();
}

class _StreakDebugPanelState extends State<_StreakDebugPanel> {
  // Form Controllers
  late final TextEditingController _gamesCtrl;
  late final TextEditingController _xpCtrl;
  late final TextEditingController _streakCtrl;
  late final TextEditingController _deltaTodayCtrl;
  late final TextEditingController _deltaYestCtrl;
  late final TextEditingController _lastPlayedCtrl;
  late final TextEditingController _debugNowCtrl;
  late final TextEditingController _jsonCtrl;

  String? _errorMessage;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    final p = widget.initialPayload;

    _gamesCtrl = TextEditingController(text: (p?.totalGames ?? 5).toString());
    _xpCtrl = TextEditingController(text: (p?.totalXp ?? 1250).toString());
    _streakCtrl = TextEditingController(text: (p?.streak ?? 3).toString());
    _deltaTodayCtrl = TextEditingController(
      text: (p?.deltaXpToday ?? 0).toString(),
    );
    _deltaYestCtrl = TextEditingController(
      text: (p?.deltaXpYesterday ?? 30).toString(),
    );
    _lastPlayedCtrl = TextEditingController(
      text: p?.lastPlayedAt ?? '2026-11-12T12:00:00Z',
    );
    _debugNowCtrl = TextEditingController(
      text: p?.debugNow ?? '2026-11-13T10:00:00',
    );
    _jsonCtrl = TextEditingController();

    _updateJsonFromFields();

    // Listen to field changes to auto-update JSON
    for (final ctrl in [
      _gamesCtrl,
      _xpCtrl,
      _streakCtrl,
      _deltaTodayCtrl,
      _deltaYestCtrl,
      _lastPlayedCtrl,
      _debugNowCtrl,
    ]) {
      ctrl.addListener(_updateJsonFromFields);
    }
  }

  @override
  void dispose() {
    _gamesCtrl.dispose();
    _xpCtrl.dispose();
    _streakCtrl.dispose();
    _deltaTodayCtrl.dispose();
    _deltaYestCtrl.dispose();
    _lastPlayedCtrl.dispose();
    _debugNowCtrl.dispose();
    _jsonCtrl.dispose();
    super.dispose();
  }

  void _updateJsonFromFields() {
    try {
      final payload = StreakDebugPayload(
        totalGames: int.tryParse(_gamesCtrl.text) ?? 0,
        totalXp: int.tryParse(_xpCtrl.text) ?? 0,
        streak: int.tryParse(_streakCtrl.text) ?? 0,
        deltaXpToday: int.tryParse(_deltaTodayCtrl.text) ?? 0,
        deltaXpYesterday: int.tryParse(_deltaYestCtrl.text) ?? 0,
        lastPlayedAt: _lastPlayedCtrl.text.isEmpty
            ? null
            : _lastPlayedCtrl.text,
        debugNow: _debugNowCtrl.text.isEmpty ? null : _debugNowCtrl.text,
      );
      _jsonCtrl.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(payload.toJson());
      setState(() => _errorMessage = null);
    } catch (e) {
      // Ignore intermediate invalid states while typing
    }
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      switch (preset) {
        case 'S1: First Time':
          _gamesCtrl.text = '0';
          _xpCtrl.text = '0';
          _streakCtrl.text = '0';
          _deltaTodayCtrl.text = '0';
          _deltaYestCtrl.text = '0';
          _lastPlayedCtrl.text = '';
          _debugNowCtrl.text = '';
          break;
        case 'S2: Day 1 (Positive)':
          _gamesCtrl.text = '1';
          _xpCtrl.text = '150';
          _streakCtrl.text = '1';
          _deltaTodayCtrl.text = '150';
          _deltaYestCtrl.text = '0';
          _lastPlayedCtrl.text = '2026-11-13T09:00:00Z';
          _debugNowCtrl.text = '2026-11-13T12:00:00';
          break;
        case 'S3: Day 3 Active':
          _gamesCtrl.text = '5';
          _xpCtrl.text = '1250';
          _streakCtrl.text = '3';
          _deltaTodayCtrl.text = '150';
          _deltaYestCtrl.text = '0';
          _lastPlayedCtrl.text = '2026-11-13T09:00:00Z';
          _debugNowCtrl.text = '2026-11-13T12:00:00';
          break;
        case 'S9: At Risk (10 AM)':
          _gamesCtrl.text = '5';
          _xpCtrl.text = '1250';
          _streakCtrl.text = '3';
          _deltaTodayCtrl.text = '0';
          _deltaYestCtrl.text = '30';
          _lastPlayedCtrl.text = '2026-11-12T12:00:00Z';
          _debugNowCtrl.text = '2026-11-13T10:00:00';
          break;
        case 'S10: Critical (8 PM)':
          _gamesCtrl.text = '5';
          _xpCtrl.text = '1250';
          _streakCtrl.text = '3';
          _deltaTodayCtrl.text = '0';
          _deltaYestCtrl.text = '30';
          _lastPlayedCtrl.text = '2026-11-12T12:00:00Z';
          _debugNowCtrl.text = '2026-11-13T20:00:00';
          break;
        case 'S11: Broken':
          _gamesCtrl.text = '8';
          _xpCtrl.text = '1240';
          _streakCtrl.text = '0';
          _deltaTodayCtrl.text = '0';
          _deltaYestCtrl.text = '-10';
          _lastPlayedCtrl.text = '2026-11-11T12:00:00Z';
          _debugNowCtrl.text = '2026-11-13T12:00:00';
          break;
      }
    });
  }

  void _applyPayload() {
    try {
      final decoded = jsonDecode(_jsonCtrl.text) as Map<String, dynamic>;
      final payload = StreakDebugPayload.fromJson(decoded);
      Navigator.pop(context, payload);
    } catch (e) {
      setState(() => _errorMessage = 'Invalid JSON or missing fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: ComebakLayout.spaceXl,
        right: ComebakLayout.spaceXl,
        top: ComebakLayout.spaceXl,
        bottom: bottomInset + ComebakLayout.spaceXl,
      ),
      decoration: const BoxDecoration(
        color: ComebakColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ComebakLayout.radiusXl),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STREAK DEBUG',
                  style: ComebakTypography.sectionTitle.copyWith(
                    color: ComebakColors.neonGreen,
                    letterSpacing: 2.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: ComebakColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ComebakLayout.spaceLg),

            // PRESET DROPDOWN
            DropdownButtonFormField<String>(
              key: ValueKey(_selectedPreset ?? 'none'),
              initialValue: _selectedPreset,
              dropdownColor: ComebakColors.surfaceElevated,
              decoration: InputDecoration(
                labelText: 'Load Preset State',
                labelStyle: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.textSecondary,
                ),
                filled: true,
                fillColor: ComebakColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              items:
                  [
                        'S1: First Time',
                        'S2: Day 1 (Positive)',
                        'S3: Day 3 Active',
                        'S9: At Risk (10 AM)',
                        'S10: Critical (8 PM)',
                        'S11: Broken',
                      ]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: ComebakTypography.bodyMedium.copyWith(
                              color: ComebakColors.textPrimary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) _applyPreset(val);
              },
            ),
            const SizedBox(height: ComebakLayout.spaceLg),

            // FORM FIELDS
            Row(
              children: [
                Expanded(child: _buildTextField('Total Games', _gamesCtrl)),
                const SizedBox(width: ComebakLayout.spaceSm),
                Expanded(child: _buildTextField('Total XP', _xpCtrl)),
                const SizedBox(width: ComebakLayout.spaceSm),
                Expanded(child: _buildTextField('Streak', _streakCtrl)),
              ],
            ),
            const SizedBox(height: ComebakLayout.spaceSm),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Delta Today', _deltaTodayCtrl),
                ),
                const SizedBox(width: ComebakLayout.spaceSm),
                Expanded(
                  child: _buildTextField('Delta Yesterday', _deltaYestCtrl),
                ),
              ],
            ),
            const SizedBox(height: ComebakLayout.spaceSm),
            _buildTextField('Last Played (ISO)', _lastPlayedCtrl),
            const SizedBox(height: ComebakLayout.spaceSm),
            _buildTextField('Debug Now (ISO)', _debugNowCtrl),

            const SizedBox(height: ComebakLayout.spaceLg),
            Text(
              'RAW JSON',
              style: ComebakTypography.labelSmall.copyWith(
                color: ComebakColors.textSecondary,
              ),
            ),
            const SizedBox(height: ComebakLayout.spaceXs),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: ComebakColors.canvas,
                borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
                border: Border.all(color: ComebakColors.border),
              ),
              child: TextField(
                controller: _jsonCtrl,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: ComebakColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(ComebakLayout.spaceMd),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: ComebakLayout.spaceSm),
              Text(
                _errorMessage!,
                style: ComebakTypography.labelSmall.copyWith(
                  color: ComebakColors.vibrantRed,
                ),
              ),
            ],

            const SizedBox(height: ComebakLayout.spaceLg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: ComebakColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ComebakLayout.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'RESET',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ComebakLayout.spaceMd),
                Expanded(
                  child: TextButton(
                    onPressed: _applyPayload,
                    style: TextButton.styleFrom(
                      backgroundColor: ComebakColors.neonGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ComebakLayout.radiusMd,
                        ),
                      ),
                    ),
                    child: Text(
                      'APPLY',
                      style: ComebakTypography.labelSmall.copyWith(
                        color: ComebakColors.canvas,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: ComebakTypography.bodyMedium.copyWith(
        color: ComebakColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: ComebakTypography.labelSmall.copyWith(
          color: ComebakColors.textSecondary,
        ),
        filled: true,
        fillColor: ComebakColors.canvas,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ComebakLayout.spaceMd,
          vertical: ComebakLayout.spaceSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ComebakLayout.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
