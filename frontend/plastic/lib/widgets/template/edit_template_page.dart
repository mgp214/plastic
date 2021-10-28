import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:objectid/objectid.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/api/api_response.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/utility/notifier.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/dialogs/scrolling_alert_dialog.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/components/template_fields/field_card.dart';
import 'package:plastic/widgets/components/template_fields/template_bool_field.dart';
import 'package:plastic/widgets/components/template_fields/template_double_field.dart';
import 'package:plastic/widgets/components/template_fields/template_enum_field.dart';
import 'package:plastic/widgets/components/template_fields/template_field.dart';
import 'package:plastic/widgets/components/template_fields/template_int_field.dart';
import 'package:plastic/widgets/components/template_fields/template_string_field.dart';
import 'package:plastic/widgets/thing/bulk_update_things.dart';

class EditTemplatePage extends StatefulWidget {
  final Template template;
  EditTemplatePage({this.template}) : super();

  @override
  State<StatefulWidget> createState() => EditTemplatePageState();
}

class EditTemplatePageState extends State<EditTemplatePage> {
  Map<String, TextEditingController> _metadataControllers;
  Map<String, FocusNode> _metadataNodes;
  Map<String, Key> _metadataKeys;

  Map<TemplateField, Key> fieldKeys;

  Template _originalTemplate;

  @override
  void initState() {
    _metadataControllers = Map();
    _metadataNodes = Map();
    _metadataKeys = Map();
    fieldKeys = Map();
    _originalTemplate = Template.clone(widget.template);
    super.initState();
  }

  Widget _getAddFieldOptions() {
    var options = List<Widget>();

    options = FieldType.values
        .map(
          (fieldType) => SplashListTile(
            color: Motif.title,
            onTap: () => _createNewField(fieldType),
            child: Text(
              TemplateField.getFriendlyName(fieldType),
              style: Motif.actionStyle(Sizes.Action, Motif.black),
            ),
          ),
        )
        .toList();

    options.add(
      SplashListTile(
        color: Motif.negative,
        onTap: () => Navigator.pop(context),
        child: Text(
          "Cancel",
          style: Motif.actionStyle(Sizes.Action, Motif.negative),
        ),
      ),
    );

    return Material(
      color: Motif.lightBackground,
      child: ListView(
        children: options,
      ),
    );
  }

  void _onAddNewFieldPressed() {
    Navigator.pop(context);
    showModalBottomSheet(
        context: context, builder: (context) => _getAddFieldOptions());
  }

  void _createNewField(FieldType fieldType) {
    var newField = TemplateField(
        name: 'new ${TemplateField.getFriendlyName(fieldType)} field',
        type: fieldType,
        defaultValue: TemplateField.getDefaultDefaultValue(fieldType),
        id: ObjectId().hexString);
    if (fieldType == FieldType.STRING && widget.template.getMainField() == null)
      newField.main = true;
    if (fieldType == FieldType.ENUM && newField.choices == null)
      newField.choices = List();
    widget.template.fields.add(newField);
    setState(() {});
    Navigator.pop(context);
  }

  Widget _getFieldWidget(TemplateField field) {
    TemplateFieldWidget fieldWidget;
    switch (field.type) {
      case FieldType.STRING:
        fieldWidget = TemplateStringField(
          field: field,
          template: widget.template,
          onMainFieldChanged: (TemplateField field) {
            setState(() {
              widget.template.getMainField().main = false;
              field.main = true;
            });
          },
        );
        break;
      case FieldType.INT:
        fieldWidget = TemplateIntField(
          field: field,
          template: widget.template,
        );
        break;
      case FieldType.DOUBLE:
        fieldWidget = TemplateDoubleField(
          field: field,
          template: widget.template,
        );
        break;
      case FieldType.ENUM:
        fieldWidget = TemplateEnumField(
          field: field,
          template: widget.template,
        );
        break;
      case FieldType.BOOL:
        fieldWidget = TemplateBoolField(
          field: field,
          template: widget.template,
        );
        break;
    }
    if (!fieldKeys.containsKey(field)) fieldKeys[field] = UniqueKey();
    return FieldCard(
        key: fieldKeys[field],
        fieldWidget: fieldWidget,
        template: widget.template,
        onDelete: () => setState(() {
              widget.template.fields.remove(field);
              if (widget.template.getMainField() == null) {
                var newMainField = widget.template.fields.firstWhere(
                    (f) => f.type == FieldType.STRING,
                    orElse: () => null);
                if (newMainField != null) newMainField.main = true;
              }
            }));
  }

