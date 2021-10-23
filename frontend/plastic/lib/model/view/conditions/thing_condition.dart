import 'dart:convert';

import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';
import 'package:plastic/model/view/conditions/value_condition.dart';

abstract class ThingCondition {
  Map<String, dynamic> toJson();
  bool isEmpty();
  ConditionOperator parent;

  @override
  String toString() {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(this.toJson());
  }

  static ThingCondition fromJsonAgnostic(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'operation':
        return ConditionOperator.fromJson(json);
        break;
      case 'template':
        return TemplateCondition.fromJson(json);
        break;
      case 'value':
        return ValueCondition.fromJson(json);
        break;
      default:
        throw UnimplementedError();
    }
  }

  static ThingCondition fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return fromJsonAgnostic(json);
  }

  static ThingCondition fromJson(Map<String, dynamic> json) {
    return fromJsonAgnostic(json);
  }

  ThingCondition get root {
    ThingCondition root = this;
    while (root?.parent != null) {
      root = root.parent;
    }
    return root;
  }

  void trimFromTree() {
    if (root == this) return;
    parent.operands.remove(this);
    this.parent = null;
  }

  ThingCondition copy();

  ThingCondition clean();
}
