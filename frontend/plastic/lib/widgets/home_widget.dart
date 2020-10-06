import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/notification_utilities.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/account/settings_page.dart';
import 'package:plastic/widgets/template/template_picker_page.dart';
import 'package:plastic/widgets/thing/view_all_things_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account/log_in_page.dart';
import 'action_menu/action_menu.dart';
import 'action_menu/action_item.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> {
  User user;
  bool _isDoneLoading = false;
  List<Thing> _things;

  void _goToThenReload(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget))
        .then((value) {
      refresh();
    });
  }

  Future<void> getAllThings() async {
    var validTokenResult = await Api.account.hasValidToken();
    if (validTokenResult != null)
      NotificationUtilities.notify(context,
          message: validTokenResult.message, color: Motif.negative);
    Api.thing.getThingsByUser(context).then(
      (value) {
        if (!value.successful) {
          NotificationUtilities.notify(
            context,
            message: value.message,
            color: Motif.negative,
          );
          return;
        }
        setState(() => {
              _isDoneLoading = true,
              _things = value.getResult,
            });
      },
    );
  }

  Future<void> refresh() async {
    setState(() {
      _isDoneLoading = false;
      _things = List<Thing>();
    });
    getPrefs()
        .then((val) => TemplateManager().loadTemplates(context))
        .then((val) => getAllThings());
  }

  Future<void> getPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var validTokenResult = await Api.account.hasValidToken();
    if (validTokenResult != null) {
      NotificationUtilities.notify(context,
          message: validTokenResult.message, color: Motif.negative);
      _goToThenReload(LogInPage());
      return;
    } else {
      setState(() {
        user = User(
            name: preferences.getString("name"),
            email: preferences.getString("email"),
            id: preferences.getString("id"));
      });
    }
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDoneLoading)
      return Container(
        color: Motif.background,
        alignment: Alignment.center,
      );
    return Scaffold(
      backgroundColor: Motif.background,
      floatingActionButton: ActionMenu(
        onAdd: () => _goToThenReload(
          TemplatePickerPage(),
        ),
        children: <ActionItem>[
          ActionItem(
            key: GlobalKey<ActionItemState>(),
            color: Motif.title,
            icon: Icons.settings,
            onPressed: () => _goToThenReload(SettingsPage(
              user: user,
            )),
          ),
        ],
      ),
      body: SafeArea(
        child: ViewAllThingsPage(
          things: _things,
          onRefresh: refresh,
        ),
      ),
    );
  }
}
