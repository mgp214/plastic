import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/utility/notifier.dart';
import 'package:plastic/widgets/thing/view_all_things_page.dart';

class AllThingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AllThingsViewState();
}

class AllThingsViewState extends State<AllThingsView> {
  List<Thing> _things;
  @override
  void initState() {
    _things = List();
    Future.delayed(Duration(milliseconds: 250), () => getAllThings());
  }

  Future<void> getAllThings() async {
    try {
      var response = await Api.thing.getThingsByUser(context);

      if (!response.successful) {
        Notifier.notify(
          context,
          message: response.message,
          color: Motif.negative,
        );
        return;
      }
      setState(() => {
            _things = response.getResult,
          });
    } on ApiException catch (e) {
      Notifier.handleApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Motif.background,
        body: SafeArea(
          child: ViewAllThingsPage(
            things: _things,
            onRefresh: () => getAllThings(),
          ),
        ),
      );
}
