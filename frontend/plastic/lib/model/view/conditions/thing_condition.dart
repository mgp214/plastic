import 'dart:convert';

abstract class ThingCondition {
  String toJson();

  @override
  String toString() {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonDecode(this.toJson()));
  }
}
