import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class ThingConditionWidget extends StatefulWidget {
  final ThingCondition condition;

  const ThingConditionWidget({Key key, @required this.condition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ThingConditionWidgetState();

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

class ThingConditionWidgetState extends State<ThingConditionWidget> {
  Widget _getDraggable() {
    if (widget.condition is ConditionOperator) {
      var conditionAsOperator = widget.condition as ConditionOperator;
      var children = List<Widget>();
      for (var operand in conditionAsOperator.operands) {
        children.add(ThingConditionWidget(
          condition: operand,
        ));
      }
      if (children.length == 0)
        children.add(Text("no conditions yet",
            style: Motif.contentStyle(
              Sizes.Content,
              Motif.lightBackground,
            )));
      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<OPERATOR>(
              value: conditionAsOperator.operation,
              items: OPERATOR.values
                  .map(
                    (o) => DropdownMenuItem(
                      child: Text(
                        ConditionOperator.getFriendlyString(o),
                      ),
                      value: o,
                    ),
                  )
                  .toList(),
              onChanged: (newOperator) => setState(() {
                conditionAsOperator.operation = newOperator;
              }),
            ), // Text(conditionAsOperator.operation.toString()),
          ),
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                VerticalDivider(thickness: 2, color: Motif.title),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: children
                        .map((c) => Row(
                              children: [c],
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      if (widget.condition is TemplateCondition) {
        return Column(
          children: [Text(widget.condition.toString())],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: Draggable(
          child: _getDraggable(),
          feedback: _getDraggable(),
        ),
      );
}
