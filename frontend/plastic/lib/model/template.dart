import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:plastic/model/template_change.dart';

enum FieldType { STRING, INT, DOUBLE, ENUM, BOOL, DATE }

class Template {
  List<TemplateField> fields;
  String id;
  String userId;
  String name;

  Template({
    @required this.fields,
    @required this.userId,
    this.id,
    this.name,
  });

  TemplateField getMainField() {
    return fields.singleWhere((element) => element.main == true,
        orElse: () => null);
  }

  Template.clone(Template original) {
    fields = List<TemplateField>();
    userId = original.userId;
    id = original.id;
    name = original.name;
    for (var originalField in original.fields) {
      List<String> choices = null;
      if (originalField.choices != null) {
        choices = List<String>();
        for (var c in originalField.choices) {
          choices.add(c);
        }
      }
      fields.add(TemplateField(
          name: originalField.name,
          type: originalField.type,
          main: originalField.main,
          defaultValue: originalField.defaultValue,
          choices: choices,
          id: originalField.id));
    }
  }

  static List<TemplateChange> diff(Template a, Template b) {
    var changes = List<TemplateChange>();
    if (a.name != b.name) {
      changes.add(
        TemplateChange(
          changeType: TemplateChangeType.TemplateNameChanged,
          fieldName: "name",
          oldValue: a.name,
          newValue: b.name,
        ),
      );
    }
    for (var aField in a.fields) {
      var matchingIndex =
          b.fields.indexWhere((bField) => aField.id == bField.id);
      if (matchingIndex != -1) {
        // field still exists in b
        var bField = b.fields[matchingIndex];
        if (aField.name != bField.name) {
          changes.add(TemplateChange(
            changeType: TemplateChangeType.NameChanged,
            fieldName: "main",
            fieldId: aField.id,
            oldValue: aField.name,
            newValue: bField.name,
          ));
        }
        if (aField.main != bField.main) {
          changes.add(TemplateChange(
              changeType: TemplateChangeType.MainFieldChanged,
              fieldId: b.getMainField().id,
              fieldName: b.getMainField().name,
              oldValue: a.getMainField().name,
              newValue: b.getMainField().name));
        }
        if (aField.defaultValue != bField.defaultValue) {
          changes.add(TemplateChange(
            changeType: TemplateChangeType.DefaultValueChanged,
            fieldId: aField.id,
            fieldName: bField.name,
            oldValue: aField.defaultValue,
            newValue: bField.defaultValue,
          ));
        }
        if (aField.type != bField.type) {
          changes.add(TemplateChange(
            changeType: TemplateChangeType.TypeChanged,
            fieldId: aField.id,
            oldValue: aField.type,
            newValue: bField.type,
          ));
        }
        if (aField.choices != null && bField.choices != null) {
          if (aField.choices.length != bField.choices.length) {
            changes.add(TemplateChange(
              changeType: TemplateChangeType.ChoicesChanged,
              fieldId: aField.id,
              fieldName: aField.name,
            ));
            for (var i = 0; i < aField.choices.length; i++) {
              if (aField.choices[i] != bField.choices[i]) {
                changes.add(TemplateChange(
                  changeType: TemplateChangeType.ChoicesChanged,
                  fieldId: aField.id,
                  fieldName: aField.name,
                ));
              }
            }
          }
        }
      } else {
        changes.add(TemplateChange(
            changeType: TemplateChangeType.Deleted,
            fieldId: aField.id,
            fieldName: aField.name,
            oldValue: aField));
      }
    }
    for (var bField in b.fields) {
      var matchingIndex =
          a.fields.indexWhere((aField) => bField.id == aField.id);
      if (matchingIndex == -1) {
        changes.add(TemplateChange(
            changeType: TemplateChangeType.Added,
            fieldId: bField.id,
            fieldName: bField.name,
            newValue: bField));
      }
    }
    return changes;
  }

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
    return jsonEncode(data);
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
  String id;
  bool main;
  dynamic defaultValue;
  List<String> choices;

  TemplateField(
      {this.name,
      this.type,
      this.id,
      this.defaultValue,
      this.main,
      this.choices});

  static String getFriendlyName(FieldType fieldType) {
    String friendlyName = "Field type not found!";
    switch (fieldType) {
      case FieldType.STRING:
        friendlyName = "Text";
        break;
      case FieldType.INT:
        friendlyName = "Whole number";
        break;
      case FieldType.DOUBLE:
        friendlyName = "Real number";
        break;
      case FieldType.ENUM:
        friendlyName = "List of choices";
        break;
      case FieldType.BOOL:
        friendlyName = "true / false";
        break;
      case FieldType.DATE:
        friendlyName = "Date";
        break;
    }
    return friendlyName;
  }

  static dynamic getDefaultDefaultValue(FieldType type) {
    switch (type) {
      case FieldType.STRING:
        return "";
      case FieldType.INT:
        return 0;
      case FieldType.DOUBLE:
        return 0.0;
      case FieldType.ENUM:
        return null;
      case FieldType.BOOL:
        return false;
      case FieldType.DATE:
        return null;
        break;
    }
  }

  TemplateField.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['_id'];
    main = json.containsKey('main') ? true : false;
    defaultValue = json.containsKey('default') ? json['default'] : null;
    if (json.containsKey('choices')) {
      choices = List();
      for (var value in json['choices']) {
        if (value is String) choices.add(value);
      }
    }

    type = FieldType.values.singleWhere(
        (ft) => ft.toString().split('.').last == json['fieldType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    if (id != null) data['_id'] = id;
    data['fieldType'] = type.toString().split('.').last;
    if (main == true) data['main'] = true;
    if (defaultValue != null) data['default'] = defaultValue;
    if (choices != null) data['choices'] = choices;

    return data;
  }
}
