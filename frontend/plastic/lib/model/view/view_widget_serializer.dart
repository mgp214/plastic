import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:plastic/model/view/view_widgets/count_widget.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/simple_list_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';

enum ViewWidgetTypes { SimpleList, Count }

class ViewWidgetSerializer {
  static Map<String, Type> widgetTypeMap = {
    'SimpleListWidget': SimpleListWidget,
    'CountWidget': CountWidget,
  };

  static ViewWidget fromJson(
      Map<String, dynamic> json, VoidCallback triggerRebuild) {
    switch (widgetTypeMap[json['type']]) {
      case SimpleListWidget:
        return SimpleListWidget.fromJson(json, triggerRebuild);
        break;
      case CountWidget:
        return CountWidget.fromJson(json, triggerRebuild);
        break;
    }
    return EmptyWidget();
  }
}
