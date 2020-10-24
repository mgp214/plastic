import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_post_response.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/view/view_widgets/count_widget.dart';

class CountWidgetWidget extends StatefulWidget {
  final CountWidget countWidget;

  const CountWidgetWidget({Key key, @required this.countWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CountWidgetState();
}

class CountWidgetState extends State<CountWidgetWidget> {
  int _count;

  Future<void> _get() async {
    var response = await Api.thing
        .getThingsMatching(context, widget.countWidget.countCondition);
    if (response is ApiPostResponse<List<Thing>>) {
      setState(() {
        _count = response.postResult.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == null)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _get();
      });

    return Center(
      child: Text(
        _count.toString(),
        style: Motif.headerStyle(Sizes.Header, Motif.title),
      ),
    );
  }
}
