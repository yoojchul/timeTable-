import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily  TimeTable ',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Daily TimeTable"),
        ),
        body: DailyAlarms(),
      ),
    );
  }
}

class DailyAlarms extends StatefulWidget {
  @override
  _DailyAlarmsState createState() => _DailyAlarmsState();
}

class _DailyAlarmsState extends State<DailyAlarms> {
  var xPos = 100.0;
  var yPos = 100.0;
  var xOrigPos = 100.0;
  var yOrigPos = 100.0;
  var radius = 150.0;
  final maxScale = 3.0;
  double strokeWidth = 3;
  var xSize = 0.0;
  var ySize = 0.0;
  var xCenter = 0.0;
  var yCenter = 0.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;
  double _scale = 1.0;
  double _initialScale = 1.0;
  bool first = true;

  @override
  Widget build(BuildContext context) {
    xSize = MediaQuery.of(context).size.width;
    ySize = MediaQuery.of(context).size.height;
    if (first) {
      radius = xSize < ySize ? xSize * 3.0 / 8.0 : ySize * 3.0 / 8.0;
      xCenter = xSize / 2;
      yCenter = ySize / 2;
      xPos = xCenter;
      yPos = yCenter;
      first = false;
    }
    return GestureDetector(
      onScaleStart: (details) {
        _initialFocalPoint = details.focalPoint;
        _initialScale = _scale;
        xOrigPos = xPos;
        yOrigPos = yPos;
      },
      onScaleEnd: (details) {
        setState(()  {
          if (_scale < 1.0) {
            radius = xSize < ySize ? xSize * 3.0 / 8.0 : ySize * 3.0 / 8.0;
            xPos = xCenter;
            yPos = yCenter;
            _scale = 1.0;
            _initialScale = 1.0;
          }
          else if (_scale > maxScale) {
            _scale = maxScale;
          }
        });
      },
      onScaleUpdate: (details) {
        setState(() {
          _sessionOffset = details.focalPoint - _initialFocalPoint;
          _scale = _initialScale * details.scale;
          xPos = (xOrigPos - xCenter) * details.scale + xCenter + _sessionOffset.dx;
          yPos = (yOrigPos - yCenter) * details.scale + yCenter + _sessionOffset.dy;
        });
      },
      child: Container(
        color: Colors.white,
        child: CustomPaint(
          painter: CirclePainter(Circle(x:xPos, y:yPos, radius:radius, width:strokeWidth, scale:_scale)),
          child: Container(),
        ),
      ),
    );
  }
}

class Circle {
  final double x;
  final double y;
  final double radius;
  final double width;
  final double scale;

  Circle({
    required this.x,
    required this.y,
    required this.radius,
    required this.width,
    required this.scale,
  });
}

class CirclePainter extends CustomPainter {
  CirclePainter(this.cir);
  final Circle cir;

  @override
  void paint(Canvas canvas, Size size) {
    var x = 0.0;
    var y = 0.0;
    var innerX = 0.0;
    var innerY = 0.0;
    var brush = Paint();
    brush.color = Colors.black;
    brush.style = PaintingStyle.stroke;
    brush.strokeWidth = cir.width*cir.scale;
    canvas.drawCircle(Offset(cir.x, cir.y), cir.radius*cir.scale, brush);

    var step = 2*pi/24.0;
    for (var rad=-pi/2.0; rad <= 3*pi/2.0; rad+=step) {
      x = cir.x + cir.radius*cir.scale * cos(rad);
      y = cir.y + cir.radius*cir.scale * sin(rad);
      innerX = cir.x + (cir.radius-10)*cir.scale * cos(rad);
      innerY = cir.y + (cir.radius-10)*cir.scale * sin(rad);
      canvas.drawLine(Offset(x, y), Offset(innerX, innerY), brush);
    }

    var rad = 0.0;
    var num = 4;
    if (cir.scale > 2.0) num=24;
    else if (cir.scale > 1.5) num = 12;
    else if (cir.scale > 1.2) num = 8;
    step = 2*pi/num;
    for (var i=0; i < num; i++) {
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14 * cir.scale,
      );
      final textSpan = TextSpan(
        text: (i*24/num).toInt().toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      rad = -pi/2.0 + step*i;
      x = (cir.radius+15) * cos(rad) * cir.scale + cir.x;
      y = (cir.radius+15) * sin(rad) * cir.scale + cir.y;
      final offset = Offset(x-textPainter.width/2, y-textPainter.height/2);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}