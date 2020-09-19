import 'dart:convert';

import 'package:plastic/utility/template_manager.dart';

class Thing {
  List<ThingField> fields;
  String id;
  String userId;
  String templateId;
  String name;
  int v;

  Thing({
    this.id,
    this.userId,
    this.templateId,
    this.name,
    this.fields,
    this.v,
  }) {
    if (fields == null) {
      fields = List<ThingField>();
      TemplateManager().getTemplateById(templateId).fields.forEach(
        (templateField) {
          fields.add(ThingField(
              name: templateField.name, value: templateField.defaultValue));
        },
      );
    }
  }

  ThingField getMainField() {
    var templateMainField = TemplateManager()
        .getTemplateById(templateId)
        .fields
        .singleWhere((element) => element.main);
    return fields.singleWhere(
      (element) => element.name == templateMainField.name,
      orElse: () => fields.first,
    );
  }

  Thing.fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    if (json['fields'] != null) {
      fields = new List<ThingField>();
      json['fields'].forEach((v) {
        fields.add(new ThingField.fromJson(v));
      });
    }
    id = json['_id'];
    userId = json['userId'];
    templateId = json['templateId'];
    name = json['name'];
    v = json['__v'];
  }

  Thing.fromJsonMap(Map<String, dynamic> jsonMap) {
    if (jsonMap['fields'] != null) {
      fields = new List<ThingField>();
      jsonMap['fields'].forEach((v) {
        fields.add(new ThingField.fromJson(v));
      });
    }
    id = jsonMap['_id'];
    userId = jsonMap['userId'];
    templateId = jsonMap['templateId'];
    name = jsonMap['name'];
    v = jsonMap['__v'];
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.id;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['templateId'] = this.templateId;
    data['__v'] = this.v;
    return jsonEncode(data);
  }
}

class ThingField {
  String name;
  dynamic value;

  ThingField({this.name, this.value});

  ThingField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['value'] = value;

    return data;
  }
}
