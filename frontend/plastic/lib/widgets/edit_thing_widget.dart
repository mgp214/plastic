import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';

import 'border_button.dart';

class EditThingWidget extends StatefulWidget {
  final Template template;
  final Thing thing;

  EditThingWidget({this.template, this.thing}) : super();

  @override
  State<StatefulWidget> createState() => EditThingState();
}

class EditThingState extends State<EditThingWidget> {
  Widget _getFieldWidget(ThingField field) {
    switch (
        widget.template.fields.firstWhere((f) => f.name == field.name).type) {
      case FieldType.STRING:
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
        );
        break;
      case FieldType.INT:
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) =>
                int.tryParse(newValue.text) == null ? oldValue : newValue)
          ],
        );
        break;
      case FieldType.DOUBLE:
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) =>
                double.tryParse(newValue.text) == null ? oldValue : newValue)
          ],
        );
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        // TODO: Handle this case.
        break;
    }
  }

  List<Widget> _getChildren(context) {
    List<Widget> children =
        widget.thing.fields.map((field) => _getFieldWidget(field)).toList();
    children.add(
      BorderButton(
        color: Style.primary,
        onPressed: () => null,
        content: "Done",
      ),
    );
    children.add(
      BorderButton(
        color: Style.error,
        onPressed: () => Navigator.pop(context),
        content: "Cancel",
      ),
    );
    return children;
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Style.background,
      child: ListView(
        children: _getChildren(context),
      ));
}
