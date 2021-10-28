import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';

class EnumField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final TextStyle labelStyle;
  final Color fillColor;
  final void Function(String) onChanged;
  final String label;
  final String value;
  final List<String> choices;

  const EnumField(
      {Key key,
      @required this.controller,
      @required this.onChanged,
      this.focusNode,
      this.style,
      this.labelStyle,
      this.label,
      this.fillColor,
      @required this.value,
      this.choices})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: EdgeInsets.all(6),
      child: Row(
        children: [
          Text(
            label,
            style: style ?? Motif.contentStyle(Sizes.Content, Motif.black),
          ),
          Expanded(child: Container()),
          DropdownButton<String>(
            value: value,
            focusNode: focusNode,
            hint: Text(
              'pick one',
              style: style ?? Motif.contentStyle(Sizes.Content, Motif.black),
            ),
            items: choices
                .map((e) => DropdownMenuItem(
                      child: Text(
                        e,
                        style: style ??
                            Motif.contentStyle(Sizes.Content, Motif.black),
                      ),
                      value: e,
                    ))
                .toList(),
            onChanged: (value) => onChanged(value),
          ),
        ],
      ));
}
