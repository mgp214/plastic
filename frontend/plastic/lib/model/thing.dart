import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/template_manager.dart';

class Thing {
  List<ThingField> fields;
  String id;
  String userId;
  String templateId;
  String name;

  Thing({
    this.id,
    this.userId,
    this.templateId,
    this.name,
    this.fields,
  }) {
    if (fields == null) {
      fields = List<ThingField>();
      TemplateManager().getTemplateById(templateId).fields.forEach(
        (templateField) {
          fields.add(
            ThingField(
              name: templateField.name,
              value: templateField.defaultValue,
              id: templateField.id,
              type: templateField.type,
            ),
          );
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

  Thing.clone(Thing original) {
    fields = List<ThingField>();
    userId = original.userId;
    templateId = original.templateId;
    id = original.id;
    name = original.name;
    for (var originalField in original.fields) {
      fields.add(ThingField(
        id: originalField.id,
        name: originalField.name,
        value: originalField.value,
        type: originalField.type,
      ));
    }
  }

  bool isDifferentFrom(Thing other) {
    if (name != other.name ||
        id != other.id ||
        templateId != other.templateId ||
        userId != other.userId) return true;
    for (var field in fields) {
      var otherField =
          other.fields.firstWhere((e) => e.id == field.id, orElse: () => null);
      if (otherField == null ||
          field.name != otherField.name ||
          field.value != otherField.value ||
          field.type != otherField.type) return true;
    }
    return false;
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
  }

  String toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fields != null) {
      data['fields'] = this.fields.map((v) => v.toJson()).toList();
    }
    if (this.id != null) {
      data['_id'] = this.id;
    }
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['templateId'] = this.templateId;
    return jsonEncode(data);
  }

  static String listToJson(List<Thing> things) {
    return jsonEncode(things);
  }
}

class ThingField {
  String name;
  String id;
  FieldType type;
  dynamic value;

  ThingField({this.name, this.value, this.id, @required this.type});

  ThingField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
    id = json['_id'];
    if (json.containsKey('fieldType'))
      type = FieldType.values.singleWhere(
          (ft) => ft.toString().split('.').last == json['fieldType']);
    if (type == FieldType.DATE)
      value = value == null ? null : DateTime.parse(value);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    if (value is DateTime) {
      data['value'] = (value as DateTime).toIso8601String().substring(0, 10);
    } else {
      data['value'] = value;
    }

    data['_id'] = id;
    data['fieldType'] = type.toString().split('.').last;
    return data;
  }
}
