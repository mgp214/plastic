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

  Widget _getAddConditionButton() => Draggable(
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
        data: null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: [
              ThingConditionWidget(
                condition: condition,
              ),
            ],
          ),
          Positioned(
            bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
            right: 10,
            child: Row(
              children: [
                _getAddConditionButton(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
