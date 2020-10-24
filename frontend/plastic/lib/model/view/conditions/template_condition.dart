import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';

class TemplateCondition extends ThingCondition {
  final Template template;

  TemplateCondition(this.template);

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['type'] = "template";
    map['value'] = template.id;
    return map;
  }
}
