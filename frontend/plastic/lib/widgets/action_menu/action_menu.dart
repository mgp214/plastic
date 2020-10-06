import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/action_menu/action_item.dart';

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
          typeCastKey.currentState.display(0, 75);
        } else {
          typeCastKey.currentState.hide();
        }
      }
    }
  }

  void onPressed(BuildContext context) {
    if (_isExpanded) {
      toggleMenu(context);
      return;
    }
    widget.onAdd();
    // toggleQuickAdd(context);
  }

  void onLongPressed(BuildContext context) {
    toggleMenu(context);
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
              color: Colors.transparent,
              padding: EdgeInsets.all(5),
              child: RotationTransition(
                turns: _rotationAnimation,
                child: AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) => Icon(
                    Icons.add,
                    color: _colorAnimation.value,
                    size: 40,
                  ),
                ),
              ),
              onPressed: () => onPressed(context),
              onLongPress: () => onLongPressed(context),
              shape:
                  CircleBorder(side: BorderSide(color: Motif.title, width: 3)),
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
