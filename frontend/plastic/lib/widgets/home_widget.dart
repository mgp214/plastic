import 'package:flutter/material.dart';
import 'package:plastic/api/api.dart';
import 'package:plastic/model/api/api_exception.dart';
import 'package:plastic/model/preference_manager.dart';
import 'package:plastic/model/thing.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/utility/notifier.dart';
import 'package:plastic/utility/template_manager.dart';
import 'package:plastic/widgets/account/settings_page.dart';
import 'package:plastic/widgets/template/template_picker_page.dart';
import 'package:plastic/widgets/thing/view_all_things_page.dart';
import 'package:plastic/widgets/view/edit_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    setState(() => {
          _isDoneLoading = true,
        });
  }

  Future<void> refresh() async {
    setState(() {
      _isDoneLoading = false;
      _things = List<Thing>();
    });
    try {
      await getPrefs();
      await TemplateManager().loadTemplates(context);
      await getAllThings();
    } on ApiException catch (e) {
      Notifier.handleApiError(context, e);
    }
  }

  Future<void> getPrefs() async {
    SharedPreferences preferences = PreferenceManager().get();
    preferences.reload();
    setState(() {
      user = User(
          name: preferences.getString("name"),
          email: preferences.getString("email"),
          id: preferences.getString("id"));
    });
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
        children: [
          ActionItem(
            key: GlobalKey<ActionItemState>(),
            color: Motif.title,
            icon: Icons.settings,
            onPressed: () => _goToThenReload(SettingsPage(
              user: user,
            )),
          ),
          ActionItem(
            key: GlobalKey<ActionItemState>(),
            color: Motif.title,
            icon: Icons.view_compact,
            onPressed: () => _goToThenReload(EditViewPage(
                view: View(root: Frame(layout: FrameLayout.VERTICAL)))),
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
