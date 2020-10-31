import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/template_condition.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/components/dialogs/choice_actions_dialog.dart';
import 'package:plastic/widgets/components/dialogs/dialog_choice.dart';
import 'package:plastic/widgets/components/input/checkbox_field.dart';

class ThingConditionWidget extends StatefulWidget {
  final ThingCondition condition;

  const ThingConditionWidget({Key key, @required this.condition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ThingConditionWidgetState();

  // TODO: replace this old json thingCondition editor
  // TextField(
  //   controller: _controller,
  //   onChanged: (newValue) {
  //     try {
  //       var newCondition = ThingCondition.fromJsonString(newValue);
  //       if (newCondition != null) {
  //         widget.conditionUpdate(newCondition);
  //       }
  //     } catch (error) {
  //       // widget.condition = null;
  //     }
  //     widget.rebuildView(false);
  //   },
  // );
}

class ThingConditionWidgetState extends State<ThingConditionWidget> {
  Map<String, ThingCondition> _availableConditions = {
    "Group (all / any / none)":
        ConditionOperator(operation: OPERATOR.AND, operands: []),
    "Template": TemplateCondition(templates: List()),
  };

  List<DialogTextChoice> _getConditionChoices(ConditionOperator parent) {
    return _availableConditions.entries
        .map<DialogTextChoice>(
            (entry) => DialogTextChoice(entry.key, Motif.black, () {
                  setState(() {
                    parent.operands.add(entry.value);
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
                builder: (context) => getWidgetPicker(widget.condition));
          }
          if (data is ThingCondition) {
            setState(() {
              (widget.condition as ConditionOperator).operands.add(data);
            });
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
    } else {
      if (widget.condition is TemplateCondition) {
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

        return Column(
          children: children,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: Draggable(
          child: _getDraggable(),
          feedback: _getDraggable(),
        ),
      );
}
