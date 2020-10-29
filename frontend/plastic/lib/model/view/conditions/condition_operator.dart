import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

enum OPERATOR { AND, OR, NOT }

class ConditionOperator extends ThingCondition {
  OPERATOR operation;
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

  @override
  static ThingCondition fromJson(Map<String, dynamic> json) =>
      ConditionOperator(
        operation: OPERATOR.values
            .singleWhere((o) => o.toString() == json['operator']),
        operands: (json['operands'] as List)
            .map((m) => ThingCondition.fromJsonAgnostic(m))
            .toList(),
      );

  static String getFriendlyString(OPERATOR operation) {
    switch (operation) {
      case OPERATOR.AND:
        return "All of these things";
      case OPERATOR.OR:
        return "Any of these things";
      case OPERATOR.NOT:
        return "None of these things";
    }
    return "Error!";
  }
}
