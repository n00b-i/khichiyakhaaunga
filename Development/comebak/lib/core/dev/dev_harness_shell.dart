import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/app_tokens.dart';
import 'dev_harness_controller.dart';

// Shell wraps the app subtree in debug mode. Applies viewport constraints,
// text scale, pause via TickerMode, and 8pt grid overlay.
class DevHarnessShell extends StatefulWidget {
  final Widget child;
  const DevHarnessShell({super.key, required this.child});

  @override
  State<DevHarnessShell> createState() => _DevHarnessShellState();
}

class _DevHarnessShellState extends State<DevHarnessShell> {
  final _c = DevHarnessController.instance;
  double _lastSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChanged);
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    timeDilation = 1.0;
    super.dispose();
  }

  void _onChanged() {
    if (_lastSpeed != _c.speed) {
      _lastSpeed = _c.speed;
      timeDilation = 1.0 / _c.speed;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Real viewport constraints - SizedBox + MediaQuery override + ClipRect.
    final vp = _c.viewport;
    if (vp != null) {
      final mq = MediaQuery.of(context);
      child = Center(
        child: SizedBox(
          width: vp.width,
          height: vp.height,
          child: MediaQuery(
            data: mq.copyWith(
              size: vp,
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
            ),
            child: ClipRect(child: child),
          ),
        ),
      );
    }

    // Text scale override.
    if (_c.textScale != 1.0) {
      final mq = MediaQuery.of(context);
      child = MediaQuery(
        data: mq.copyWith(textScaler: TextScaler.linear(_c.textScale)),
        child: child,
      );
    }

    // Pause via TickerMode. Silences ticker callbacks; time still elapses.
    child = TickerMode(enabled: !_c.paused, child: child);

    // 8pt grid overlay.
    if (_c.showGrid) {
      child = Stack(
        children: [
          child,
          const Positioned.fill(
            child: IgnorePointer(child: _Grid()),
          ),
        ],
      );
    }

    return child;
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += AppSpacing.space8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += AppSpacing.space8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
