import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
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
  TextEditingController _controller;
  ThingCondition condition;

  @override
  void initState() {
    condition = widget.condition;
    _controller =
        TextEditingController(text: jsonEncode(widget.condition?.toJson()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ThingConditionWidget(
            condition: condition,
          )
        ],
      ),
    );
  }
}
