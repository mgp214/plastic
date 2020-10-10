import 'package:plastic/model/view/view_widget.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

class ViewFrame extends ViewWidget {
  FrameLayout layout;
  List<ViewWidget> children;
}
