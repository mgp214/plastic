import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

enum ValueComparison { LT, LTE, GT, GTE, E, STR_CONTAINS }

class ValueCondition extends ThingCondition {
  FieldType fieldType;
  String fieldName;
  ValueComparison comparison;
  String value;

  ValueCondition({this.fieldName, this.fieldType, this.comparison, this.value});

  @override
  ThingCondition clean() => isEmpty() ? null : this;

  @override
  ThingCondition copy() => ValueCondition(
        value: value,
        fieldName: fieldName,
        fieldType: fieldType,
        comparison: comparison,
      );

  @override
  bool isEmpty() =>
      fieldName == null || value == null || fieldName.isEmpty || value.isEmpty;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['type'] = "value";
    map['fieldName'] = fieldName;
    map['fieldType'] = fieldType.toString();
    map['comparison'] = comparison.toString();
    map['value'] = value;
    return map;
  }

  static ValueCondition fromJson(Map<String, dynamic> json) => ValueCondition(
        fieldName: json['fieldName'],
        fieldType: FieldType.values
            .firstWhere((x) => x.toString() == json['fieldType']),
        value: json['value'],
        comparison: ValueComparison.values.firstWhere(
            (x) => x.toString() == json['comparison'],
            orElse: () => ValueComparison.E),
      );

  static String getFriendlyName(ValueComparison comparison) {
    switch (comparison) {
      case ValueComparison.LT:
        return "is less than";
      case ValueComparison.LTE:
        return "is less than or equal to";
      case ValueComparison.GT:
        return "is greater than";
      case ValueComparison.GTE:
        return "is greater than or equal to";
      case ValueComparison.E:
        return "is equal to";
      case ValueComparison.STR_CONTAINS:
        return "contains";
    }
    return "error not found!";
  }
}
