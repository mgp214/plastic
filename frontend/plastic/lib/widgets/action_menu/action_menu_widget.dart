import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/action_menu/action_widget.dart';

class ActionMenuWidget extends StatefulWidget {
  final VoidCallback onAdd;
  final List<ActionWidget> children;

  ActionMenuWidget({@required this.onAdd, @required this.children});

  @override
  State<StatefulWidget> createState() => ActionMenuState();
}

class ActionMenuState extends State<ActionMenuWidget>
    with TickerProviderStateMixin {
  List<Key> actionKeys;
  bool _isExpanded = false;
  // bool _isQuickAddOpen = false;
  AnimationController _menuController;
  // AnimationController _quickAddController;
  Animation<Color> _colorAnimation;
  Animation<double> _rotationAnimation;
  // Animation<Offset> _quickAddAnimation;
  // FocusNode _quickAddFocus;

  void toggleMenu(BuildContext context) {
    _isExpanded = !_isExpanded;
    if (_isExpanded)
      _menuController.forward();
    else
      _menuController.reverse();

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

  // void toggleQuickAdd(BuildContext context) {
  //   // if the action menu is open, close it first, then await further interaction.
  //   if (_isExpanded) {
  //     toggleMenu(context);
  //     return;
  //   }
  //   setState(() {
  //     _isQuickAddOpen = !_isQuickAddOpen;
  //   });

  //   if (_isQuickAddOpen) {
  //     _menuController.forward();
  //     _quickAddController.forward();
  //     _quickAddFocus.requestFocus();
  //   } else {
  //     _menuController.reverse();
  //     _quickAddController.reverse();
  //     FocusScope.of(context).unfocus();
  //   }
  // }

  void onPressed(BuildContext context) {
    if (_isExpanded) {
      toggleMenu(context);
      return;
    }
    widget.onAdd();
    // toggleQuickAdd(context);
  }

  void onLongPressed(BuildContext context) {
    // if quick add is open, close it first, then await further interaction
    // if (_isQuickAddOpen) {
    //   toggleQuickAdd(context);
    //   return;
    // }
    toggleMenu(context);
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    // _isQuickAddOpen = false;
    _menuController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    // _quickAddController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 200),
    // );
    _rotationAnimation = Tween(begin: 0.0, end: 3 / 8).animate(_menuController);
    // _quickAddAnimation = Tween(begin: Offset(0, 1.5), end: Offset.zero).animate(
    //   CurvedAnimation(
    //     curve: Curves.easeOut,
    //     parent: _quickAddController,
    //   ),
    // );
    _colorAnimation = ColorTween(begin: Motif.title, end: Motif.negative)
        .animate(_menuController);
    // _quickAddFocus = FocusNode();
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

    // Widget quickAdd = Positioned(
    //   bottom: MediaQuery.of(context).viewInsets.bottom + 10,
    //   left: 5,
    //   child: SlideTransition(
    //     position: _quickAddAnimation,
    //     child: QuickAddWidget(
    //       focusNode: _quickAddFocus,
    //     ),
    //   ),
    // );

    List<Widget> actions = List();
    actions.addAll(widget.children);
    actions.add(main);
    // actions.add(widget.add);
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
