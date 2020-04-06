import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SpotLightTabBar extends StatefulWidget {
  final Color color;
  final TabController controller;

  SpotLightTabBar({Key key, this.color = Colors.white, @required this.controller}) : super(key: key);

  final _SpotLightTabBarState _state = _SpotLightTabBarState();

  @override
  _SpotLightTabBarState createState() => _state;
}

class _SpotLightTabBarState extends State<SpotLightTabBar> {
  double _opacity = 0.5;
  @override
  void initState() {
    super.initState();
    widget.controller.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _opacity = 0.5;
      } else {
        _opacity = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: AnimatedBuilder(
        animation: widget.controller.animation,
        builder: (context, child) => TabBar(
          controller: widget.controller,
          indicator: _SpotLightIndicator(
            color: Colors.white,
            opacity: _opacity,
            positionX: widget.controller.animation.value,
          ),
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.local_mall),
            ),
            Tab(
              icon: Icon(Icons.favorite_border),
            ),
            Tab(
              icon: Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotLightIndicator extends Decoration {
  final BoxPainter _painter;

  _SpotLightIndicator({
    @required Color color,
    @required double opacity,
    @required double positionX,
  }) : _painter = _SpotLightPainter(color, opacity, positionX);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _SpotLightPainter extends BoxPainter {
  final Paint _beamPaint;
  final Paint _emitterPaint;
  final double _positionX;

  _SpotLightPainter(Color color, double opacity, double positionX)
      : _positionX = positionX,
        _beamPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0.0, kBottomNavigationBarHeight),
            [
              color.withOpacity(opacity),
              Colors.transparent,
            ],
          )
          ..isAntiAlias = true,
        _emitterPaint = Paint()
          ..color = color
          ..isAntiAlias = true
          ..strokeWidth = 2.5
          ..isAntiAlias = true;

  @override
  // Let's create a trapezoid ABCD, beign AB the top (and smaller side), and CD the base (and larger side)
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    Path _path = Path();
    // We have to build a line (with points P1 and P2) and a trapezoid (with points A, B, C and D).
    //
    // That's what we want to build:
    //
    //   P1======P2
    //   A/------\B
    //   /........\
    // D/..........\C
    //
    // In order to do so, the points must be calculated as follow:
    //
    // We have a line (P1->P2) on top, i.e., the "light emitter",
    // with a "padding" of 34% of the tab width
    final Offset _lineP1 = Offset((_positionX * cfg.size.width) + (cfg.size.width * 0.34), 0.0);
    final Offset _lineP2 = Offset((_positionX * cfg.size.width) - (cfg.size.width * 0.34) + cfg.size.width, 0.0);

    // Now we calculate the "light beam"

    // Point A is 35% from left and at the top
    final Offset _pointA = Offset(offset.dx + (cfg.size.width * 0.35), 0.0);
    // Point B is 35% from right and at the top
    final Offset _pointB = Offset(offset.dx + cfg.size.width - (cfg.size.width * 0.35), 0.0);
    // point C is 25% from right and at the bottom
    final Offset _pointC = Offset(offset.dx + cfg.size.width - (cfg.size.width * 0.17), cfg.size.height);
    // point D is 25% from left and at the bottom
    final Offset _pointD = Offset(offset.dx + (cfg.size.width * 0.17), cfg.size.height);
    // Add the beam points to a path...
    _path.addPolygon([_pointA, _pointB, _pointC, _pointD], true);
    // And draw everything! :)
    canvas.drawLine(_lineP1, _lineP2, _emitterPaint);
    canvas.drawPath(_path, _beamPaint);
  }
}
