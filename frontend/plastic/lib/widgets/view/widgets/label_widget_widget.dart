import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/view_widgets/label_widget.dart';

class LabelWidgetWidget extends StatelessWidget {
  final LabelWidget labelWidget;

  const LabelWidgetWidget({Key key, @required this.labelWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          labelWidget.text.toString(),
          style: Motif.headerStyle(Sizes.Header, Motif.title),
        ),
      );
}
