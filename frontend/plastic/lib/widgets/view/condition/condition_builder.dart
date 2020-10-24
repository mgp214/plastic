import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class ConditionBuilder extends StatefulWidget {
  final ThingCondition condition;
  final Function(bool) rebuildView;
  final Function(ThingCondition) conditionUpdate;

  const ConditionBuilder({
    Key key,
    @required this.condition,
    @required this.rebuildView,
    @required this.conditionUpdate,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConditionBuilderState();
}

class ConditionBuilderState extends State<ConditionBuilder> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller =
        TextEditingController(text: jsonEncode(widget.condition?.toJson()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _controller,
        onChanged: (newValue) {
          try {
            var newCondition = ThingCondition.fromJsonString(newValue);
            if (newCondition != null) {
              widget.conditionUpdate(newCondition);
            }
          } catch (error) {
            // widget.condition = null;
          }
          widget.rebuildView(false);
        },
      );
}
