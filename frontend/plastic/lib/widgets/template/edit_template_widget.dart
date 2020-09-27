import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/widgets/components/checkbox_field.dart';
import 'package:plastic/widgets/components/double_field.dart';
import 'package:plastic/widgets/components/int_field.dart';
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

  Map<TemplateField, TextEditingController> _fieldDefaultValueControllers;
  Map<TemplateField, FocusNode> _fieldDefaultValueNodes;

  Map<TemplateField, Key> fieldKeys;

  @override
  void initState() {
    _metadataControllers = Map();
    _fieldControllers = Map();
    _fieldNodes = Map();
    _fieldDefaultValueControllers = Map();
    _fieldDefaultValueNodes = Map();
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
    if (fieldType == FieldType.STRING && widget.template.getMainField() == null)
      newField.main = true;
    widget.template.fields.add(newField);
    setState(() {});
    Navigator.pop(context);
  }

  Widget _getFieldWidget(TemplateField field) {
    void buildControllers(bool includeDefaultValue) {
      //name objects
      if (_fieldControllers[field] != null) return;
      var controller = TextEditingController(text: field.name);
      _fieldControllers[field] = controller;
      fieldKeys[field] = UniqueKey();
      var node = FocusNode();
      _fieldNodes[field] = node;

      node.addListener(() {
        if (node.hasFocus) {
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length);
        }
      });

      // default value objects
      if (!includeDefaultValue) return;
      var defaultValuecontroller = TextEditingController(
          text:
              field.defaultValue == null ? "" : field.defaultValue.toString());
      _fieldDefaultValueControllers[field] = defaultValuecontroller;
      var defaultValueNode = FocusNode();
      _fieldDefaultValueNodes[field] = defaultValueNode;
      defaultValueNode.addListener(() {
        if (defaultValueNode.hasFocus) {
          defaultValuecontroller.selection = TextSelection(
              baseOffset: 0, extentOffset: defaultValuecontroller.text.length);
        } else {
          defaultValuecontroller.text = field.defaultValue.toString();
        }
      });
    }

    List<Widget> cardContents = List();

    switch (field.type) {
      case FieldType.STRING:
        buildControllers(true);
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
          StringField(
            controller: _fieldDefaultValueControllers[field],
            focusNode: _fieldDefaultValueNodes[field],
            label: "Default value",
            onChanged: (value) {
              setState(() {
                field.defaultValue = value;
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
        buildControllers(true);
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
        cardContents.add(IntField(
          controller: _fieldDefaultValueControllers[field],
          focusNode: _fieldDefaultValueNodes[field],
          label: "Default value",
          onChanged: (value) {
            setState(() {
              field.defaultValue = int.parse(value, onError: (value) => 0);
            });
          },
        ));
        break;
      case FieldType.DOUBLE:
        buildControllers(true);
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
        cardContents.add(DoubleField(
          controller: _fieldDefaultValueControllers[field],
          focusNode: _fieldDefaultValueNodes[field],
          label: "Default value",
          onChanged: (value) {
            setState(() {
              field.defaultValue = double.parse(value, (value) => 0);
            });
          },
        ));
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        buildControllers(false);
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
        cardContents.add(CheckboxField(
          onChanged: (value) {
            setState(() {
              field.defaultValue = value ?? false;
            });
          },
          label: "Default state",
          value: field.defaultValue ?? null,
        ));
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
        child: Stack(
          children: [
            SplashListTile(
              color: Style.accent,
              onTap: () => Flushbar(
                message: "Hold to rearrange fields",
                duration: Style.snackDuration,
              ).show(context),
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
            Positioned(
              top: 5,
              right: 0,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                ),
                color: Style.error,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      backgroundColor: Style.background,
                      title: Text(
                        "Are you sure you want to delete field \"${field.name}\"?",
                        style: Style.getStyle(FontRole.Display3, Style.primary),
                      ),
                      children: [
                        SimpleDialogOption(
                          child: Text(
                            "Delete",
                            style:
                                Style.getStyle(FontRole.Display3, Style.error),
                          ),
                          onPressed: () {
                            setState(() {
                              widget.template.fields.remove(field);
                              if (widget.template.getMainField() == null) {
                                var newMainField = widget.template.fields
                                    .firstWhere(
                                        (f) => f.type == FieldType.STRING,
                                        orElse: () => null);
                                if (newMainField != null)
                                  newMainField.main = true;
                              }
                              Navigator.pop(context);
                            });
                          },
                        ),
                        SimpleDialogOption(
                          child: Text(
                            "Cancel",
                            style:
                                Style.getStyle(FontRole.Display3, Style.accent),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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

  void handleApiResponse(Routes route, ApiResponse response) {
    if (route == Routes.saveTemplate) {
      if (response.successful) {
        Flushbar(
                messageText: Text(
                  "Template saved.",
                  style: Style.getStyle(FontRole.Tooltip, Style.accent),
                ),
                duration: Style.snackDuration)
            .show(context);
      } else {
        var affectedThings =
            (response as ApiPostResponse<List<Thing>>).postResult;
        if (affectedThings.length > 0) {
          _handleSaveRejection(affectedThings);
        } else {
          Flushbar(
                  messageText: Text(
                    response.message,
                    style: Style.getStyle(FontRole.Tooltip, Style.error),
                  ),
                  duration: Style.snackDuration)
              .show(context);
        }
      }
    }
  }

  _handleSaveRejection(List<Thing> affectedThings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Style.background,
        title: Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Text(
            "Updating ${widget.template.name} will affect ${affectedThings.length} thing${affectedThings.length == 0 ? '' : 's'}. Do you want to update update one at a time, or all at the same time?",
            style: Style.getStyle(FontRole.Content, Style.accent),
          ),
        ),
        children: [
          SimpleDialogOption(
            child: Text("Update each thing",
                style: Style.getStyle(FontRole.Display3, Style.primary)),
            onPressed: () {
              Navigator.pop(context);
              _reviewEachAffectedThing(affectedThings);
            },
          ),
          SimpleDialogOption(
            child: Text("All at the same time",
                style: Style.getStyle(FontRole.Display3, Style.primary)),
            onPressed: () {
              Navigator.pop(context);
              _updateAllThings(affectedThings);
            },
          ),
          SimpleDialogOption(
            child: Text("Back (don't save)",
                style: Style.getStyle(FontRole.Display3, Style.error)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _reviewEachAffectedThing(List<Thing> affectedThings) {}

  _updateAllThings(List<Thing> affectedThings) {}

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
                      Api.template.saveTemplate(widget.template, List()).then(
                          (response) =>
                              handleApiResponse(Routes.saveTemplate, response));
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
                          widget.template.id != null ? "Delete" : "Discard",
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
                              widget.template.id != null
                                  ? "Delete existing template?"
                                  : "Discard new template?",
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
                                widget.template.id != null
                                    ? "Delete ${widget.template.name} PERMANENTLY!"
                                    : "Confirm cancel",
                                style: Style.getStyle(
                                    FontRole.Display3, Style.error),
                              ),
                              onPressed: () {
                                if (widget.template.id != null) {
                                  Api.template.deleteTemplate(widget.template);
                                }
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
