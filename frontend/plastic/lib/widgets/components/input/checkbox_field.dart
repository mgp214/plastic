import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class CheckboxField extends StatelessWidget {
  final FocusNode focusNode;
  final TextStyle labelStyle;
  final void Function(bool) onChanged;
  final String label;
  final Color checkColor;
  final bool value;

  const CheckboxField(
      {Key key,
      @required this.onChanged,
      @required this.value,
      this.focusNode,
      this.labelStyle,
      this.label,
      this.checkColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        title: Text(
          label ?? "",
          style: labelStyle ?? Style.getStyle(FontRole.Display3, Style.accent),
        ),
        checkColor: checkColor ?? Style.primary,
        onChanged: onChanged,
        value: value ?? false,
      );
}
