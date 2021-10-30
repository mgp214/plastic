import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';

class DateConditionWidget extends StatefulWidget {
  final Function(String) onChanged;

  const DateConditionWidget({Key key, this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DateConditionWidgetState();
}

class DateConditionWidgetState extends State<DateConditionWidget> {
  String dateType;
  DateTime absoluteValue;
  double relativeValue;
  String relativeDirection;
  String relativeUnit;
  String calendarDirection;
  String calendarUnit;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  String _buildStringValue() {
    switch (dateType) {
      case "A":
        return "A-" + absoluteValue.toIso8601String().substring(0, 10);
        break;
      case "R":
        return "R-" +
            relativeUnit +
            " " +
            relativeDirection +
            relativeValue.toString();
        break;
      case "C":
        return "C-" + calendarUnit + calendarDirection;
        break;
    }
  }

  void _getAbsoluteWidgets(List<Widget> children) {
    if (absoluteValue == null) {
      absoluteValue = DateTime.now();
    }
    children.add(
      Expanded(
        child: BorderButton(
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
              widget.onChanged(
                _buildStringValue(),
              );
            });
          },
        ),
      ),
    );
  }

  void _getRelativeWidgets(List<Widget> children) {
    children.add(Text("is in the "));
    children.add(
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
          widget.onChanged(
            _buildStringValue(),
          );
        },
      ),
    );
    children.add(
      Container(
        width: 50,
        child: DoubleField(
          controller: _controller,
          onChanged: (value) => setState(() {
            relativeValue = double.parse(
              value,
              (erroredValue) {
                _controller.text = relativeValue.toString();
                return relativeValue;
              },
            ).abs();
            _controller.text = relativeValue.toString();
            widget.onChanged(
              _buildStringValue(),
            );
          }),
        ),
      ),
    );
    children.add(
      DropdownButton<String>(
        value: relativeUnit,
        items: [
          DropdownMenuItem(child: Text("days"), value: "d"),
          DropdownMenuItem(child: Text("weeks"), value: "w"),
          DropdownMenuItem(child: Text("months"), value: "m"),
          DropdownMenuItem(child: Text("years"), value: "y"),
        ],
        onChanged: (value) {
          setState(() {
            relativeUnit = value;
          });
          widget.onChanged(
            _buildStringValue(),
          );
        },
      ),
    );
  }

  void _getCalendarWidgets(List<Widget> children) {
    children.add(Text("is in the "));
    children.add(
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
          widget.onChanged(
            _buildStringValue(),
          );
        },
      ),
    );
    children.add(
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
          widget.onChanged(
            _buildStringValue(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var children = List<Widget>();

    children.add(
      DropdownButton<String>(
          value: dateType,
          items: [
            DropdownMenuItem(child: Text("Absolute"), value: "A"),
            DropdownMenuItem(child: Text("Relative"), value: "R"),
            DropdownMenuItem(child: Text("Calendar"), value: "C"),
          ],
          onChanged: (value) => setState(() {
                dateType = value;
              })),
    );
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

    return Row(
      children: children,
    );
  }
}
