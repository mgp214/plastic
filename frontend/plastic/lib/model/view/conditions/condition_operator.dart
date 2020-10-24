import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

enum OPERATOR { AND, OR, NOT }

class ConditionOperator extends ThingCondition {
  final OPERATOR operation;
  final List<ThingCondition> operands;

  ConditionOperator({@required this.operation, @required this.operands});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = Map();
    jsonMap['type'] = "operation";
    jsonMap['operator'] = operation.toString();
    List operandJson = operands.map((o) => o.toJson()).toList();
    jsonMap['operands'] = operandJson;

    return jsonMap;
  }
}
