import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';

class FrameResizeHandle extends StatelessWidget {
  final VoidCallback rebuildLayout;
  final double Function() getParentLength;
  final Frame before;
  final Frame after;
  final FrameLayout parentLayout;

  const FrameResizeHandle(
      {Key key,
      @required this.rebuildLayout,
      @required this.before,
      @required this.after,
      @required this.parentLayout,
      @required this.getParentLength})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Motif.title,
            width: 3,
          ),
        ),
        child: Icon(
          parentLayout == FrameLayout.HORIZONTAL
              ? Icons.more_vert
              : Icons.more_horiz,
          color: Motif.title,
          size: 15,
        ),
      ),
      onPanUpdate: (updateDetails) {
        var parentLength = getParentLength();
        var siblings = before.parent.childFrames.length;
        var flexAdjustment = siblings *
            (parentLayout == FrameLayout.HORIZONTAL
                ? updateDetails.delta.dx
                : updateDetails.delta.dy) /
            parentLength;

        if ((flexAdjustment > 0 && after.flex > flexAdjustment) ||
            (flexAdjustment < 0 && before.flex > flexAdjustment)) {
          before.addFlex(flexAdjustment);
          after.addFlex(-flexAdjustment);
        }

        before.normalizeFlex();
        rebuildLayout();
      },
    );
  }
}
