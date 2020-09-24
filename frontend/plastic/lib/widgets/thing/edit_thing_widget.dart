import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';

import '../components/border_button.dart';

class EditThingWidget extends StatefulWidget {
  final Template template;
  final Thing thing;

  EditThingWidget({this.template, this.thing}) : super();

  @override
  State<StatefulWidget> createState() => EditThingState(thing);
}

class EditThingState extends State<EditThingWidget> {
  Thing _thing;
  Map<String, TextEditingController> fieldControllers;
  Map<String, FocusNode> fieldFocusNodes;

  EditThingState(Thing thing) {
    _thing = thing;
    fieldControllers = Map();
    fieldFocusNodes = Map();
  }

  Widget _getFieldWidget(ThingField field, FieldType type) {
    void buildControllers(String name) {
      if (fieldControllers[field.name] != null) return;
      var controller = TextEditingController(text: field.value);
      fieldControllers[field.name] = controller;

      var node = FocusNode();
      fieldFocusNodes[field.name] = node;
      node
        ..addListener(() {
          if (node.hasFocus) {
            controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.text.length);
          }
        });
    }

    switch (type) {
      case FieldType.STRING:
        buildControllers(field.name);
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          onChanged: (value) => setState(() {
            field.value = value;
          }),
        );
        break;
      case FieldType.INT:
        buildControllers(field.name);
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: false),
          onChanged: (value) => setState(() {
            field.value = int.parse(value, onError: (value) => 0);
          }),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length == 1 && newValue.text == '-')
                return newValue;
              if (newValue.text.length < oldValue.text.length) return newValue;
              return int.tryParse(newValue.text) == null ? oldValue : newValue;
            }),
          ],
        );
        break;
      case FieldType.DOUBLE:
        buildControllers(field.name);
        return TextField(
          decoration: InputDecoration(
            labelText: field.name,
            labelStyle: Style.getStyle(FontRole.Content, Style.accent),
          ),
          style: Style.getStyle(FontRole.Display2, Style.primary),
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          keyboardType:
              TextInputType.numberWithOptions(signed: true, decimal: true),
          onChanged: (value) => setState(() {
            field.value = double.parse(value, (value) => 0);
          }),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length == 1 && newValue.text == '-')
                return newValue;
              if (newValue.text.length == 1 && newValue.text == '.')
                return TextEditingValue(
                  text: "0.",
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: 2),
                  ),
                );
              if (newValue.text.length == 2 && newValue.text == '-.')
                return TextEditingValue(
                  text: "-0.",
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: 3),
                  ),
                );
              if (newValue.text.length < oldValue.text.length) return newValue;
              return double.tryParse(newValue.text) == null
                  ? oldValue
                  : newValue;
            }),
          ],
        );
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        return CheckboxListTile(
          title: Text(
            field.name,
            style: Style.getStyle(FontRole.Content, Style.accent),
          ),
          checkColor: Style.primary,
          onChanged: (value) => setState(() {
            field.value = value;
          }),
          value: field.value ?? false,
        );
        break;
    }
    return Text("couldn't figure out what type of field this is.");
  }

  List<Widget> _getFields(context) {
    var fieldWidgets = new List<Widget>();
    var template = TemplateManager().getTemplateById(widget.thing.templateId);
    if (template == null) return fieldWidgets;

    for (var templateField in template.fields) {
      var thingField = widget.thing.fields.singleWhere(
        (f) => f.name == templateField.name,
        orElse: () => null,
      );

      if (thingField == null) continue;
      fieldWidgets.add(_getFieldWidget(thingField, templateField.type));
    }

    var isExistingThing = widget.thing.id != null;

    var doneString = isExistingThing ? "Update" : "Create";
    var cancelString = isExistingThing ? "Back" : "Discard";

    fieldWidgets.add(
      BorderButton(
        color: Style.primary,
        onPressed: () => Api.thing.saveThing(_thing).then((response) {
          if (response.successful) {
            Navigator.popUntil(context, ModalRoute.withName('home'));
            String message;
            if (!isExistingThing) {
              message = 'your new ${widget.template.name} has been created.';
            } else {
              message = 'your ${widget.template.name} has been updated.';
            }
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: 'saved',
              message: message,
              duration: Duration(seconds: 2),
            )..show(context);
          } else {
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: 'oops!',
              message: response.message,
              duration: Duration(seconds: 2),
            )..show(context);
          }
        }),
        content: doneString,
      ),
    );
    if (isExistingThing) {
      fieldWidgets.add(
        BorderButton(
          color: Style.error,
          onPressed: () => Api.thing.deleteThing(_thing).then((response) {
            if (response.successful) {
              String message =
                  '${widget.thing.getMainField().value} has been deleted.';
              Navigator.popUntil(context, ModalRoute.withName('home'));
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                title: 'deleted',
                message: message,
                duration: Duration(seconds: 2),
              )..show(context);
            } else {
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                title: 'oops!',
                message: response.message,
                duration: Duration(seconds: 2),
              )..show(context);
            }
          }),
          content: "Delete",
        ),
      );
    }
    fieldWidgets.add(
      BorderButton(
        color: Style.accent,
        onPressed: () =>
            Navigator.popUntil(context, ModalRoute.withName('home')),
        content: cancelString,
      ),
    );
    return fieldWidgets;
  }

  @override
  Widget build(BuildContext context) => Material(
      color: Style.background,
      child: ListView(
        children: _getFields(context),
      ));
}
