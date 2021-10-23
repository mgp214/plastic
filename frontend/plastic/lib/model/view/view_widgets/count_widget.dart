import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';

class CountWidget extends ViewWidget {
  ThingCondition countCondition;
  dynamic count;

  CountWidget({this.countCondition, VoidCallback triggerRebuild})
      : super(triggerRebuild) {
    if (countCondition == null)
      countCondition = ConditionOperator(operation: OPERATOR.AND, operands: []);
  }

  @override
  Future<void> getData() async {
    try {
      var response = await Api.thing.getThingsMatching(null, countCondition);

      if (response is ApiPostResponse<List<Thing>>) {
        if (count == response.postResult.length) return;
        count = response.postResult.length ?? 0;
        triggerRebuild();
      }
    } on ApiException catch (e) {
      count = e.message;
      triggerRebuild();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data['type'] = (CountWidget).toString();
    data['condition'] = countCondition.toJson();
    return data;
  }

  CountWidget.fromJson(Map<String, dynamic> json, VoidCallback triggerRebuild)
      : super(triggerRebuild) {
    countCondition = ThingCondition.fromJson(json['condition']);
  }
}
