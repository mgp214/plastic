import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashListTile extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;

  const SplashListTile(
      {Key key,
      @required this.child,
      @required this.color,
      @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        splashColor: color,
        onTap: onTap,
        child: ListTile(
          title: child,
          hoverColor: color,
          focusColor: color,
        ),
      );
}
