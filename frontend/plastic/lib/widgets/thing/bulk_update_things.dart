import 'dart:developer';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/template_change.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/border_button.dart';

class BulkUpdateThings extends StatefulWidget {
  final Template oldTemplate;
  final Template newTemplate;
  final List<Thing> affectedThings;

  const BulkUpdateThings(
      {Key key,
      @required this.oldTemplate,
      @required this.newTemplate,
      @required this.affectedThings})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BulkUpdateThingsState();
}

class BulkUpdateThingsState extends State<BulkUpdateThings> {
  Map<TemplateChange, dynamic> changeAnswers = Map();
  List<TemplateChange> changes;

  @override
  void initState() {
    changes = Template.diff(widget.oldTemplate, widget.newTemplate);
    super.initState();
  }

  void applyChanges() {
    for (var thing in widget.affectedThings) {
      for (var change in changes) {
        var fieldIndex =
            thing.fields.indexWhere((field) => field.id == change.fieldId);
        var field = fieldIndex != -1 ? thing.fields[fieldIndex] : null;
        switch (change.changeType) {
          case TemplateChangeType.Deleted:
            thing.fields.removeAt(fieldIndex);
            break;
          case TemplateChangeType.Added:
            thing.fields.add(
              ThingField(
                id: change.fieldId,
                name: change.fieldName,
                value: (change.newValue as TemplateField).defaultValue,
              ),
            );
            break;
          case TemplateChangeType.NameChanged:
            field.name = change.newValue;
            break;
          case TemplateChangeType.DefaultValueChanged:
            if (changeAnswers[change] == true &&
                field.value == change.oldValue) {
              // replace existing default values
              field.value = change.newValue;
            }
            break;
          case TemplateChangeType.TypeChanged:
            // TODO: Handle this case.
            break;
        }
      }
    }

    Api.template
        .saveTemplate(widget.newTemplate, widget.affectedThings)
        .then((response) {
      if (response.successful) {
        Flushbar(
          messageText: Text(
            response.message,
            style: Style.getStyle(FontRole.Tooltip, Style.accent),
          ),
          duration: Style.snackDuration,
        ).show(context);
        Navigator.popUntil(context, ModalRoute.withName("home"));
      } else {
        Navigator.pop(context);
        Flushbar(
          messageText: Text(
            response.message,
            style: Style.getStyle(FontRole.Tooltip, Style.error),
          ),
          duration: Style.snackDuration,
        ).show(context);
      }
    });
  }

  List<Widget> _getChangeWidgets() {
    var widgets = List<Widget>();

    widgets.add(Padding(
      padding: EdgeInsets.all(15),
      child: Text(
          "Reviewing bulk changes to ${widget.affectedThings.length} \"${widget.oldTemplate.name}\" thing${widget.affectedThings.length == 1 ? "" : "s"}",
          style: Style.getStyle(FontRole.Display3, Style.accent)),
    ));

    Widget cardContents;
    for (var change in changes) {
      switch (change.changeType) {
        case TemplateChangeType.Deleted:
          cardContents = Text(
            "Field \"${(change.oldValue as TemplateField).name}\" was deleted, the field and value in each affected thing will be deleted.",
            style: Style.getStyle(FontRole.Display3, Style.primary),
          );
          break;
        case TemplateChangeType.Added:
          cardContents = Text(
            "Field \"${change.fieldName}\" was created. Existing things will have this field set to the default value of " +
                "\"${(change.newValue as TemplateField).defaultValue}\".",
            style: Style.getStyle(FontRole.Display3, Style.primary),
          );
          break;
        case TemplateChangeType.NameChanged:
          cardContents = Text(
            "Field \"${change.oldValue}\" had its name changed to \"${change.newValue}\". Values in this field will be unchanged.",
            style: Style.getStyle(FontRole.Display3, Style.primary),
          );
          break;
        case TemplateChangeType.DefaultValueChanged:
          cardContents = Column(
            children: [
              Text(
                "Field \"${change.fieldName}\" had its default value changed from \"${change.oldValue}\" to \"${change.newValue}\"." +
                    " Do you want to replace the old value of things which currently have the default value with the new one?",
                style: Style.getStyle(FontRole.Display3, Style.primary),
              ),
              RadioListTile(
                title: Text(
                  "Yes, replace \"${change.oldValue}\" with \"${change.newValue}\"",
                  style: Style.getStyle(FontRole.Display3, Style.accent),
                ),
                groupValue: changeAnswers[change] as bool,
                onChanged: (value) {
                  setState(() {
                    changeAnswers[change] = value;
                  });
                },
                value: true,
              ),
              RadioListTile(
                title: Text(
                  "No, leave the \"${change.oldValue}\" values in existing things.",
                  style: Style.getStyle(FontRole.Display3, Style.error),
                ),
                groupValue: changeAnswers[change] as bool,
                onChanged: (value) {
                  setState(() {
                    changeAnswers[change] = value;
                  });
                },
                value: false,
              ),
            ],
          );
          break;
        case TemplateChangeType.TypeChanged:
          // TODO: Handle this case.
          break;
      }
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Card(
            color: Style.inputField,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: cardContents,
            ),
          ),
        ),
      );
    }

    widgets.add(BorderButton(
      color: Style.primary,
      content: "Done",
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                  backgroundColor: Style.background,
                  title: Text(
                    "Are you sure you want to apply these changes to all ${widget.oldTemplate.name} things?",
                    style: Style.getStyle(FontRole.Display3, Style.accent),
                  ),
                  children: [
                    SimpleDialogOption(
                      child: Text(
                        "Yes",
                        style: Style.getStyle(FontRole.Display3, Style.primary),
                      ),
                      onPressed: applyChanges,
                    ),
                    SimpleDialogOption(
                      child: Text(
                        "No",
                        style: Style.getStyle(FontRole.Display3, Style.primary),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ));
      },
    ));

    widgets.add(BorderButton(
      color: Style.error,
      content: "Back",
      onPressed: () => Navigator.pop(context),
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Style.background,
      body: ListView(
        children: _getChangeWidgets(),
      ));
}
