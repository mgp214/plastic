import 'package:flutter/cupertino.dart';

abstract class ViewWidget {
  VoidCallback triggerRebuild;

  ViewWidget(this.triggerRebuild);

  Future<void> getData();

  Map<String, dynamic> toJson();

  ViewWidget.fromJson(String jsonString);
}