  Widget _getReorderableFieldWidget() => Expanded(
        child: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            var field = widget.template.fields[oldIndex];
            newIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
            setState(() {
              widget.template.fields.removeAt(oldIndex);
              widget.template.fields.insert(newIndex, field);
            });
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
      fillColor: Motif.background,
      label: "Template name",
      onChanged: (value) => setState(() {
        widget.template.name = value;
      }),
    );
  }

  void handleApiResponse(Routes route, ApiResponse response) {
    if (route == Routes.saveTemplate) {
      if (response.successful) {
        TemplateManager().needsToReload = true;
        Navigator.pop(context);
        Notifier.notify(
          context,
          message: "Template saved.",
          color: Motif.black,
        );
      } else {
        var affectedThings =
            (response as ApiPostResponse<List<Thing>>).postResult;
        if (affectedThings.length > 0) {
          _handleSaveRejection(affectedThings);
        } else {
          Notifier.notify(
            context,
            message: response.message,
            color: Motif.negative,
          );
        }
      }
    }
  }

  _handleSaveRejection(List<Thing> affectedThings) {
    showDialog(
      context: context,
      builder: (context) => ChoiceActionsDialog(
        message:
            "Updating ${widget.template.name} will affect ${affectedThings.length} thing${affectedThings.length == 0 ? '' : 's'}. Do you want to update update one at a time, or all at the same time?",
        choices: [
          DialogTextChoice("Update each thing", Motif.lightBackground, null),
          DialogTextChoice("All at the same time", Motif.black, () {
            Navigator.pop(context);
            _updateAllThings(affectedThings);
          }),
          DialogTextChoice("Back (don't save)", Motif.negative, () {
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  // _reviewEachAffectedThing(List<Thing> affectedThings) {}

  _updateAllThings(List<Thing> affectedThings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BulkUpdateThings(
          affectedThings: affectedThings,
          newTemplate: widget.template,
          oldTemplate: _originalTemplate,
        ),
      ),
    );
  }

  void _saveTemplatePressed() {
    Api.template
        .saveTemplate(context, widget.template, List())
        .then((response) {
          Navigator.pop(context);
          handleApiResponse(Routes.saveTemplate, response);
        })
        .catchError((e) => Notifier.handleApiError(context, e),
            test: (e) => e is ApiException)
        .catchError((e) {
          showDialog(
            context: context,
            builder: (context) => ScrollingAlertDialog(
              headerColor: Motif.negative,
              header: "There are problems with this template",
              okColor: Motif.black,
              children: e.errors
                  .map<Widget>(
                    (e) => ListTile(
                      title: Text(e,
                          style:
                              Motif.contentStyle(Sizes.Content, Motif.black)),
                    ),
                  )
                  .toList(),
            ),
          ).then((val) => Navigator.pop(context));
        });
  }

  void _deleteTemplatePressed() {
    var templateAlreadyExists =
        TemplateManager().doesTemplateExist(widget.template.id);
    showDialog(
      context: context,
      builder: (context) => ChoiceActionsDialog(
        message: templateAlreadyExists
            ? "Delete existing template?"
            : "Discard new template?",
        choices: [
          DialogTextChoice(
              "Stay here", Motif.black, () => Navigator.pop(context)),
          DialogTextChoice(
              templateAlreadyExists
                  ? "Delete ${widget.template.name} PERMANENTLY!"
                  : "Confirm cancel",
              Motif.negative, () {
            if (templateAlreadyExists) {
              Api.template
                  .deleteTemplate(context, widget.template)
                  .then((value) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                if (value.successful) {
                  Notifier.notify(
                    context,
                    message:
                        "Template ${widget.template.name} deleted successfully, along with all its things.",
                  );
                } else {
                  Notifier.notify(
                    context,
                    message: value.message,
                    color: Motif.negative,
                  );
                }
              });
            } else {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            }
          }),
        ],
      ),
    );
  }

  Future<bool> _onTryPop() {
    if (Template.diff(_originalTemplate, widget.template).length == 0)
      return Future.value(true);
    return showDialog(
        context: context,
        builder: (context) => ChoiceActionsDialog(
              message: "Are you sure you want to discard your changes?",
              choices: [
                DialogTextChoice("Yes", Motif.negative, () {
                  Navigator.pop(context, true);
                }),
                DialogTextChoice("Stay here", Motif.black, () {
                  Navigator.pop(context, false);
                }),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        child: Scaffold(
          backgroundColor: Motif.background,
          floatingActionButton: FloatingActionButton(
            shape: CircleBorder(side: BorderSide(color: Motif.title, width: 3)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Icon(
              Icons.menu,
              color: Motif.title,
              size: Constants.iconSize,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ChoiceActionsDialog(
                  message: null,
                  choices: [
                    DialogTextIconChoice("Add a new field", Icons.add,
                        Motif.black, () => _onAddNewFieldPressed()),
                    DialogTextIconChoice("Save template", Icons.save,
                        Motif.black, () => _saveTemplatePressed()),
                    DialogTextIconChoice(
                        TemplateManager().doesTemplateExist(widget.template.id)
                            ? "Delete"
                            : "Discard",
                        Icons.cancel,
                        Motif.negative,
                        () => _deleteTemplatePressed()),
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
        ),
        onWillPop: () => _onTryPop(),
      );
}
