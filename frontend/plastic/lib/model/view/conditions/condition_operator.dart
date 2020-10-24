import 'dart:convert';

import 'package:plastic/model/view/conditions/thing_condition.dart';

enum OPERATOR { AND, OR, NOT }

class ConditionOperator extends ThingCondition {
  final OPERATOR operation;
  final List<ThingCondition> operands;

  ConditionOperator({this.operation, this.operands});

  @override
  String toJson() {
    Map<String, dynamic> jsonMap = Map();
    jsonMap['type'] = operation.toString();
    List<String> operandJson = operands.map((o) => o.toJson()).toList();
    jsonMap['operands'] = operandJson;

    return jsonEncode(jsonMap);
  }
}
