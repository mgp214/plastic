import 'package:flutter/material.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view_widget.dart';

class ViewFrame extends ViewWidget {
  FrameLayout layout;
  List<ViewWidget> children;

  ViewFrame({ViewFrame parent, @required this.layout, this.children})
      : super(parent) {
    if (children == null) children = List();
  }
}
