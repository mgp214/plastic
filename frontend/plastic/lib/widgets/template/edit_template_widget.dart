import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/checkbox_field.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/components/string_field.dart';

class EditTemplateWidget extends StatefulWidget {
  final Template template;
  EditTemplateWidget({this.template}) : super();

  @override
  State<StatefulWidget> createState() => EditTemplateState();
}

class EditTemplateState extends State<EditTemplateWidget> {
  Map<String, TextEditingController> _metadataControllers;
  Map<String, FocusNode> _metadataNodes;
  Map<String, Key> _metadataKeys;
  Map<TemplateField, TextEditingController> _fieldControllers;
  Map<TemplateField, FocusNode> _fieldNodes;

  Map<TemplateField, Key> fieldKeys;

  @override
  void initState() {
    _metadataControllers = Map();
    _fieldControllers = Map();
    _fieldNodes = Map();
    _metadataNodes = Map();
    _metadataKeys = Map();
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
    var newField = TemplateField(
        name: 'new ${TemplateField.getFriendlyName(fieldType)} field',
        type: fieldType);
    if (fieldType == FieldType.STRING &&
        widget.template.fields
                .firstWhere((f) => f.main == true, orElse: () => null) ==
            null) newField.main = true;
    widget.template.fields.add(newField);
    setState(() {});
    Navigator.pop(context);
  }

  Widget _getFieldWidget(TemplateField field) {
    void buildControllers() {
      if (_fieldControllers[field] != null) return;
      var controller = TextEditingController(text: field.name);
      _fieldControllers[field] = controller;
      fieldKeys[field] = UniqueKey();

      var node = FocusNode();
      _fieldNodes[field] = node;
      node
        ..addListener(() {
          if (node.hasFocus) {
            controller.selection = TextSelection(
                baseOffset: 0, extentOffset: controller.text.length);
          }
        });
    }

    List<Widget> cardContents = List();

    //TODO: default values
    switch (field.type) {
      case FieldType.STRING:
        buildControllers();
        cardContents.add(
          StringField(
            controller: _fieldControllers[field],
            focusNode: _fieldNodes[field],
            label: "Field name",
            onChanged: (value) {
              setState(() {
                field.name = value;
              });
            },
          ),
        );
        cardContents.add(
          RadioListTile(
            title: Text(
              "Main template field",
              style: Style.getStyle(FontRole.Display3, Style.accent),
            ),
            activeColor: Style.primary,
            groupValue: widget.template.getMainField(),
            onChanged: (value) => setState(() {
              widget.template.getMainField().main = false;
              field.main = true;
            }),
            value: field,
          ),
        );
        break;
      case FieldType.INT:
        buildControllers();
        cardContents.add(
          StringField(
            controller: _fieldControllers[field],
            focusNode: _fieldNodes[field],
            label: "Field name",
            onChanged: (value) {
              setState(() {
                field.name = value;
              });
            },
          ),
        );
        break;
      case FieldType.DOUBLE:
        buildControllers();
        cardContents.add(
          StringField(
            controller: _fieldControllers[field],
            focusNode: _fieldNodes[field],
            label: "Field name",
            onChanged: (value) {
              setState(() {
                field.name = value;
              });
            },
          ),
        );
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        buildControllers();
        cardContents.add(
          StringField(
            controller: _fieldControllers[field],
            focusNode: _fieldNodes[field],
            label: "Field name",
            onChanged: (value) {
              setState(() {
                field.name = value;
              });
            },
          ),
        );
        break;
      default:
        cardContents.add(Text(
          "Unknown field type!",
          style: Style.getStyle(FontRole.Display3, Style.accent),
        ));
    }
    return IntrinsicHeight(
      key: fieldKeys[field],
      child: Card(
        color: Style.inputField,
        child: SplashListTile(
          color: Style.accent,
          onTap: () => Flushbar(
            message: "Drag to rearrange fields",
            duration: Style.snackDuration,
          )..show(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        children: cardContents,
                      ),
                    ),
                    VerticalDivider(
                      width: 15,
                      thickness: 1,
                      color: Style.background,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Icon(
                      Icons.reorder,
                      color: Style.background,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getReorderableFieldWidget() => Expanded(
        child: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            var field = widget.template.fields[oldIndex];
            widget.template.fields.removeAt(oldIndex);
            widget.template.fields.insert(newIndex, field);
            setState(() {});
          },
          children:
              widget.template.fields.map((f) => _getFieldWidget(f)).toList(),
        ),
      );

  Widget _getTemplateNameField() {
    FocusNode node;
    TextEditingController controller;
    Key key;
    if (_metadataControllers.keys.contains('name')) {
      controller = _metadataControllers['name'];
      node = _metadataNodes['name'];
      key = _metadataKeys['name'];
    } else {
      controller = TextEditingController(text: widget.template.name);
      node = FocusNode();
      key = UniqueKey();
      _metadataControllers['name'] = controller;
      _metadataNodes['name'] = node;
      _metadataKeys['name'] = key;
    }
    node.addListener(() {
      if (node.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });
    return StringField(
      controller: controller,
      focusNode: node,
      label: "Template name",
      onChanged: (value) => setState(() {
        widget.template.name = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Style.background,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(side: BorderSide(color: Style.primary, width: 3)),
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.menu,
            color: Style.primary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                backgroundColor: Style.background,
                children: [
                  SimpleDialogOption(
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Style.primary,
                        ),
                        Text("Add a new field",
                            style: Style.getStyle(
                                FontRole.Display3, Style.primary)),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _onAddNewFieldPressed();
                    },
                  ),
                  SimpleDialogOption(
                    child: Row(
                      children: [
                        Icon(
                          Icons.save,
                          color: Style.primary,
                        ),
                        Text("Save template",
                            style: Style.getStyle(
                                FontRole.Display3, Style.primary)),
                      ],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SimpleDialogOption(
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Style.error,
                        ),
                        Text(
                          "Discard",
                          style: Style.getStyle(FontRole.Display3, Style.error),
                        ),
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          backgroundColor: Style.background,
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Text(
                              "Discard new template?",
                              style: Style.getStyle(
                                  FontRole.Display3, Style.accent),
                            ),
                          ),
                          children: [
                            SimpleDialogOption(
                              child: Text(
                                "Stay here",
                                style: Style.getStyle(
                                    FontRole.Display3, Style.primary),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SimpleDialogOption(
                              child: Text(
                                "Confirm cancel",
                                style: Style.getStyle(
                                    FontRole.Display3, Style.error),
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
                  )
                ],
              ),
            );
          },
        ),
        body: Column(
          children: [
            _getTemplateNameField(),
            _getReorderableFieldWidget(),
          ],
        ),
      );
}
