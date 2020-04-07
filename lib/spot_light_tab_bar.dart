import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class SpotLightTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final TabController controller;
  final bool isScrollable;
  final Color indicatorColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry indicatorPadding;
  final Decoration indicator;
  final TabBarIndicatorSize indicatorSize;
  final Color labelColor;
  final TextStyle labelStyle;
  final EdgeInsetsGeometry labelPadding;
  final Color unselectedLabelColor;
  final TextStyle unselectedLabelStyle;
  final DragStartBehavior dragStartBehavior;
  final void Function(int) onTap;
  final Color spotColor;
  final Color backgroundColor;
  final double spotLightBasePercentPadding;
  final double spotLightTopPercentPadding;
  final double spotIntensity;

  SpotLightTabBar({
    Key key,
    @required this.tabs,
    @required this.controller,
    this.isScrollable = false,
    this.indicatorColor = Colors.white,
    this.indicatorWeight = 2.0,
    this.indicatorPadding = EdgeInsets.zero,
    this.indicator,
    this.indicatorSize,
    this.labelColor,
    this.labelStyle,
    this.labelPadding,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
    this.dragStartBehavior = DragStartBehavior.start,
    this.onTap,
    this.spotColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.spotLightBasePercentPadding = 0.17,
    this.spotLightTopPercentPadding = 0.35,
    this.spotIntensity = 0.5,
  })  : assert(indicator != null || spotColor != null),
        super(key: key) {
    if (indicatorSize != null) assert(indicator != null);
  }

  final _SpotLightTabBarState _state = _SpotLightTabBarState();

  @override
  _SpotLightTabBarState createState() => _state;
}

class _SpotLightTabBarState extends State<SpotLightTabBar> {
  double _opacity;
  @override
  void initState() {
    super.initState();
    widget.controller.animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _opacity = widget.spotIntensity;
      } else {
        _opacity = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: widget.controller.animation,
        builder: (context, child) => TabBar(
          key: widget.key,
          tabs: widget.tabs,
          controller: widget.controller,
          isScrollable: widget.isScrollable,
          indicatorColor: widget.indicatorColor,
          indicatorWeight: widget.indicatorWeight,
          indicatorPadding: widget.indicatorPadding,
          indicatorSize: widget.indicatorSize,
          labelColor: widget.labelColor,
          labelStyle: widget.labelStyle,
          labelPadding: widget.labelPadding,
          unselectedLabelColor: widget.unselectedLabelColor,
          unselectedLabelStyle: widget.unselectedLabelStyle,
          dragStartBehavior: widget.dragStartBehavior,
          onTap: widget.onTap,
          indicator: widget.indicator ??
              _SpotLightIndicator(
                beamColor: widget.spotColor,
                emitterColor: widget.indicatorColor,
                opacity: _opacity ?? widget.spotIntensity,
                positionX: widget.controller.animation.value,
                basePadding: widget.spotLightBasePercentPadding,
                topPadding: widget.spotLightTopPercentPadding,
              ),
        ),
      ),
    );
  }
}

class _SpotLightIndicator extends Decoration {
  final BoxPainter _painter;

  _SpotLightIndicator({
    @required Color beamColor,
    @required Color emitterColor,
    @required double opacity,
    @required double positionX,
    @required double basePadding,
    @required double topPadding,
  }) : _painter = _SpotLightPainter(
          beamColor: beamColor,
          emitterColor: emitterColor,
          opacity: opacity,
          positionX: positionX,
          basePadding: basePadding,
          topPadding: topPadding,
        );

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _SpotLightPainter extends BoxPainter {
  final Paint _beamPaint;
  final Paint _emitterPaint;
  final double positionX;
  final double basePadding;
  final double topPadding;

  _SpotLightPainter({
    Color beamColor,
    double opacity,
    Color emitterColor,
    this.positionX,
    this.basePadding,
    this.topPadding,
  })  : _beamPaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0.0, kBottomNavigationBarHeight),
            [
              beamColor.withOpacity(opacity),
              Colors.transparent,
            ],
          )
          ..isAntiAlias = true,
        _emitterPaint = Paint()
          ..color = emitterColor
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
    final Offset _lineP1 = Offset((positionX * cfg.size.width) + (cfg.size.width * (topPadding - 0.01)), 0.0);
    final Offset _lineP2 = Offset((positionX * cfg.size.width) - (cfg.size.width * (topPadding - 0.01)) + cfg.size.width, 0.0);

    // Now we calculate the "light beam"

    // Point A is 35% from left and at the top
    final Offset _pointA = Offset(offset.dx + (cfg.size.width * topPadding), 0.0);
    // Point B is 35% from right and at the top
    final Offset _pointB = Offset(offset.dx + cfg.size.width - (cfg.size.width * topPadding), 0.0);
    // point C is 25% from right and at the bottom
    final Offset _pointC = Offset(offset.dx + cfg.size.width - (cfg.size.width * basePadding), cfg.size.height);
    // point D is 25% from left and at the bottom
    final Offset _pointD = Offset(offset.dx + (cfg.size.width * basePadding), cfg.size.height);
    // Add the beam points to a path...
    _path.addPolygon([_pointA, _pointB, _pointC, _pointD], true);
    // And draw everything! :)
    canvas.drawLine(_lineP1, _lineP2, _emitterPaint);
    canvas.drawPath(_path, _beamPaint);
  }
}
