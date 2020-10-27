import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class ThingConditionWidget extends StatelessWidget {
  final ThingCondition condition;

  const ThingConditionWidget({Key key, @required this.condition})
      : super(key: key);

  Widget _getDraggable(BuildContext context) {
    return Placeholder();
  }

  @override
  Widget build(BuildContext context) => Draggable(
        child: DragTarget(builder: (context, condidateList, rejectedData) {
          return _getDraggable(context);
        }),
        feedback: _getDraggable(context),
      );

  // TODO: replace this old json thingCondition editor
  // TextField(
  //   controller: _controller,
  //   onChanged: (newValue) {
  //     try {
  //       var newCondition = ThingCondition.fromJsonString(newValue);
  //       if (newCondition != null) {
  //         widget.conditionUpdate(newCondition);
  //       }
  //     } catch (error) {
  //       // widget.condition = null;
  //     }
  //     widget.rebuildView(false);
  //   },
  // );
}
