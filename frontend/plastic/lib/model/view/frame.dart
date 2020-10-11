import 'package:plastic/model/view/view_widget.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

class Frame {
  Frame parent;

  List<Frame> childFrames;
  ViewWidget widget;
  FrameLayout layout;

  Frame({this.parent, this.childFrames, this.widget, this.layout}) {
    if (childFrames == null) childFrames = List();
  }
}
