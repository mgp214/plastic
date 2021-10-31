import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/conditions/value_condition.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/components/input/checkbox_field.dart';
import 'package:plastic/widgets/components/input/string_field.dart';

class BoolFieldCondition extends StatefulWidget {
  final ValueCondition condition;

  const BoolFieldCondition({Key key, @required this.condition})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => BoolFieldConditionState();
}

class BoolFieldConditionState extends State<BoolFieldCondition> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.condition.fieldName ?? "");
  }

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Card(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StringField(
                      controller: _nameController,
                      onChanged: (value) => setState(() {
                        widget.condition.fieldName = value;
                      }),
                      label: 'Field name',
                    ),
                    CheckboxField(
                        onChanged: (value) => setState(() {
                              widget.condition.value = value ? 'true' : 'false';
                            }),
                        value: widget.condition.value == 'true')
                  ],
                ),
              ),
              Icon(
                Icons.menu,
                size: Constants.iconSize,
                color: Motif.neutral,
              ),
            ],
          ),
        ),
      );
}
