import 'package:flutter/material.dart';
import 'package:plastic/api/view_api.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/preference_manager.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/widgets/account/settings_page.dart';
import 'package:plastic/widgets/template/template_picker_page.dart';
import 'package:plastic/widgets/view/edit_view_page.dart';
import 'package:plastic/widgets/view/view_frame_card.dart';
import 'package:plastic/widgets/view/view_picker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../action_menu/action_menu.dart';
import '../action_menu/action_item.dart';

class ViewPage extends StatefulWidget {
  final View view;

  const ViewPage({Key key, @required this.view}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewPageState();
}

class ViewPageState extends State<ViewPage> with TickerProviderStateMixin {
  AnimationController _refreshAnimationController;
  GlobalKey<ActionItemState> key1, key2, key3;
  @override
  void initState() {
    _refreshAnimationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    key1 = GlobalKey<ActionItemState>();
    key2 = GlobalKey<ActionItemState>();
    key3 = GlobalKey<ActionItemState>();
    refresh();
    super.initState();
  }

  void refresh() {
    var widgets = _getAllWidgets(widget.view.root);
    for (var w in widgets) {
      w.getData();
      w.triggerRebuild = () {
        setState(() {});
      };
    }
    setState(() {});
  }

  List<ViewWidget> _getAllWidgets(Frame frame) {
    var result = List<ViewWidget>();
    if (frame.widget != null && frame.widget.runtimeType != EmptyWidget) {
      result.add(frame.widget);
    }
    for (var cf in frame.childFrames) {
      result.addAll(_getAllWidgets(cf));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences = PreferenceManager().get();
    var user = User(
        name: preferences.getString("name"),
        email: preferences.getString("email"),
        id: preferences.getString("id"));
    return Scaffold(
      backgroundColor: Motif.background,
      body: SafeArea(
        child: Container(
          child: ViewFrameCard(
            frame: widget.view.root,
            rebuildLayout: (isDragging) => setState(() {}),
            resetLayout: (f) => setState(() {
              widget.view.root = f;
            }),
            isLocked: true,
            isEditing: false,
          ),
          height: MediaQuery.of(context).size.height,
        ),
      ),
      floatingActionButton: ActionMenu(
        onAdd: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemplatePickerPage(),
            )),
        children: [
          ActionItem(
            key: key1,
            color: Motif.title,
            icon: Icons.settings,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(user: user),
              ),
            ),
          ),
          ActionItem(
              key: key2,
              color: Motif.title,
              icon: Icons.refresh,
              onPressed: () {
                _refreshAnimationController.forward().then((value) {
                  _refreshAnimationController.reset();
                });
                refresh();
              }),
          ActionItem(
            key: key3,
            color: Motif.title,
            icon: Icons.view_compact,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewPickerPage()),
            ),
          ),
        ],
      ),
    );
  }
}
