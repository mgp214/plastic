import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/template_change.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/utility/notification_utilities.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/border_button.dart';

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
          case TemplateChangeType.TemplateNameChanged:
          case TemplateChangeType.MainFieldChanged:
            // No changes needed.
            break;
        }
      }
    }

    Api.template
        .saveTemplate(widget.newTemplate, widget.affectedThings)
        .then((response) {
      if (response.successful) {
        NotificationUtilities.notify(
          context,
          message: response.message,
        );
        Navigator.popUntil(context, ModalRoute.withName("home"));
      } else {
        Navigator.pop(context);
        NotificationUtilities.notify(
          context,
          message: response.message,
          color: Motif.negative,
        );
      }
    });
  }

  List<Widget> _getChangeWidgets() {
    var widgets = List<Widget>();

    widgets.add(Padding(
      padding: EdgeInsets.all(15),
      child: Text(
          "Reviewing bulk changes to ${widget.affectedThings.length} \"${widget.oldTemplate.name}\" thing${widget.affectedThings.length == 1 ? "" : "s"}",
          style: Motif.contentStyle(Sizes.Header, Motif.black)),
    ));

    Widget cardContents;
    var changedFieldNames = Map<String, String>();
    for (var change in changes) {
      if (change.changeType != TemplateChangeType.NameChanged) continue;
      changedFieldNames[change.newValue] =
          "\"${change.newValue}\" (previously \"${change.oldValue}\")";
      changedFieldNames[change.oldValue] =
          "\"${change.newValue}\" (previously \"${change.oldValue}\")";
    }
    for (var change in changes) {
      var affectedFieldName = changedFieldNames.containsKey(change.fieldName)
          ? changedFieldNames[change.fieldName]
          : "\"${change.fieldName}\"";

      switch (change.changeType) {
        case TemplateChangeType.Deleted:
          cardContents = Text(
            "Field $affectedFieldName was deleted, the field and value in each affected thing will be deleted.",
            style: Motif.contentStyle(Sizes.Label, Motif.black),
          );
          break;
        case TemplateChangeType.Added:
          cardContents = Text(
            "Field $affectedFieldName was created. Existing things will have this field set to the default value of " +
                "\"${(change.newValue as TemplateField).defaultValue}\".",
            style: Motif.contentStyle(Sizes.Label, Motif.black),
          );
          break;
        case TemplateChangeType.NameChanged:
          cardContents = Text(
            "Field \"${change.oldValue}\" had its name changed to \"${change.newValue}\". Values in this field will be unchanged.",
            style: Motif.contentStyle(Sizes.Label, Motif.black),
          );
          break;
        case TemplateChangeType.DefaultValueChanged:
          cardContents = Column(
            children: [
              Text(
                "Field $affectedFieldName had its default value changed from \"${change.oldValue}\" to \"${change.newValue}\"." +
                    " Do you want to replace the old value of things which currently have the default value with the new one?",
                style: Motif.contentStyle(Sizes.Label, Motif.black),
              ),
              RadioListTile(
                title: Text(
                  "Yes, replace \"${change.oldValue}\" with \"${change.newValue}\"",
                  style: Motif.actionStyle(Sizes.Action, Motif.black),
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
                  style: Motif.actionStyle(Sizes.Action, Motif.black),
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
        case TemplateChangeType.TemplateNameChanged:
          cardContents = Text(
            "Template had name changed from \"${change.oldValue}\" to \"${change.newValue}\".",
            style: Motif.contentStyle(Sizes.Label, Motif.black),
          );
          break;
        case TemplateChangeType.MainFieldChanged:
          cardContents = Text(
            "Template had its main field changed from \"${change.oldValue}\" to \"${change.newValue}\".",
            style: Motif.contentStyle(Sizes.Label, Motif.black),
          );
          break;
      }
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Card(
            color: Motif.lightBackground,
            child: Padding(
              padding: EdgeInsets.all(15),
              child: cardContents,
            ),
          ),
        ),
      );
    }

    widgets.add(BorderButton(
      color: Motif.black,
      content: "Done",
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => ChoiceActionsDialog(
                  message:
                      "Are you sure you want to apply these changes to all ${widget.oldTemplate.name} things?",
                  choices: [
                    DialogTextChoice("Yes", Motif.black, applyChanges),
                    DialogTextChoice("No", Motif.black, () {
                      Navigator.pop(context);
                    }),
                  ],
                ));
      },
    ));

    widgets.add(BorderButton(
      color: Motif.negative,
      content: "Back",
      onPressed: () => Navigator.pop(context),
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Motif.background,
        body: ListView(
          children: _getChangeWidgets(),
        ),
      );
}
