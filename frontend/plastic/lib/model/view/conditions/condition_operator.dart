import 'package:flutter/material.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

enum OPERATOR { AND, OR, NOT }

class ConditionOperator extends ThingCondition {
  static const Color AND_COLOR = Colors.green;
  static const Color OR_COLOR = Colors.blue;
  static const Color NOT_COLOR = Colors.red;

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

  static Color getColor(OPERATOR operation) {
    switch (operation) {
      case OPERATOR.AND:
        return AND_COLOR;
      case OPERATOR.OR:
        return OR_COLOR;
      default:
        return NOT_COLOR;
    }
  }

  @override
  bool isEmpty() => operands.length == 0;

  @override
  ThingCondition copy() {
    var copy = ConditionOperator(operation: operation, operands: List());
    for (var operand in operands) {
      copy.operands.add(operand.copy());
    }
    return copy;
  }
}
