import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/view/condition/thing_condition_widget.dart';

class ConditionBuilder extends StatefulWidget {
  final ThingCondition condition;
  final Function(ThingCondition) conditionUpdate;

  const ConditionBuilder({
    Key key,
    @required this.condition,
    @required this.conditionUpdate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConditionBuilderState();
}

class ConditionBuilderState extends State<ConditionBuilder> {
  ThingCondition condition;
  bool _isDragging;

  @override
  void initState() {
    condition = widget.condition;
    _isDragging = false;
    super.initState();
  }

  Widget _getAddChild(IconData icon, Color color) => Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            icon,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  Widget _getPositionedAction() {
    if (_isDragging == false)
      return Draggable(
        feedback: _getAddChild(
          Icons.rule,
          Color.fromARGB(
            128,
            Motif.background.red,
            Motif.background.green,
            Motif.background.blue,
          ),
        ),
        dragAnchor: DragAnchor.child,
        child: _getAddChild(Icons.rule, Motif.background),
        onDragStarted: () => setState(() {
          _isDragging = true;
        }),
        onDragEnd: (dd) => setState(() {
          _isDragging = false;
        }),
        onDraggableCanceled: (velocity, offset) => setState(() {
          _isDragging = false;
        }),
        data: null as dynamic,
      );
    return DragTarget(
      builder: (context, candidateData, rejectedData) => Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Motif.background),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.delete,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      ),
      onWillAccept: (candidate) => true,
      onAccept: (candidate) => setState(() {
        _isDragging = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () {
          widget.conditionUpdate(condition.clean());
          return Future.value(true);
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(children: [
              Column(
                children: [
                  ThingConditionWidget(
                    condition: condition,
                    rebuildLayout: (isDragging) => setState(() {
                      _isDragging = isDragging;
                    }),
                    resetLayout: (c) => setState(() {
                      _isDragging = false;
                      condition = c;
                    }),
                  ),
                ],
              ),
              Positioned(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
                right: 10,
                child: Row(
                  children: [
                    _getPositionedAction(),
                  ],
                ),
              )
            ]),
          ),
        ),
      );
}
