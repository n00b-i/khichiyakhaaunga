import 'package:flutter/material.dart';
import '../1_foundations/tokens/ui_lab_tokens.dart';

class ComebakAddBurstIcon extends StatelessWidget {
  final double size;
  const ComebakAddBurstIcon({super.key, required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: CustomPaint(painter: _AddBurstPainter()));
}

class _AddBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 140.0;
    canvas.translate(size.width / 2, size.height / 2 - (10 * scale));
    final shadowPaint = Paint()..color = ComebakColors.addBaseLeft.withValues(alpha: 0.4)..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * scale);
    canvas.drawOval(Rect.fromCenter(center: Offset(0, 45 * scale), width: 100 * scale, height: 30 * scale), shadowPaint);
    canvas.save();
    canvas.translate(ComebakLayout.isoSmallCubeOffset.dx * scale, ComebakLayout.isoSmallCubeOffset.dy * scale);
    canvas.scale(ComebakLayout.isoSmallCubeScale);
    _drawCube(canvas, scale, isSmall: true);
    canvas.restore();
    _drawCube(canvas, scale, isSmall: false);
  }

  void _drawCube(Canvas canvas, double scale, {required bool isSmall}) {
    final w = ComebakLayout.isoCubeWidth * scale; final h = ComebakLayout.isoCubeHeight * scale; final e = ComebakLayout.isoCubeExtrusion * scale; final soft = ComebakLayout.isoEdgeSoftness * scale;
    final pTop = Offset(0, -h); final pRight = Offset(w, 0); final pBottom = Offset(0, h); final pLeft = Offset(-w, 0);
    _drawSoftFace(canvas, Path()..moveTo(pLeft.dx, pLeft.dy)..lineTo(pBottom.dx, pBottom.dy)..lineTo(pBottom.dx, pBottom.dy + e)..lineTo(pLeft.dx, pLeft.dy + e)..close(), ComebakColors.addBaseLeft, soft);
    _drawSoftFace(canvas, Path()..moveTo(pBottom.dx, pBottom.dy)..lineTo(pRight.dx, pRight.dy)..lineTo(pRight.dx, pRight.dy + e)..lineTo(pBottom.dx, pBottom.dy + e)..close(), ComebakColors.addBaseRight, soft);
    _drawSoftFace(canvas, Path()..moveTo(pLeft.dx, pLeft.dy)..lineTo(pBottom.dx, pBottom.dy)..lineTo(pBottom.dx, pBottom.dy + e)..lineTo(pLeft.dx, pLeft.dy + e)..close(), Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ComebakColors.addLeftStart, ComebakColors.addLeftEnd]).createShader(Rect.fromPoints(pLeft, Offset(pBottom.dx, pBottom.dy + e))), soft);
    _drawSoftFace(canvas, Path()..moveTo(pRight.dx, pRight.dy)..lineTo(pBottom.dx, pBottom.dy)..lineTo(pBottom.dx, pBottom.dy + e)..lineTo(pRight.dx, pRight.dy + e)..close(), Paint()..shader = const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [ComebakColors.addRightStart, ComebakColors.addRightEnd]).createShader(Rect.fromPoints(Offset(pBottom.dx, pBottom.dy), Offset(pRight.dx, pRight.dy + e))), soft);
    _drawSoftFace(canvas, Path()..moveTo(pTop.dx, pTop.dy)..lineTo(pRight.dx, pRight.dy)..lineTo(pBottom.dx, pBottom.dy)..lineTo(pLeft.dx, pLeft.dy)..close(), Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ComebakColors.addTopStart, ComebakColors.addTopEnd]).createShader(Rect.fromPoints(pTop, Offset(pRight.dx, pBottom.dy))), soft);
    canvas.drawPath(Path()..moveTo(pTop.dx, pTop.dy)..lineTo(pLeft.dx / 2, pLeft.dy / 2)..lineTo(pBottom.dx / 2, pBottom.dy / 2)..lineTo(0, 0)..close(), Paint()..color = Colors.white.withValues(alpha: 0.3));
    _drawEmbossedText(canvas, isSmall ? '=' : '+', scale, isSmall ? 40 : 45, ComebakColors.addTextDeep, ComebakColors.addTextMid);
  }

  void _drawSoftFace(Canvas canvas, Path path, dynamic p, double s) {
    Paint stroke = p is Color ? (Paint()..color = p..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeWidth = s) : (Paint()..color = Colors.white.withValues(alpha: 0.1)..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeWidth = s);
    Paint fill = p is Color ? (Paint()..color = p) : (p as Paint);
    canvas.drawPath(path, stroke); canvas.drawPath(path, fill);
  }

  void _drawEmbossedText(Canvas canvas, String text, double scale, double fontSize, Color deep, Color mid) {
    final style = TextStyle(fontFamily: 'system-ui', fontWeight: FontWeight.w900, fontSize: fontSize * scale);
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr)..layout();
    final off = Offset(-tp.width / 2, -tp.height / 2 + (5 * scale)); final drop = ComebakLayout.isoTextOffset * scale;
    tp.text = TextSpan(text: text, style: style.copyWith(color: deep)); tp.layout(); tp.paint(canvas, off + Offset(0, drop));
    tp.text = TextSpan(text: text, style: style.copyWith(color: mid)); tp.layout(); tp.paint(canvas, off + Offset(0, drop * 0.5));
    tp.text = TextSpan(text: text, style: style.copyWith(color: Colors.white, shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), offset: const Offset(0, 2), blurRadius: 2)])); tp.layout(); tp.paint(canvas, off);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}