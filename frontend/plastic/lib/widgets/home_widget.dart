import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/utility/notification_utilities.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/account/settings_widget.dart';
import 'package:plastic/widgets/loading_modal.dart';
import 'package:plastic/widgets/template/template_picker_widget.dart';
import 'package:plastic/widgets/thing/view_all_things_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account/log_in_widget.dart';
import 'action_menu/action_menu_widget.dart';
import 'action_menu/action_widget.dart';

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
    if (!await Api.account.hasValidToken()) return;
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
    if (!await Api.account.hasValidToken()) {
      _goToThenReload(LogInWidget());
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
        child: Spacer(),
      );
    return Scaffold(
      backgroundColor: Motif.background,
      floatingActionButton: ActionMenuWidget(
        onAdd: () => _goToThenReload(
          TemplatePickerWidget(
            templates: TemplateManager().getAllTemplates(),
          ),
        ),
        children: <ActionWidget>[
          ActionWidget(
            key: GlobalKey<ActionState>(),
            color: Motif.title,
            icon: Icons.settings,
            onPressed: () => _goToThenReload(SettingsWidget(
              user: user,
            )),
          ),
        ],
      ),
      body: SafeArea(
        child: ViewAllThingsWidget(
          things: _things,
          onRefresh: refresh,
        ),
      ),
    );
  }
}
