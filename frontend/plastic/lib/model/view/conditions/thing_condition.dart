import 'dart:convert';

abstract class ThingCondition {
  Map<String, dynamic> toJson();

  @override
  String toString() {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(this.toJson());
  }
}
