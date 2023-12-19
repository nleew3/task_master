import 'package:flutter/material.dart';
import 'dart:math';

// Used to add colored circles to progress monitor on right side of screen
class OpenPainter extends CustomPainter {
  OpenPainter({
    this.color = Colors.lightBlue,
    required this.innerRadius,
    required this.outerRadius,
    this.total = 1,
    this.useStroke = false,
    this.percentage = 1,
    this.startAngle = 270,
    this.sweepAngle = 359.9,
    this.setOffset = const Offset(0, 0),
    this.clockwise = false
  });

  //Color color;
  double innerRadius;
  double outerRadius;
  Color color;
  int total;
  bool useStroke;
  bool clockwise;
  double percentage;
  double startAngle;
  double sweepAngle;
  Offset setOffset;
  List<Path> paths = []; //Path();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < total; i++) {
      paint.color = color;
      if (useStroke) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 4;
      }

      Path path = _getPath(size, i);
      paths.add(path);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool? hitTest(Offset position) {
    bool didHit = false;
    for (int i = 0; i < paths.length; i++) {
      bool checkHit = paths[i].contains(position);
      if (checkHit) {
        didHit = checkHit;
      }
    }

    return didHit;
  }

  _getPath(Size size, int i) {
    double rad = pi / 180;
    double endSize = outerRadius - innerRadius;
    double angleSize = (sweepAngle / (total)) * percentage;

    double start = startAngle - (angleSize * i);
    double end = startAngle - (angleSize * (i + 1));

    Offset offsetSet = setOffset;

    Path path = Path()
      ..arcTo(Rect.fromCircle(center: offsetSet, radius: outerRadius),
          (start) * rad, (end - start) * rad, true)
      ..relativeLineTo(-cos((end) * rad) * (outerRadius - innerRadius),
          -sin((end) * rad) * (outerRadius - innerRadius))
      ..arcTo(Rect.fromCircle(center: offsetSet, radius: innerRadius),
          (end) * rad, (start - end) * rad, false)
      ..close();
    if (percentage != 1) {
      if (!clockwise) {
        path.addArc(
            Rect.fromCircle(
                center: Offset(cos(start * rad) * (outerRadius - endSize / 2),
                    sin(start * rad) * (outerRadius - endSize / 2)),
                radius: endSize / 2),
            start * rad,
            pi);
        path.addArc(
            Rect.fromCircle(
                center: Offset(cos(end * rad) * (outerRadius - endSize / 2),
                    sin(end * rad) * (outerRadius - endSize / 2)),
                radius: endSize / 2),
            (end + 180) * rad,
            pi);
      } else {
        path.addArc(
            Rect.fromCircle(
                center: Offset(cos(start * rad) * (outerRadius - endSize / 2),
                    sin(start * rad) * (outerRadius - endSize / 2)),
                radius: endSize / 2),
            -start * rad,
            pi);
        path.addArc(
            Rect.fromCircle(
                center: Offset(cos(end * rad) * (outerRadius - endSize / 2),
                    sin(end * rad) * (outerRadius - endSize / 2)),
                radius: endSize / 2),
            (end) * rad,
            pi);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
