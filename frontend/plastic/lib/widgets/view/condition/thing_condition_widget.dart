import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class ThingConditionWidget extends StatelessWidget {
  final ThingCondition condition;

  const ThingConditionWidget({Key key, @required this.condition})
      : super(key: key);

  Widget _getDraggable(BuildContext context) {
    if (condition is ConditionOperator) {
      var conditionAsOperator = condition as ConditionOperator;
      var children = List<Widget>();
      children.add(
        Text(conditionAsOperator.operation.toString()),
      );
      for (var operand in conditionAsOperator.operands) {
        children.add(ThingConditionWidget(
          condition: operand,
        ));
      }
      return Column(
        children: children
            .map((c) => Row(
                  children: [c],
                ))
            .toList(),
      );
    } else {
      if (condition is TemplateCondition) {
        return Column(
          children: [Text(condition.toString())],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Draggable(
            child: _getDraggable(context),
            feedback: _getDraggable(context),
          ),
        ],
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
