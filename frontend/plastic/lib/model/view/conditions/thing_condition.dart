import 'dart:convert';

import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';

abstract class ThingCondition {
  Map<String, dynamic> toJson();

  @override
  String toString() {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(this.toJson());
  }

  static ThingCondition fromJson(Map<String, dynamic> json) =>
      throw UnimplementedError();

  static ThingCondition fromJsonAgnostic(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'operation':
        return ConditionOperator.fromJson(json);
        break;
      case 'template':
        return TemplateCondition.fromJson(json);
        break;
      default:
        throw UnimplementedError();
    }
  }

  static ThingCondition fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return fromJsonAgnostic(json);
  }
}
