import 'package:flutter/cupertino.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/view/conditions/thing_condition.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';

class CountWidget extends ViewWidget {
  ThingCondition countCondition;
  int count;

  CountWidget({this.countCondition, VoidCallback triggerRebuild})
      : super(triggerRebuild);

  @override
  Future<void> getData() async {
    var response = await Api.thing.getThingsMatching(null, countCondition);
    if (response is ApiPostResponse<List<Thing>>) {
      if (count == response.postResult.length) return;
      count = response.postResult.length;
      triggerRebuild();
    }
  }
}
