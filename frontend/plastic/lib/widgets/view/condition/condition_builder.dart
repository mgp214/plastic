import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
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
  TextEditingController _controller;
  ThingCondition condition;

  @override
  void initState() {
    condition = widget.condition;
    _controller =
        TextEditingController(text: jsonEncode(widget.condition?.toJson()));
    super.initState();
  }

  Widget _getAddOperationButton() => Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Motif.background),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.create_new_folder_outlined,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  Widget _getAddConditionButton() => Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Motif.background),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.rule,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            ThingConditionWidget(
              condition: condition ??
                  ConditionOperator(operation: OPERATOR.AND, operands: []),
            )
          ],
        ),
        Positioned(
          bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
          right: 10,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: _getAddOperationButton(),
              ),
              _getAddConditionButton(),
            ],
          ),
        )
      ]),
    );
  }
}
