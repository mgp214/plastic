import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/value_condition.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/view/condition/condition_card.dart';

class DateFieldCondition extends StatefulWidget {
  final ValueCondition condition;

  const DateFieldCondition({Key key, this.condition}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DateFieldConditionState();
}

class DateFieldConditionState extends State<DateFieldCondition> {
  String dateType;
  DateTime absoluteValue;
  double relativeValue;
  String relativeDirection;
  String relativeUnit;
  String calendarDirection;
  String calendarUnit;
  TextEditingController _valueController;
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController(text: '');
    _nameController = TextEditingController(text: '');
    if (widget.condition.value == null) return;
    dateType = widget.condition.value.substring(0, 1);
    _nameController.text = widget.condition.fieldName;

    switch (dateType) {
      case 'A':
        absoluteValue = DateTime.parse(widget.condition.value.substring(2));
        break;
      case 'R':
        relativeUnit = widget.condition.value[2];
        relativeValue =
            double.parse(widget.condition.value.split(' ')[1]).abs();
        relativeDirection = widget.condition.value.split(' ')[1][0];
        _valueController =
            TextEditingController(text: relativeValue.toString());
        break;
      case 'C':
        break;
    }
  }

  String _buildStringValue() {
    var tzMinutes = DateTime.now().timeZoneOffset.inMinutes.toString();
    switch (dateType) {
      case "A":
        return "A-" + absoluteValue.toIso8601String().substring(0, 10);
        break;
      case "R":
        return "R-" +
            "$relativeUnit $relativeDirection${relativeValue.toString()} $tzMinutes";
        break;
      case "C":
        return "C-" + calendarUnit + calendarDirection;
        break;
    }
    return 'error!';
  }

  void _getAbsoluteWidgets(List<Widget> children) {
    if (absoluteValue == null) {
      absoluteValue = DateTime.now();
    }
    var comparisons = List<ValueComparison>();
    comparisons.add(ValueComparison.E);
    comparisons.add(ValueComparison.LT);
    comparisons.add(ValueComparison.LTE);
    comparisons.add(ValueComparison.GT);
    comparisons.add(ValueComparison.GTE);
    var row = Row(
      children: [
        Text("comparison: "),
        DropdownButton<ValueComparison>(
          value: widget.condition.comparison,
          items: comparisons
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
            widget.condition.comparison = newValueComparison;
          }),
        ),
      ],
    );
    children.add(row);
    children.add(
      BorderButton(
        color: Motif.lightBackground,
        content: DateFormat('MMMM d, \'\'yy').format(absoluteValue),
        onPressed: () {
          showDatePicker(
                  context: context,
                  initialDate: absoluteValue ?? DateTime.now(),
                  firstDate: DateTime.tryParse('1950-01-01T00:00:00.000Z'),
                  lastDate: DateTime.tryParse('2050-01-01T00:00:00.000Z'))
              .then((value) {
            setState(() {
              absoluteValue = value;
            });
            widget.condition.value = _buildStringValue();
          });
        },
      ),
    );
  }

  void _getRelativeWidgets(List<Widget> children) {
    var row = Row(
      children: [
        Text("is in the "),
        DropdownButton<String>(
          value: relativeDirection,
          items: [
            DropdownMenuItem(child: Text("last"), value: "-"),
            DropdownMenuItem(child: Text("next"), value: "+"),
          ],
          onChanged: (value) {
            setState(() {
              relativeDirection = value;
            });
            widget.condition.value = _buildStringValue();
          },
        ),
        Container(
          width: 50,
          child: DoubleField(
            controller: _valueController,
            onChanged: (value) => setState(() {
              relativeValue = double.parse(
                value,
                (erroredValue) {
                  _valueController.text = relativeValue.toString();
                  return relativeValue;
                },
              ).abs();
              _valueController.text = relativeValue.toString();
              widget.condition.value = _buildStringValue();
            }),
          ),
        ),
        DropdownButton<String>(
          value: relativeUnit,
          items: [
            DropdownMenuItem(child: Text("days"), value: "d"),
            DropdownMenuItem(child: Text("weeks"), value: "w"),
            DropdownMenuItem(child: Text("months"), value: "M"),
            DropdownMenuItem(child: Text("years"), value: "y"),
          ],
          onChanged: (value) {
            setState(() {
              relativeUnit = value;
            });
            widget.condition.value = _buildStringValue();
          },
        ),
      ],
    );
    children.add(row);
  }

  void _getCalendarWidgets(List<Widget> children) {
    var row = Row(
      children: [
        Text("is in the "),
        DropdownButton<String>(
          value: calendarDirection,
          items: [
            DropdownMenuItem(child: Text("previous"), value: "-"),
            DropdownMenuItem(child: Text("current"), value: "="),
            DropdownMenuItem(child: Text("next"), value: "+"),
          ],
          onChanged: (value) {
            setState(() {
              calendarDirection = value;
            });
            widget.condition.value = _buildStringValue();
          },
        ),
        DropdownButton<String>(
          value: calendarUnit,
          items: [
            DropdownMenuItem(child: Text("day"), value: "d"),
            DropdownMenuItem(child: Text("week"), value: "w"),
            DropdownMenuItem(child: Text("month"), value: "m"),
            DropdownMenuItem(child: Text("year"), value: "y"),
          ],
          onChanged: (value) {
            setState(() {
              calendarUnit = value;
            });
            widget.condition.value = _buildStringValue();
          },
        ),
      ],
    );
    children.add(row);
  }

  @override
  Widget build(BuildContext context) {
    var children = List<Widget>();

    children.add(StringField(
      controller: _nameController,
      onChanged: (value) => setState(() {
        widget.condition.fieldName = value;
      }),
      label: 'Field name',
    ));

    var row = Row(
      children: [
        Text("Match type: "),
        DropdownButton<String>(
          value: dateType,
          items: [
            DropdownMenuItem(child: Text("Absolute"), value: "A"),
            DropdownMenuItem(child: Text("Relative"), value: "R"),
            DropdownMenuItem(child: Text("Calendar"), value: "C"),
          ],
          onChanged: (value) => setState(
            () {
              dateType = value;
            },
          ),
        ),
      ],
    );
    children.add(row);
    switch (dateType) {
      case "A":
        _getAbsoluteWidgets(children);
        break;
      case "R":
        _getRelativeWidgets(children);
        break;
      case "C":
        _getCalendarWidgets(children);
        break;
    }

    return ConditionCard(
      label: 'Date field',
      children: children,
    );
  }
}
