import 'package:flutter/material.dart';

class ActionWidget extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  ActionWidget({
    GlobalKey<ActionState> key,
    @required this.icon,
    @required this.color,
    @required this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ActionState();
}

class ActionState extends State<ActionWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Color _currentColor;
  Animation<Offset> _animation;
  Offset _origin;
  Offset targetOffset;

  void onAnimationFinish(status) {
    if (status == AnimationStatus.completed &&
        _animation.value.dx == _origin.dx &&
        _animation.value.dy == _origin.dy) {
      setState(() {
        _currentColor = Colors.red;
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
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation =
        Tween<Offset>(begin: _origin, end: _origin).animate(CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _controller,
    ));
  }

  @override
  Widget build(BuildContext context) => Positioned(
        right: 20,
        bottom: 20,
        child: SlideTransition(
          position: _animation,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 50,
              height: 50,
              child: FlatButton(
                color: Colors.transparent,
                padding: EdgeInsets.all(5),
                child: Icon(
                  widget.icon,
                  color: _currentColor,
                  size: 40,
                ),
                onPressed: widget.onPressed,
                shape: CircleBorder(
                  side: BorderSide(color: _currentColor, width: 3),
                ),
              ),
            ),
          ),
        ),
      );
}
