import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/template.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/model/view/conditions/value_condition.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/checkbox_field.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/int_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';

class ThingConditionWidget extends StatefulWidget {
  final ThingCondition condition;
  final Function(bool) rebuildLayout;
  final Function(ThingCondition) resetLayout;

  const ThingConditionWidget(
      {Key key,
      @required this.condition,
      @required this.rebuildLayout,
      @required this.resetLayout})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ThingConditionWidgetState(condition);
}

class ThingConditionWidgetState extends State<ThingConditionWidget> {
  ThingCondition _rootCopy;
  TextEditingController _valueController;
  TextEditingController _nameController;

  ThingConditionWidgetState(ThingCondition condition) {
    if (condition is ValueCondition) {
      var vc = condition;
      _valueController = TextEditingController(text: vc.value);
      _nameController = TextEditingController(text: vc.fieldName);
    }
  }

  Map<String, ThingCondition> _availableConditions = {
    "Group (all / any / none)":
        ConditionOperator(operation: OPERATOR.AND, operands: []),
    "Template": TemplateCondition(templates: List()),
    "Value": ValueCondition(),
  };

  List<DialogTextChoice> _getConditionChoices(ConditionOperator parent) {
    return _availableConditions.entries
        .map<DialogTextChoice>(
            (entry) => DialogTextChoice(entry.key, Motif.black, () {
                  var newWidget = entry.value.copy();
                  newWidget.parent = parent;
                  setState(() {
                    parent.operands.add(newWidget);
                  });
                  Navigator.pop(context);
                }))
        .toList();
  }

  Widget getWidgetPicker(ConditionOperator parent) =>
      ChoiceActionsDialog(message: null, choices: _getConditionChoices(parent));

  List<Widget> _getFieldTypeComparisons(FieldType fieldType) {
    var comparisions = List<ValueComparison>();
    comparisions.add(ValueComparison.E);
    switch (fieldType) {
      case FieldType.STRING:
        comparisions.add(ValueComparison.STR_CONTAINS);
        continue numbers;
      numbers:
      case FieldType.INT:
      case FieldType.DOUBLE:
        comparisions.add(ValueComparison.LT);
        comparisions.add(ValueComparison.LTE);
        comparisions.add(ValueComparison.GT);
        comparisions.add(ValueComparison.GTE);
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        break;
    }

    return comparisions
        .map(
          (o) => DropdownMenuItem(
            child: Text(
              ValueCondition.getFriendlyName(o),
            ),
            value: o,
          ),
        )
        .toList();
  }

