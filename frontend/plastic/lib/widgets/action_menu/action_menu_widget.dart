import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/action_menu/action_widget.dart';

class ActionMenuWidget extends StatefulWidget {
  final List<ActionWidget> children;

  ActionMenuWidget({@required this.children});

  @override
  State<StatefulWidget> createState() => ActionMenuState();
}

class ActionMenuState extends State<ActionMenuWidget>
    with SingleTickerProviderStateMixin {
  List<Key> actionKeys;
  bool _isExpanded = false;
  AnimationController _controller;

  void onPressed() {}

  void onLongPressed(BuildContext context) {
    _isExpanded = !_isExpanded;
    if (_isExpanded)
      _controller.forward();
    else
      _controller.reverse();

    for (var key in actionKeys) {
      var typeCastKey = key as GlobalKey<ActionState>;
      if (typeCastKey != null) {
        if (_isExpanded) {
          typeCastKey.currentState.display(0, 75);
        } else {
          typeCastKey.currentState.hide();
        }
      }
    }
  }

  @override
  void initState() {
    _isExpanded = false;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget main = Positioned(
      bottom: 20,
      right: 20,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 50,
          height: 50,
          child: GestureDetector(
            child: FlatButton(
              color: Colors.transparent,
              padding: EdgeInsets.all(5),
              child: RotationTransition(
                turns: Tween(begin: 0.0, end: 3 / 8).animate(_controller),
                child: Icon(
                  Icons.add,
                  color: Style.primary,
                  size: 40,
                ),
              ),
              onPressed: onPressed,
              onLongPress: () => onLongPressed(context),
              highlightColor: Style.accent,
              shape: CircleBorder(
                  side: BorderSide(color: Style.primary, width: 3)),
            ),
            onVerticalDragStart: (details) => onLongPressed(context),
            onHorizontalDragStart: (details) => onLongPressed(context),
          ),
        ),
      ),
    );

    List<Widget> actions = List();
    actions.addAll(widget.children);
    actions.add(main);
    actionKeys = widget.children.map((child) => child.key).toList();

    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        fit: StackFit.expand,
        children: actions,
      ),
    );
  }
}
