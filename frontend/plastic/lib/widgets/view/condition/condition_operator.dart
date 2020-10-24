import 'package:flutter/material.dart';

class ConditionOperator extends StatelessWidget {
  final ConditionOperator conditionOperator;

  const ConditionOperator({Key key, @required this.conditionOperator})
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
}
