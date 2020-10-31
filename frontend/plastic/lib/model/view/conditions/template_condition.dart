import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/utility/template_manager.dart';

class TemplateCondition extends ThingCondition {
  final List<Template> templates;

  TemplateCondition({@required this.templates});

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = Map();
    map['type'] = "template";
    map['value'] = templates.map((t) => t.id).toList();
    return map;
  }

  @override
  static ThingCondition fromJson(Map<String, dynamic> json) =>
      TemplateCondition(
        templates: (json['value'] as List<String>)
            .map((t) => TemplateManager().getTemplateById(t))
            .toList(),
      );
}
