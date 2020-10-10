import 'package:plastic/model/view/view_widget.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

class ViewFrame extends ViewWidget {
  FrameLayout layout;
  List<ViewWidget> children;

  ViewFrame({this.layout, this.children}) {
    if (layout == null) layout = FrameLayout.VERTICAL;
    if (children == null) children = List();
  }
}
