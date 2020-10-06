import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/notification_utilities.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/checkbox_field.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/int_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/template/edit_template_page.dart';

class EditThingWidget extends StatefulWidget {
  final Template template;
  final Thing thing;

  EditThingWidget({this.template, this.thing}) : super();

  @override
  State<StatefulWidget> createState() => EditThingState(thing);
}

class EditThingState extends State<EditThingWidget> {
  Thing _originalThing;
  Thing _thing;
  Map<String, TextEditingController> fieldControllers;
  Map<String, FocusNode> fieldFocusNodes;

  EditThingState(Thing thing) {
    _thing = thing;
    _originalThing = Thing.clone(thing);
    fieldControllers = Map();
    fieldFocusNodes = Map();
  }

  Widget _getFieldWidget(ThingField field, FieldType type) {
    void buildControllers(String name) {
      if (fieldControllers[field.name] != null) return;
      var controller = TextEditingController(
          text: field.value == null ? "" : field.value.toString());
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
        return StringField(
          label: field.name,
          fillColor: Motif.lightBackground,
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          onChanged: (value) => setState(() {
            field.value = value;
          }),
        );
        break;
      case FieldType.INT:
        buildControllers(field.name);
        return IntField(
          label: field.name,
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          onChanged: (value) => setState(() {
            field.value = int.parse(value, onError: (value) => 0);
          }),
        );
        break;
      case FieldType.DOUBLE:
        buildControllers(field.name);
        return DoubleField(
          label: field.name,
          controller: fieldControllers[field.name],
          focusNode: fieldFocusNodes[field.name],
          onChanged: (value) => setState(() {
            field.value = double.parse(value, (value) => 0);
          }),
        );
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        return CheckboxField(
          label: field.name,
          onChanged: (value) => setState(() {
            field.value = value;
          }),
          value: field.value,
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
        color: Motif.neutral,
        onPressed: () =>
            Api.thing.saveThing(context, widget.thing).then((response) {
          if (response.successful) {
            Navigator.popUntil(context, ModalRoute.withName('home'));
            String message;
            if (!isExistingThing) {
              message = 'your new ${widget.template.name} has been created.';
            } else {
              message = 'your ${widget.template.name} has been updated.';
            }
            NotificationUtilities.notify(
              context,
              message: message,
            );
          } else {
            NotificationUtilities.notify(
              context,
              message: response.message,
              color: Motif.negative,
            );
          }
        }),
        content: doneString,
      ),
    );
    if (isExistingThing) {
      fieldWidgets.add(
        BorderButton(
          color: Motif.negative,
          onPressed: () =>
              Api.thing.deleteThing(context, widget.thing).then((response) {
            if (response.successful) {
              String message =
                  '${widget.thing.getMainField().value} has been deleted.';
              Navigator.popUntil(context, ModalRoute.withName('home'));
              NotificationUtilities.notify(
                context,
                message: message,
              );
            } else {
              NotificationUtilities.notify(
                context,
                message: response.message,
                color: Motif.negative,
              );
            }
          }),
          content: "Delete",
        ),
      );
    }

    fieldWidgets.add(
      BorderButton(
        color: Motif.neutral,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditTemplatePage(template: widget.template),
              ));
        },
        content: "Edit ${widget.template.name} template",
      ),
    );

    fieldWidgets.add(
      BorderButton(
        color: Motif.caution,
        onPressed: () {
          if (_originalThing.isDifferentFrom(widget.thing)) {
            showDialog(
              context: context,
              builder: (context) => ChoiceActionsDialog(
                message: "Are you sure you want to discard your changes?",
                choices: [
                  DialogTextChoice(
                      "Yes",
                      Motif.negative,
                      () => Navigator.popUntil(
                          context, ModalRoute.withName('home'))),
                  DialogTextChoice("No", Motif.black, () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            );
          } else {
            Navigator.popUntil(context, ModalRoute.withName('home'));
          }
        },
        content: cancelString,
      ),
    );
    return fieldWidgets;
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Motif.background,
        child: ListView(
          children: _getFields(context),
        ),
      );
}