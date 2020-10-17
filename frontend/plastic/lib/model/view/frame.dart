import 'dart:convert';
import 'dart:math' as math;

import 'dart:developer';

import 'package:plastic/model/view/view_widget.dart';
import 'package:uuid/uuid.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

FrameLayout opposite(FrameLayout layout) => layout == FrameLayout.VERTICAL
    ? FrameLayout.HORIZONTAL
    : FrameLayout.VERTICAL;

class Frame {
  static final math.Random random = math.Random();
  Frame parent;

  List<Frame> childFrames;
  ViewWidget widget;
  FrameLayout layout;
  String id;

  static Frame copy(Frame source) {
    var copy = Frame(
        widget: source.widget, layout: source.layout, parent: source.parent);
    for (var child in source.childFrames) {
      var childCopy = Frame.copy(child);
      copy.childFrames.add(childCopy);
      childCopy.parent = copy;
    }
    return copy;
  }

  bool get isRoot =>
      this == root || (parent == root && parent.childFrames.length == 1);

  Frame({this.parent, this.childFrames, this.widget, this.layout}) {
    if (childFrames == null) childFrames = List();
    if (widget == null) widget = ViewWidget();
    id = Uuid().v4().toString().substring(0, 4);
  }

  void trimFromTree(Frame frame) {
    // new frame, we don't need to trim.
    if (frame == null) return;
    List<Frame> getChildren(Frame frame) {
      var results = List<Frame>();
      results.addAll(frame.childFrames);
      for (var child in frame.childFrames) {
        results.addAll(getChildren(child));
      }
      return results;
    }

    var tree = getChildren(root);
    log('BEFORE');
    log(root.prettyPrint());

    log('removing all frames with widget matching this one: ${frame.widget.id}');

    for (var f in tree) {
      if (f.widget == frame.widget) {
        f.parent.childFrames.remove(f);
        log('checking for dead branch');
        var branch = f.parent;
        while (branch != root) {
          if (branch.childFrames.length == 1) {
            log('branch only has single child.');
            if (branch.childFrames.first.widget != null) {
              log('branch child is leaf, moving leaf up to branch');
              branch.widget = branch.childFrames.first.widget;
              branch.childFrames.removeAt(0);
            } else {
              log('sewing branch childs children directly into branch');
              var startIndex = branch.parent.childFrames.indexOf(branch);
              branch.parent.childFrames
                  .insertAll(startIndex, branch.childFrames.first.childFrames);
              branch.childFrames.first.childFrames
                  .forEach((c) => c.parent = branch.parent);
              branch.parent.childFrames.remove(branch);
            }
          } else if (branch.childFrames.length == 0) {
            log('trimming dead branch');
            branch.parent.childFrames.remove(branch);
          }
          log('moving up to branchs parent');
          branch = branch.parent;
        }
      }
    }
    log('AFTER');
    log(root.prettyPrint());
  }

  Map<String, dynamic> tree() {
    Map getMap(Frame frame) {
      var map = Map<String, dynamic>();

      var entries = frame.childFrames.map(
        (c) => MapEntry<String, dynamic>(
          c.toString(),
          getMap(c),
        ),
      );

      map['parent'] = frame.parent?.id;
      map['widget'] = frame.widget?.id;

      for (var entry in entries) {
        map[entry.key] = entry.value;
      }

      return map;
    }

    var thisMap = Map<String, dynamic>();
    thisMap[toString()] = getMap(root);

    return thisMap;
  }

  Frame get root {
    var root = this;
    while (root.parent != null) {
      root = root.parent;
    }
    return root;
  }

  @override
  String toString() => (layout == FrameLayout.HORIZONTAL ? 'H-' : 'V-') + id;

  String prettyPrint() {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(tree());
  }
}