  Widget _getConditionOperatorDraggable() {
    var conditionAsOperator = widget.condition as ConditionOperator;
    var children = List<Widget>();
    for (var operand in conditionAsOperator.operands) {
      children.add(ThingConditionWidget(
        condition: operand,
        resetLayout: widget.resetLayout,
        rebuildLayout: widget.rebuildLayout,
      ));
    }
    if (children.length == 0)
      children.add(Text("no conditions yet",
          style: Motif.contentStyle(
            Sizes.Content,
            Motif.lightBackground,
          )));
    return DragTarget(
      onWillAccept: (data) => widget.condition is ConditionOperator,
      onAccept: (data) {
        if (data == null) {
          showDialog(
                  context: context,
                  builder: (context) => getWidgetPicker(widget.condition))
              .then((val) => widget.rebuildLayout(false));
        }
        if (data is ThingCondition) {
          (widget.condition as ConditionOperator).operands.add(data);
          data.parent?.operands?.remove(data);
          data.parent = widget.condition;
          widget.rebuildLayout(false);
        }
      },
      builder: (context, candidateList, rejectedData) {
        var contents = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: DropdownButton<OPERATOR>(
                value: conditionAsOperator.operation,
                items: OPERATOR.values
                    .map(
                      (o) => DropdownMenuItem(
                        child: Text(
                          ConditionOperator.getFriendlyString(o),
                        ),
                        value: o,
                      ),
                    )
                    .toList(),
                onChanged: (newOperator) => setState(() {
                  conditionAsOperator.operation = newOperator;
                }),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  VerticalDivider(
                    thickness: 3,
                    color: ConditionOperator.getColor(
                        conditionAsOperator.operation),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: children
                          .map((c) => Row(
                                children: [c],
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        BorderSide border;
        if (candidateList.length > 0)
          border = BorderSide(color: Colors.green, width: 4);
        else
          border = BorderSide(color: Colors.transparent, width: 4);
        return Container(
          decoration: BoxDecoration(
            border: Border(
                bottom: border, top: border, left: border, right: border),
          ),
          child: contents,
        );
      },
    );
  }

  Widget _getTemplateConditionDraggable() {
    var conditionAsTemplate = widget.condition as TemplateCondition;
    List<Widget> children = List();
    children.add(Text(
      "Template is one of the following:",
      style: Motif.contentStyle(Sizes.Content, Motif.black),
    ));

    for (var template in TemplateManager().getAllTemplates()) {
      children.add(CheckboxField(
        label: template.name,
        value: conditionAsTemplate.templates.contains(template),
        onChanged: (value) {
          if (value) {
            setState(() {
              conditionAsTemplate.templates.add(template);
            });
          } else {
            setState(() {
              conditionAsTemplate.templates
                  .removeWhere((t) => t.id == template.id);
            });
          }
        },
      ));
    }

    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  String _getFieldTypeDefaultValue(FieldType fieldType) {
    switch (fieldType) {
      case FieldType.STRING:
        return 'value';
        break;
      case FieldType.INT:
        return '0';
        break;
      case FieldType.DOUBLE:
        return '0.0';
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        return 'false';
        break;
    }
  }

  Widget _getValueConditionDraggable() {
    var conditionAsValue = widget.condition as ValueCondition;
    List<Widget> children = List();
    children.add(Text(
      "Has a ",
      style: Motif.contentStyle(Sizes.Label, Motif.black),
    ));
    children.add(
      DropdownButton<FieldType>(
        value: conditionAsValue.fieldType,
        items: FieldType.values
            .map(
              (o) => DropdownMenuItem(
                child: Text(
                  TemplateField.getFriendlyName(o),
                ),
                value: o,
              ),
            )
            .toList(),
        onChanged: (newFieldType) => setState(() {
          conditionAsValue.fieldType = newFieldType;
          conditionAsValue.value = _getFieldTypeDefaultValue(newFieldType);
          _valueController.text = _getFieldTypeDefaultValue(newFieldType);
        }),
      ),
    );
    children.add(Text(
      " field with name ",
      style: Motif.contentStyle(Sizes.Label, Motif.black),
    ));
    children.add(StringField(
      controller: _nameController,
      onChanged: (newValue) {
        setState(() {
          conditionAsValue.fieldName = newValue;
        });
      },
    ));
    children.add(Text(
      " with value ",
      style: Motif.contentStyle(Sizes.Label, Motif.black),
    ));
    children.add(
      DropdownButton<ValueComparison>(
        value: conditionAsValue.comparison,
        items: _getFieldTypeComparisons(conditionAsValue.fieldType),
        onChanged: (newValueComparison) => setState(() {
          conditionAsValue.comparison = newValueComparison;
        }),
      ),
    );
    switch (conditionAsValue.fieldType) {
      case FieldType.STRING:
        children.add(
          StringField(
            controller: _valueController,
            onChanged: (newValue) {
              setState(() {
                conditionAsValue.value = newValue;
              });
            },
          ),
        );
        break;
      case FieldType.INT:
        children.add(
          IntField(
            controller: _valueController,
            onChanged: (newValue) {
              setState(() {
                conditionAsValue.value = newValue;
              });
            },
          ),
        );
        break;
      case FieldType.DOUBLE:
        children.add(
          DoubleField(
            controller: _valueController,
            onChanged: (newValue) {
              setState(() {
                conditionAsValue.value = newValue;
              });
            },
          ),
        );
        break;
      case FieldType.ENUM:
        // TODO: Handle this case.
        break;
      case FieldType.BOOL:
        children.add(Checkbox(
            value: conditionAsValue.value == 'true',
            onChanged: (newValue) {
              setState(() {
                conditionAsValue.value = newValue ? 'true' : 'false';
              });
            }));
        break;
    }

    return IntrinsicHeight(
      child: Card(
        child: Wrap(
          children: children,
        ),
      ),
    );
  }

  Widget _getDraggable() {
    if (widget.condition is ConditionOperator) {
      return _getConditionOperatorDraggable();
    } else if (widget.condition is TemplateCondition) {
      return _getTemplateConditionDraggable();
    } else if (widget.condition is ValueCondition) {
      return _getValueConditionDraggable();
    }

    return Placeholder(
      color: Color.fromARGB(255, 255, 0, 0),
    );
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: Draggable(
          maxSimultaneousDrags: widget.condition.parent == null ? 0 : 1,
          child: _getDraggable(),
          feedback: Placeholder(
            fallbackHeight: 50,
            fallbackWidth: 50,
          ),
          dragAnchor: DragAnchor.child,
          feedbackOffset: Offset.zero,
          onDragStarted: () {
            _rootCopy = widget.condition.root.copy();
            widget.condition.trimFromTree();
            widget.rebuildLayout(true);
          },
          onDraggableCanceled: (v, o) {
            widget.resetLayout(_rootCopy);
          },
          data: widget.condition as dynamic,
        ),
      );
}
