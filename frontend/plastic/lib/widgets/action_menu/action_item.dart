import 'package:flutter/material.dart';
import 'package:plastic/utility/constants.dart';

class ActionItem extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  ActionItem({
    GlobalKey<ActionItemState> key,
    @required this.icon,
    @required this.color,
    @required this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActionItemState();
}

class ActionItemState extends State<ActionItem>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Color _currentColor;
  Animation<Offset> _animation;
  Offset _origin;
  Offset targetOffset;

  void onAnimationFinish(status) {
    if (status == AnimationStatus.dismissed &&
        _animation.value.dx == _origin.dx &&
        _animation.value.dy == _origin.dy) {
      setState(() {
        _currentColor = Colors.transparent;
      });
    }
  }

  void initializeAnimations(double x, double y) {
    targetOffset = Offset(x, y);

    var animation = Tween<Offset>(begin: _origin, end: targetOffset).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener(onAnimationFinish);

    setState(() {
      _animation = animation;
    });
  }

  void display(double x, double y) {
    var adjustedX = _origin.dx - x / 50;
    var adjustedY = _origin.dy - y / 50;

    if (targetOffset.dx != adjustedX || targetOffset.dy != adjustedY)
      initializeAnimations(adjustedX, adjustedY);

    setState(() {
      _currentColor = widget.color;
    });
    _controller.forward();
  }

  void hide() {
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _origin = Offset(0, 0);
    targetOffset = Offset(0, 0);
    _currentColor = Colors.transparent;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animation =
        Tween<Offset>(begin: _origin, end: _origin).animate(CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _controller,
    ));
  }

  @override
  Widget build(BuildContext context) => Positioned(
        right: 10,
        bottom: 10,
        child: SlideTransition(
          position: _animation,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 50,
              height: 50,
              child: FadeTransition(
                opacity:
                    Tween<double>(begin: 0.0, end: 1.0).animate(_controller),
                child: FlatButton(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    widget.icon,
                    color: _currentColor,
                    size: Constants.iconSize,
                  ),
                  onPressed: widget.onPressed,
                  shape: CircleBorder(
                    side: BorderSide(color: _currentColor, width: 3),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
