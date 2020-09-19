import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';

class ViewThingWidget extends StatelessWidget {
  final Thing thing;
  Template template;

  ViewThingWidget({Key key, this.thing}) : super(key: key) {
    template = TemplateManager().getTemplateById(thing.templateId);
  }

  Widget _getFieldWidget(ThingField field, FieldType type) {
    switch (type) {
      case FieldType.STRING:
        // TODO: Handle this case.
        break;
      case FieldType.INT:
        // TODO: Handle this case.
        break;
      case FieldType.DOUBLE:
        // TODO: Handle this case.
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        // TODO: Handle this case.
        break;
    }
    return Text("Invalid field!");
  }

  List<Widget> _getFields(context) {
    var fieldWidgets = new List<Widget>();
    for (var templateField in template.fields) {
      var thingField = thing.fields.singleWhere(
        (f) => f.name == templateField.name,
        orElse: () => null,
      );
      if (thingField == null) continue;
      fieldWidgets.add(_getFieldWidget(thingField, templateField.type));
    }
    return fieldWidgets;
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Style.background,
        child: ListView(
          children: _getFields(context),
        ),
      );
}
