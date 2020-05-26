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

class ActionMenuState extends State<ActionMenuWidget> {
  List<Key> actionKeys;
  bool _isExpanded = false;

  void onPressed() {}

  void onLongPressed(BuildContext context) {
    _isExpanded = !_isExpanded;

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
              color: Style.primary,
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.add,
                color: Style.black,
                size: 40,
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
