import 'package:flutter/material.dart';
import 'package:plastic/api/backend_service.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/utility/style.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/log_in_widget.dart';
import 'package:plastic/widgets/settings_widget.dart';
import 'package:plastic/widgets/template_picker_widget.dart';
import 'package:plastic/widgets/view_all_things_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'action_menu/action_menu_widget.dart';
import 'action_menu/action_widget.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomeWidget> {
  User user;
  String token;
  bool _isDoneCheckingPrefs = false;
  List<Thing> _things;

  void _goToThenReload(Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget))
        .then((value) {
      setState(() {
        _isDoneCheckingPrefs = false;
      });

      getPrefs();
      getAllThings();
    });
  }

  void getAllThings() {
    BackendService.getThingsByUser().then(
      (value) => setState(
        () => {
          _things = value,
        },
      ),
    );
  }

  Future<Null> getPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (!preferences.containsKey("token")) {
      _goToThenReload(LogInWidget());
      return;
    }
    var tokenFromPrefs = preferences.getString("token");
    var name = preferences.getString("name");
    var email = preferences.getString("email");
    var id = preferences.getString("id");
    var isTokenValid = await BackendService.checkToken(tokenFromPrefs);

    if (!isTokenValid) {
      preferences.remove("token");
      preferences.remove("name");
      preferences.remove("email");
      preferences.remove("id");
      _goToThenReload(LogInWidget());
      return;
    }

    setState(() {
      _isDoneCheckingPrefs = true;
      token = tokenFromPrefs;
      user = User(name: name, email: email, id: id);
    });
  }

  @override
  void initState() {
    _things = List<Thing>();
    getPrefs();
    getAllThings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDoneCheckingPrefs)
      return Container(
          color: Style.background,
          alignment: Alignment.center,
          child: CircularProgressIndicator());
    return Material(
      color: Style.background,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ViewAllThingsWidget(
              things: _things,
              onThingsChanged: getAllThings,
            ),
            ActionMenuWidget(
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
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            )
          ],
        ),
      ),
    );
  }
}
