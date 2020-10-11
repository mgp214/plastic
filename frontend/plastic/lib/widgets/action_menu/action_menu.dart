import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/action_menu/action_item.dart';
import 'package:vector_math/vector_math.dart';
import 'dart:math';

class ActionMenu extends StatefulWidget {
  final VoidCallback onAdd;
  final List<ActionItem> children;

  ActionMenu({@required this.onAdd, @required this.children});

  @override
  State<StatefulWidget> createState() => ActionMenuState();
}

class ActionMenuState extends State<ActionMenu> with TickerProviderStateMixin {
  List<Key> actionKeys;
  bool _isExpanded = false;
  AnimationController _menuController;
  Animation<Color> _colorAnimation;
  Animation<double> _rotationAnimation;
  Map<Key, Vector2> positions;

  void toggleMenu(BuildContext context) {
    _isExpanded = !_isExpanded;
    if (_isExpanded)
      _menuController.forward();
    else
      _menuController.reverse();

    for (var key in actionKeys) {
      var typeCastKey = key as GlobalKey<ActionItemState>;
      if (typeCastKey != null) {
        if (_isExpanded) {
          // typeCastKey.currentState.display(0, 75);
          typeCastKey.currentState.display(positions[key].x, positions[key].y);
        } else {
          typeCastKey.currentState.hide();
        }
      }
    }
  }

  void onPressed() {
    if (_isExpanded) {
      toggleMenu(context);
      return;
    }
    widget.onAdd();
    // toggleQuickAdd(context);
  }

  void onLongPressed() {
    toggleMenu(context);
  }

  void calculatePositions() {
    positions = Map();
    var radius = 75.0;
    for (var i = 0; i < actionKeys.length; i++) {
      var key = actionKeys[i];
      var t = Matrix2.rotation(i * (-pi / 2) / (actionKeys.length - 1));
      positions[key] = t.transform(Vector2(0, radius));
    }
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _menuController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween(begin: 0.0, end: 3 / 8).animate(_menuController);
    _colorAnimation = ColorTween(begin: Motif.title, end: Motif.negative)
        .animate(_menuController);
    actionKeys = widget.children.map((child) => child.key).toList();
    calculatePositions();
  }

  @override
  Widget build(BuildContext context) {
    Widget main = Positioned(
      bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
      right: 10,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          width: 50,
          height: 50,
          child: GestureDetector(
            child: FlatButton(
              color: Color.fromARGB(0, 0, 0, 0),
              padding: EdgeInsets.all(5),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) => Icon(
                    Icons.add,
                    color: _colorAnimation.value,
                    size: Constants.iconSize,
                  ),
                ),
              ),
              onPressed: () => onPressed(),
              onLongPress: () => onLongPressed(),
              shape:
                  CircleBorder(side: BorderSide(color: Motif.title, width: 3)),
            ),
            onVerticalDragStart: (details) => onLongPressed(),
            onHorizontalDragStart: (details) => onLongPressed(),
          ),
        ),
      ),
    );

    List<Widget> actions = List();
    actions.addAll(widget.children);
    actions.add(main);

    return Align(
      alignment: Alignment.bottomRight,
      child: Stack(
        fit: StackFit.expand,
        children: actions,
      ),
    );
  }
}
