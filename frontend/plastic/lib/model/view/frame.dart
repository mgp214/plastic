import 'dart:math' as math;

import 'dart:developer';

import 'package:plastic/model/view/view_widget.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

class Frame {
  static final math.Random random = math.Random();
  Frame parent;

  List<Frame> childFrames;
  ViewWidget widget;
  FrameLayout layout;
  // String get id =>
  //     (layout == FrameLayout.HORIZONTAL ? 'H' : 'V') + '-' + widget.id;

  Frame({this.parent, this.childFrames, this.widget, this.layout}) {
    if (childFrames == null) childFrames = List();
    if (widget == null) widget = ViewWidget();
  }

  void trimFromTree(Frame frame) {
    List<Frame> getChildren(Frame frame) {
      var results = List<Frame>();
      results.addAll(frame.childFrames);
      for (var child in frame.childFrames) {
        results.addAll(getChildren(child));
      }
      return results;
    }

    var root = this;
    while (root.parent != null) {
      root = parent;
    }

    // var visited = List<Frame>();
    // var markedForRemoval = List<Frame>();
    var tree = getChildren(root);
    root.printTree();
    for (var f in tree) {
      if (f.widget == frame.widget) {
        if (f.parent?.childFrames?.length == 1) {
          // markedForRemoval.add(f.parent);
          f.parent.parent?.childFrames?.remove(f.parent);
        }
        // markedForRemoval.add(f);
        f.parent.childFrames.remove(f);
      }
    }
    // for (var f in markedForRemoval) {
    // f.parent?.childFrames?.remove(f);
    // }
  }

  void printTree() {
    var root = this;
    while (root.parent != null) {
      root = parent;
    }

    var currentLevel = List<Frame>();
    currentLevel.add(root);

    var levels = List<List<Frame>>();
    levels.add(currentLevel);

    while (currentLevel.map((f) => f.childFrames).fold(
          List<Frame>(),
          (list, newItems) {
            list.addAll(newItems);
            return list;
          },
        ).length >
        0) {
      currentLevel = currentLevel.map((f) => f.childFrames).fold(
        List<Frame>(),
        (list, newItems) {
          list.addAll(newItems);
          return list;
        },
      );
      levels.add(currentLevel);
    }

    for (var level in levels) {
      var output = level
          .map((f) => '[${f.widget?.id ?? ""}]')
          .reduce((value, element) => value += element);
      log(output);
    }
  }
}
