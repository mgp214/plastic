import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/constants.dart';

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
        padding: EdgeInsets.all(5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                // borderSide: BorderSide(
                //     color: color, width: 2, style: BorderStyle.solid),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Constants.borderRadius),
                ),
                splashColor: color,

                // highlightedBorderColor: color,
                padding: EdgeInsets.all(15),
                child: Text(
                  content,
                  style: Motif.actionStyle(Sizes.Action, Motif.white),
                ),
                onPressed: onPressed,
                color: color,
              ),
            ),
          ],
        ),
      );
}
