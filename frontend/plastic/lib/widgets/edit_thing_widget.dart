import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/backend_service.dart';
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
          onChanged: (value) => widget.thing.fields
              .singleWhere((f) => f.name == field.name)
              .value = value,
        );
        break;
      case FieldType.INT:
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          onChanged: (value) => widget.thing.fields
              .singleWhere((f) => f.name == field.name)
              .value = int.parse(value),
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
          onChanged: (value) => widget.thing.fields
              .singleWhere((f) => f.name == field.name)
              .value = double.parse(value),
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
    return Text("couldn't figure out what type of field this is.");
  }

  List<Widget> _getChildren(context) {
    List<Widget> children =
        widget.thing.fields.map((field) => _getFieldWidget(field)).toList();
    children.add(
      BorderButton(
        color: Style.primary,
        onPressed: () =>
            BackendService.saveThing(widget.thing).then((response) {
          if (response.statusCode == 201) {
            Navigator.pop(context);
            Navigator.pop(context);
            String message;
            if (widget.thing.id == null) {
              message = 'your new ${widget.template.name} has been created.';
            } else {
              message = 'your ${widget.template.name} has been updated.';
            }
            Flushbar(
              title: 'saved',
              message: message,
              duration: Duration(seconds: 2),
            )..show(context);
          } else {
            Flushbar(
              title: 'oops!',
              message: response.reasonPhrase,
              duration: Duration(seconds: 2),
            )..show(context);
          }
        }),
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
