import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../ui/components/comebak_card.dart';
import '../ui/components/comebak_button.dart';
import 'dev_harness_controller.dart';

// Minimal Phase 1 verification pill. Phase 2 replaces it with the full panel.
class DevHarnessPill extends StatefulWidget {
  const DevHarnessPill({super.key});

  @override
  State<DevHarnessPill> createState() => _DevHarnessPillState();
}

class _DevHarnessPillState extends State<DevHarnessPill> {
  final _c = DevHarnessController.instance;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChanged);
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  String get _vpLabel {
    final vp = _c.viewport;
    if (vp == null) return 'Auto';
    if (vp.width == 375) return 'SE';
    if (vp.width == 390) return '14';
    if (vp.width == 430) return 'Max';
    return '${vp.width.toInt()}';
  }

  void _cycleViewport() {
    final vp = _c.viewport;
    if (vp == null) {
      _c.setViewport(const Size(375, 667));
    } else if (vp.width == 375) {
      _c.setViewport(const Size(390, 844));
    } else if (vp.width == 390) {
      _c.setViewport(const Size(430, 932));
    } else {
      _c.setViewport(null);
    }
  }

  void _cycleSpeed() {
    final s = _c.speed;
    if (s == 1.0) {
      _c.setSpeed(0.5);
    } else if (s == 0.5) {
      _c.setSpeed(0.25);
    } else if (s == 0.25) {
      _c.setSpeed(2.0);
    } else {
      _c.setSpeed(1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.space32,
            right: AppSpacing.space16,
          ),
          child: ComebakCard(
            padding: const EdgeInsets.all(AppSpacing.space8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ComebakButton(
                  text: _c.paused ? 'Resume' : 'Pause',
                  variant: ComebakButtonVariant.secondary,
                  onPressed: () => _c.setPaused(!_c.paused),
                ),
                const SizedBox(height: AppSpacing.space8),
                ComebakButton(
                  text: 'Viewport: $_vpLabel',
                  variant: ComebakButtonVariant.secondary,
                  onPressed: _cycleViewport,
                ),
                const SizedBox(height: AppSpacing.space8),
                ComebakButton(
                  text: 'Speed: ${_c.speed}x',
                  variant: ComebakButtonVariant.secondary,
                  onPressed: _cycleSpeed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
