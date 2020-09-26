import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/account/settings_widget.dart';
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
    Api.thing.getThingsByUser().then(
      (value) {
        if (!value.successful) {
          Flushbar(
              messageText: Text(
                value.message,
                style: Style.getStyle(FontRole.Tooltip, Style.error),
              ),
              duration: Style.toastDuration)
            ..show(context);
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
        .then((val) => TemplateManager().loadTemplates())
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
          color: Style.background,
          alignment: Alignment.center,
          child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Style.background,
      floatingActionButton: ActionMenuWidget(
        onAdd: () => _goToThenReload(
          TemplatePickerWidget(
            templates: TemplateManager().getAllTemplates(),
          ),
        ),
        children: <ActionWidget>[
          ActionWidget(
            key: GlobalKey<ActionState>(),
            color: Style.accent,
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
