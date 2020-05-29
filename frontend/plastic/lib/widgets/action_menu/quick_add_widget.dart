import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class QuickAddWidget extends StatefulWidget {
  final FocusNode focusNode;

  QuickAddWidget({this.focusNode});

  @override
  State<StatefulWidget> createState() => QuickAddState();
}

class QuickAddState extends State<QuickAddWidget> {
  Map<String, dynamic> workingThing;

  String _value;

  void onChanged(BuildContext context, String newValue) {
    String templateMatch = RegExp("#\w+").firstMatch(newValue).group(0);

    //TODO: check if templateMatch is a valid template, if not, show partial matches as dropdown options

    //TODO: Pull up template as model, search for other field names, If partial, show partial matches as dropdown options
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: MediaQuery.of(context).size.width - 75,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Style.borderRadius),
              border: Border.all(color: Style.primary),
              color: Style.inputField),
          padding: EdgeInsets.all(1),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            child: TextField(
              focusNode: widget.focusNode,
              decoration:
                  InputDecoration(border: InputBorder.none, filled: false),
              style: Style.getStyle(FontRole.Content, Style.accent),
              onChanged: (value) => onChanged(context, value),
              maxLines: null,
            ),
          ),
        ),
      );
}
