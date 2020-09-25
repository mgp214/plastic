import 'package:flutter/material.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/border_button.dart';

class EditTemplateWidget extends StatefulWidget {
  final Template template;
  EditTemplateWidget({this.template}) : super();

  @override
  State<StatefulWidget> createState() => EditTemplateState();
}

class EditTemplateState extends State<EditTemplateWidget> {
  Widget _getAddFieldOptions(context) {
    var options = List<Widget>();

    options = FieldType.values
        .map(
          (fieldType) => InkWell(
            splashColor: Style.accent,
            onTap: () => _createNewField(fieldType),
            child: ListTile(
              title: Text(TemplateField.getFriendlyName(fieldType),
                  style: Style.getStyle(
                    FontRole.Display3,
                    Style.primary,
                  )),
            ),
          ),
        )
        .toList();

    options.add(InkWell(
      splashColor: Style.error,
      onTap: () => Navigator.pop(context),
      child: ListTile(
        title: Text(
          "Cancel",
          style: Style.getStyle(FontRole.Display3, Style.error),
        ),
      ),
    ));

    return Material(
      color: Style.background,
      child: ListView(
        children: options,
      ),
    );
  }

  void _onAddNewFieldPressed() {
    showModalBottomSheet(context: context, builder: _getAddFieldOptions);
  }

  void _createNewField(FieldType fieldType) {
    widget.template.fields.add(TemplateField(
        name: 'New ${TemplateField.getFriendlyName(fieldType)}',
        type: fieldType));
    setState(() {});
    Navigator.pop(context);
  }

  Widget _getFieldWidget(TemplateField field) {
    return Text(
      field.name,
      style: Style.getStyle(FontRole.Display3, Style.accent),
    );
  }

  List<Widget> _getChildren() {
    var children = List<Widget>();
    //TODO: build edit widgets for each field in template
    for (var field in widget.template.fields) {
      children.add(_getFieldWidget(field));
    }

    children.add(BorderButton(
      color: Style.accent,
      content: "Add a new field",
      onPressed: _onAddNewFieldPressed,
    ));

    children.add(BorderButton(
      color: Style.primary,
      content: "Save",
      onPressed: () => null,
    ));

    children.add(BorderButton(
      color: Style.error,
      content: "Cancel",
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            backgroundColor: Style.background,
            title: Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Text(
                "Discard new template?",
                style: Style.getStyle(FontRole.Display3, Style.accent),
              ),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Stay here",
                  style: Style.getStyle(FontRole.Display3, Style.primary),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              SimpleDialogOption(
                child: Text(
                  "Confirm cancel",
                  style: Style.getStyle(FontRole.Display3, Style.error),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    ));

    return children;
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Style.background,
        child: ListView(
          children: _getChildren(),
        ),
      );
}
