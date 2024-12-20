import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/preference_manager.dart';
import 'package:plastic/model/user.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
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
  GlobalKey<ActionItemState> key1, key2, key3, key4;
  bool _isReadyForRefresh;
  @override
  void initState() {
    key1 = GlobalKey<ActionItemState>();
    key2 = GlobalKey<ActionItemState>();
    key3 = GlobalKey<ActionItemState>();
    key4 = GlobalKey<ActionItemState>();
    _isReadyForRefresh = true;
    var widgets = _getAllWidgets(widget.view.root);
    for (var w in widgets) {
      w.triggerRebuild = refresh;
    }
    refresh();
    super.initState();
    Timer(
      Duration(milliseconds: 250),
      () => setState(
        () {
          _isReadyForRefresh = true;
        },
      ),
    );
  }

  void refresh() {
    if (!_isReadyForRefresh) return;
    _isReadyForRefresh = false;
    var widgets = _getAllWidgets(widget.view.root);
    for (var w in widgets) {
      w.getData();
    }

    Timer(
      Duration(seconds: 1),
      () => setState(
        () {
          _isReadyForRefresh = true;
        },
      ),
    );
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
        radius: 120,
        onAdd: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemplatePickerPage(),
            )).then((value) => refresh()),
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
          ActionItem(
            key: key4,
            color: Motif.title,
            icon: Icons.edit_outlined,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditViewPage(view: widget.view)),
            ),
          ),
        ],
      ),
    );
  }
}
