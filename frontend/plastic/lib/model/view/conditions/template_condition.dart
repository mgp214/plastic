import 'dart:convert';

import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class TemplateCondition extends ThingCondition {
  Template template;
  @override
  String toJson() {
    Map<String, dynamic> map = Map();
    map['type'] = template;
    map['value'] = template.id;
    return jsonEncode(map);
  }
}
