import 'package:flutter/material.dart';

enum FieldType {
  STRING,
  INT,
  DOUBLE,
  ENUM,
  BOOL,
}

class Template {
  List<TemplateField> fields;
  String id;
  String userId;
  String name;
  int v;

  Template(
      {@required this.fields,
      @required this.id,
      @required this.userId,
      @required this.name,
      @required this.v});

  Template.fromJson(Map<String, dynamic> json) {
    if (json['fields'] != null) {
      fields = new List<TemplateField>();
      json['fields'].forEach((v) {
        fields.add(new TemplateField.fromJson(v));
      });
    }
    id = json['_id'];
    userId = json['userId'];
    name = json['name'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.id;
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['__v'] = this.v;
    return data;
  }

  List<TemplateField> getFieldsByPartial(String partial) => fields
      .where(
        (t) => t.name.toLowerCase().indexOf(partial.toLowerCase()) != -1,
      )
      .toList();
}

class TemplateField {
  String name;
  FieldType type;
  bool main;
  dynamic defaultValue;

  TemplateField({this.name, this.type});

  TemplateField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    main = json.containsKey('main') ? true : false;
    defaultValue = json.containsKey('default') ? json['default'] : null;

    type = FieldType.values.singleWhere(
        (ft) => ft.toString().split('.').last == json['fieldType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['fieldType'] = type.toString();
    if (main) data['main'] = true;
    if (defaultValue != null) data['default'] = defaultValue;

    return data;
  }
}
