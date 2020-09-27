import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/template_change.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';

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

  List<Widget> _getChangeWidgets() {
    var widgets = List<Widget>();

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

    return widgets;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Style.background,
      body: ListView(
        children: _getChangeWidgets(),
      ));
}
