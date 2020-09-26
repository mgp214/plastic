import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/border_button.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';

class EditTemplateWidget extends StatefulWidget {
  final Template template;
  EditTemplateWidget({this.template}) : super();

  @override
  State<StatefulWidget> createState() => EditTemplateState();
}

class EditTemplateState extends State<EditTemplateWidget> {
  Map<String, TextEditingController> _metadataControllers;
  Map<TemplateField, TextEditingController> _fieldControllers;

  Map<TemplateField, Key> fieldKeys;

  @override
  void initState() {
    _metadataControllers = Map();
    _fieldControllers = Map();
    fieldKeys = Map();
    super.initState();
  }

  Widget _getAddFieldOptions(context) {
    var options = List<Widget>();

    options = FieldType.values
        .map(
          (fieldType) => SplashListTile(
            color: Style.accent,
            onTap: () => _createNewField(fieldType),
            child: Text(
              TemplateField.getFriendlyName(fieldType),
              style: Style.getStyle(
                FontRole.Display3,
                Style.primary,
              ),
            ),
          ),
        )
        .toList();

    options.add(
      SplashListTile(
        color: Style.error,
        onTap: () => Navigator.pop(context),
        child: Text(
          "Cancel",
          style: Style.getStyle(FontRole.Display3, Style.error),
        ),
      ),
    );

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
    Widget cardContents = Text(
      "Unknown field type!",
      style: Style.getStyle(FontRole.Display3, Style.accent),
    );
    switch (field.type) {
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
    cardContents = Text(
      TemplateField.getFriendlyName(field.type),
      style: Style.getStyle(FontRole.Display3, Style.accent),
    );
    return Card(
      key: UniqueKey(),
      color: Style.inputField,
      child: SplashListTile(
          color: Style.accent,
          onTap: () => Flushbar(
                message: "Drag to rearrange fields",
                duration: Style.toastDuration,
              )..show(context),
          child: cardContents),
    );
  }

  List<Widget> _getChildren() {
    var children = List<Widget>();

    var node = FocusNode();
    TextEditingController controller;
    if (_metadataControllers.keys.contains('name')) {
      controller = _metadataControllers['name'];
    } else {
      controller = TextEditingController(text: widget.template.name);
      _metadataControllers['name'] = controller;
    }
    node.addListener(() {
      if (node.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });
    var templateNameField = TextField(
      focusNode: node,
      controller: controller,
      decoration: InputDecoration(
        labelText: "Template name",
        labelStyle: Style.getStyle(FontRole.Display3, Style.accent),
      ),
      style: Style.getStyle(FontRole.Display2, Style.primary),
      onChanged: (value) => setState(() {
        widget.template.name = value;
      }),
    );

    children.add(templateNameField);
    children.add(Divider(
      color: Style.accent,
    ));

    var fieldChildren = List<Widget>();

    for (var field in widget.template.fields) {
      fieldChildren.add(_getFieldWidget(field));
    }

    var reorderableListWidget = Container(
      height: MediaQuery.of(context).size.height - 350,
      child: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          var field = widget.template.fields[oldIndex];
          widget.template.fields.removeAt(oldIndex);
          widget.template.fields.insert(newIndex, field);
          setState(() {});
        },
        children: fieldChildren,
      ),
    );

    if (fieldChildren.length > 0) children.add(reorderableListWidget);

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
