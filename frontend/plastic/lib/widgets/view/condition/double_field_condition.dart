import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/value_condition.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/input/double_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';
import 'package:plastic/widgets/view/condition/condition_card.dart';

class DoubleFieldCondition extends StatefulWidget {
  final ValueCondition condition;

  const DoubleFieldCondition({Key key, @required this.condition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => DoubleFieldConditionState();
}

class DoubleFieldConditionState extends State<DoubleFieldCondition> {
  TextEditingController _nameController;
  TextEditingController _valueController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.condition.fieldName ?? "");
    _valueController =
        TextEditingController(text: widget.condition.value ?? "");
  }

  List<Widget> _getFieldTypeComparisons() {
    var comparisions = List<ValueComparison>();
    comparisions.add(ValueComparison.E);
    comparisions.add(ValueComparison.LT);
    comparisions.add(ValueComparison.LTE);
    comparisions.add(ValueComparison.GT);
    comparisions.add(ValueComparison.GTE);

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

  @override
  Widget build(BuildContext context) => ConditionCard(
        label: 'Real number field',
        children: [
          StringField(
            controller: _nameController,
            onChanged: (value) => setState(() {
              widget.condition.fieldName = value;
            }),
            label: 'Field name',
          ),
          DropdownButton(
            value: widget.condition.comparison,
            items: _getFieldTypeComparisons(),
            onChanged: (value) => setState(() {
              widget.condition.comparison = value;
            }),
          ),
          DoubleField(
            controller: _valueController,
            onChanged: (value) => setState(() {
              widget.condition.value = value;
            }),
            label: 'Value',
          ),
        ],
      );
}
