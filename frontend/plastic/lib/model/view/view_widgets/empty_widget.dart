import 'package:plastic/model/view/view_widgets/view_widget.dart';

class EmptyWidget extends ViewWidget {
  EmptyWidget() : super(() {});

  @override
  Future<void> getData() => Future.value(null);

  Map<String, dynamic> toJson() {
    return Map<String, dynamic>();
  }
}
