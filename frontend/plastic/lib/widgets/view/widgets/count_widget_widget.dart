import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/count_widget.dart';

class CountWidgetWidget extends StatelessWidget {
  final CountWidget countWidget;

  const CountWidgetWidget({Key key, @required this.countWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          countWidget.count.toString(),
          style: Motif.headerStyle(Sizes.Header, Motif.title),
        ),
      );
}
