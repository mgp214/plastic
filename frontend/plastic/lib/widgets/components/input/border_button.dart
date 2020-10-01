import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/utility/style.dart';

class BorderButton extends StatelessWidget {
  final Color color;
  final String content;
  final VoidCallback onPressed;

  const BorderButton(
      {Key key,
      @required this.color,
      @required this.content,
      @required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                // borderSide: BorderSide(
                //     color: color, width: 2, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Style.borderRadius),
                ),
                splashColor: color,
                // highlightedBorderColor: color,
                padding: EdgeInsets.all(15),
                child: Text(
                  content,
                  style: Style.getStyle(
                    FontRole.Display3,
                    Style.white,
                  ),
                ),
                onPressed: onPressed,
                color: color,
              ),
            ),
          ],
        ),
      );
}
