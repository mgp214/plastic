import 'dart:developer';

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
  State<StatefulWidget> createState() => ThingConditionWidgetState();
}

class ThingConditionWidgetState extends State<ThingConditionWidget> {
  ThingCondition _rootCopy;

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

  Widget _getDraggable() {
    if (widget.condition is ConditionOperator) {
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
    } else if (widget.condition is TemplateCondition) {
      var conditionAsTemplate = widget.condition as TemplateCondition;
      List<Widget> children = List();
      children.add(Text(
        "Template is one of the following:",
        style: Motif.contentStyle(Sizes.Content, Motif.black),
      ));

      for (var template in TemplateManager().getAllTemplates()) {
        log(template.name);
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
    } else if (widget.condition is ValueCondition) {
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
          }),
        ),
      );
      children.add(Text(
        " field that's value ",
        style: Motif.contentStyle(Sizes.Label, Motif.black),
      ));
      children.add(
        DropdownButton<ValueComparison>(
          value: conditionAsValue.comparison,
          items: ValueComparison.values
              .map(
                (o) => DropdownMenuItem(
                  child: Text(
                    ValueCondition.getFriendlyName(o),
                  ),
                  value: o,
                ),
              )
              .toList(),
          onChanged: (newValueComparison) => setState(() {
            conditionAsValue.comparison = newValueComparison;
          }),
        ),
      );
      children.add(
        StringField(
          controller: TextEditingController(text: conditionAsValue.value),
          onChanged: (newValue) {
            setState(() {
              conditionAsValue.value = newValue;
            });
          },
        ),
      );
      return Card(
        child: Wrap(
          children: children,
        ),
      );
    }

    return Placeholder();
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