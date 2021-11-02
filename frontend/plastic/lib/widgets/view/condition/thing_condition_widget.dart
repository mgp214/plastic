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
import 'package:plastic/widgets/view/condition/bool_field_condition.dart';
import 'package:plastic/widgets/view/condition/date_field_condition.dart';
import 'package:plastic/widgets/view/condition/double_field_condition.dart';
import 'package:plastic/widgets/view/condition/enum_field_condition.dart';
import 'package:plastic/widgets/view/condition/int_field_condition.dart';
import 'package:plastic/widgets/view/condition/string_field_condition.dart';

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

  ThingConditionWidgetState(ThingCondition condition) {
    if (condition is ValueCondition) {
      var vc = condition;
      vc.comparison = condition.comparison;
    }
  }

  Map<String, ThingCondition> _availableConditions = {
    "Date field": ValueCondition(fieldType: FieldType.DATE),
    "Group (all / any / none)":
        ConditionOperator(operation: OPERATOR.AND, operands: []),
    "Integer number field": ValueCondition(fieldType: FieldType.INT),
    "List of choices field": ValueCondition(fieldType: FieldType.ENUM),
    "Real number field": ValueCondition(fieldType: FieldType.DOUBLE),
    "String field": ValueCondition(fieldType: FieldType.STRING),
    "Template": TemplateCondition(templates: List()),
    "True/false field": ValueCondition(
        fieldType: FieldType.BOOL,
        comparison: ValueComparison.E,
        value: 'false'),
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
            Row(
              children: [
                Expanded(
                  child: Align(
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
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.menu,
                    color: Motif.black,
                  ),
                ),
              ],
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
          child: SingleChildScrollView(
            child: contents,
          ),
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
        return 'value';
        break;
      case FieldType.BOOL:
        return 'false';
        break;
      case FieldType.DATE:
        return null;
        break;
    }
    return null;
  }

  Widget _getValueConditionDraggable() {
    var conditionAsValue = widget.condition as ValueCondition;
    switch (conditionAsValue.fieldType) {
      case FieldType.STRING:
        return StringFieldCondition(condition: conditionAsValue);
        break;
      case FieldType.INT:
        return IntFieldCondition(condition: conditionAsValue);
        break;
      case FieldType.DOUBLE:
        return DoubleFieldCondition(condition: conditionAsValue);
        break;
      case FieldType.ENUM:
        return EnumFieldCondition(condition: conditionAsValue);
        break;
      case FieldType.BOOL:
        return BoolFieldCondition(condition: conditionAsValue);
        break;
      case FieldType.DATE:
        return DateFieldCondition(condition: conditionAsValue);
        break;
    }
    return Placeholder(
      fallbackHeight: 100,
      fallbackWidth: 100,
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
        child: LongPressDraggable(
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
