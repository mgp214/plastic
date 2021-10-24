import 'package:flutter/material.dart';
import 'package:plastic/api/view_api.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/model/view/view.dart';
import 'package:plastic/widgets/components/input/border_button.dart';
import 'package:plastic/widgets/components/splash_list_tile.dart';
import 'package:plastic/widgets/view/edit_view_page.dart';

class ViewPickerPage extends StatefulWidget {
  ViewPickerPage() : super();

  @override
  State<StatefulWidget> createState() => ViewPickerPageState();
}

class ViewPickerPageState extends State<ViewPickerPage> {
  List<View> _views;
  bool _isLoaded;

  ViewPickerPageState();

  @override
  void initState() {
    _views = List();
    _isLoaded = false;
    super.initState();
  }

  void _loadViewsAndRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ViewApi().getViewsByUser(context).then((value) {
        _isLoaded = true;
        setState(() {
          _views = value.getResult;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Motif.background,
        child: _getTemplateListView(),
      );

  Widget _getTemplateListView() {
    if (!_isLoaded) {
      _loadViewsAndRefresh();
      return Container();
    }
    List children = _views
        .map<Widget>(
          (view) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Card(
              elevation: 5,
              color: Motif.lightBackground,
              child: SplashListTile(
                color: Motif.title,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditViewPage(
                        view: view,
                      ),
                    ),
                  ).then((value) => _loadViewsAndRefresh());
                },
                child: Text(view.name,
                    style: Motif.contentStyle(
                      Sizes.Action,
                      Motif.black,
                    )),
              ),
            ),
          ),
        )
        .toList();
    children.add(
      BorderButton(
        content: "Create a new view",
        color: Motif.neutral,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditViewPage(
                view: View(root: Frame(layout: FrameLayout.VERTICAL))),
          ),
        ).then(
          (value) => _loadViewsAndRefresh(),
        ),
      ),
    );
    return ListView(children: children);
  }
}
