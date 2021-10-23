import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/view/conditions/condition_operator.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';

class SimpleListWidget extends ViewWidget {
  ThingCondition condition;
  dynamic things;

  SimpleListWidget({this.condition, VoidCallback triggerRebuild})
      : super(triggerRebuild) {
    if (condition == null)
      condition = ConditionOperator(operation: OPERATOR.AND, operands: []);
  }

  @override
  Future<void> getData() async {
    try {
      var response = await Api.thing.getThingsMatching(null, condition);

      if (response is ApiPostResponse<List<Thing>>) {
        things = response.postResult;
        triggerRebuild();
      }
    } on ApiException catch (e) {
      things = e.message;
      triggerRebuild();
    }
  }

  @override
  Map<String, dynamic> toJson() {
    var data = Map<String, dynamic>();
    data['type'] = (SimpleListWidget).toString();
    data['condition'] = condition.toJson();
    return data;
  }

  SimpleListWidget.fromJson(
      Map<String, dynamic> json, VoidCallback triggerRebuild)
      : super(triggerRebuild) {
    condition = ThingCondition.fromJson(json['condition']);
  }
}
