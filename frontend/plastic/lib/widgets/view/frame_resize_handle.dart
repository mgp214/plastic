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
        if (parentLayout == FrameLayout.HORIZONTAL) {
          if (after.flex > siblings * updateDetails.delta.dx / parentLength) {
            before.flex += siblings * updateDetails.delta.dx / parentLength;
            after.flex -= siblings * updateDetails.delta.dx / parentLength;
          }
        } else {
          if (after.flex > siblings * updateDetails.delta.dy / parentLength) {
            before.flex += siblings * updateDetails.delta.dy / parentLength;
            after.flex -= siblings * updateDetails.delta.dy / parentLength;
          }
        }
        before.normalizeFlex();
        rebuildLayout();
        log(updateDetails.toString());
      },
    );
  }
}
