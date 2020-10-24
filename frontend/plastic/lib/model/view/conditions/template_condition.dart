import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/utility/template_manager.dart';

class TemplateCondition extends ThingCondition {
  final Template template;

  TemplateCondition({this.template});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['type'] = "template";
    map['value'] = template.id;
    return map;
  }

  @override
  static ThingCondition fromJson(Map<String, dynamic> json) =>
      TemplateCondition(
        template: TemplateManager().getTemplateById(json['value']),
      );
}
