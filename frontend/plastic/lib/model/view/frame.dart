import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plastic/model/view/view_widget.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

class Frame {
  static final Random random = Random();
  Frame parent;

  List<Frame> childFrames;
  ViewWidget widget;
  FrameLayout layout;
  Color color;

  Frame({this.parent, this.childFrames, this.widget, this.layout}) {
    if (childFrames == null) childFrames = List();
    color = Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }
}
