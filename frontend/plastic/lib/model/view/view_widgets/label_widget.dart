import 'package:flutter/material.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';

class LabelWidget extends ViewWidget {
  String text;

  LabelWidget({this.text, triggerRebuild}) : super(triggerRebuild);

  @override
  Future<void> getData() async {
    return;
  }

  @override
  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data['type'] = (LabelWidget).toString();
    data['text'] = text;
    return data;
  }

  LabelWidget.fromJson(Map<String, dynamic> json, VoidCallback triggerRebuild)
      : super(triggerRebuild) {
    text = json['text'];
  }
}
