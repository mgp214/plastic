import 'dart:math' as math;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plastic/model/view/view_widgets/empty_widget.dart';
import 'package:plastic/model/view/view_widgets/view_widget.dart';
import 'package:plastic/utility/view_widget_serializer.dart';
import 'package:uuid/uuid.dart';

enum FrameLayout { VERTICAL, HORIZONTAL }

FrameLayout opposite(FrameLayout layout) => layout == FrameLayout.VERTICAL
    ? FrameLayout.HORIZONTAL
    : FrameLayout.VERTICAL;

class Frame {
  static final flexResolution = 100000;
  static final scaleSensitivity = 0.5;
  static final math.Random random = math.Random();
  Frame parent;

  List<Frame> childFrames;
  ViewWidget widget;
  FrameLayout layout;
  double flex;
  String id;

  static Frame copy(Frame source) {
    var copy = Frame(
      widget: source.widget,
      layout: source.layout,
      parent: source.parent,
      flex: source.flex,
    );
    for (var child in source.childFrames) {
      var childCopy = Frame.copy(child);
      copy.childFrames.add(childCopy);
      childCopy.parent = copy;
    }
    return copy;
  }

  bool get isRoot =>
      this == root || (parent == root && parent.childFrames.length == 1);

  Frame({
    this.parent,
    this.childFrames,
    this.widget,
    this.layout,
    this.flex = 1,
  }) {
    if (childFrames == null) childFrames = List();
    if (widget == null) widget = EmptyWidget();
    id = Uuid().v4().toString().substring(0, 4);
  }

  void addFlex(double flex) {
    this.flex += flex;
    if (this.flex < 0.1) this.flex = 0.1;
  }

  void normalizeFlex() {
    if (this == root) return;
    var parentFlexSum = 0.00;

    // parent.childFrames.forEach((f) => log('pre: ${f.flex}'));
    parent.childFrames.forEach((f) => parentFlexSum += f.flex);
    parent.childFrames.forEach(
        (f) => f.flex = f.flex / parentFlexSum * parent.childFrames.length);
    // parent.childFrames.forEach((f) => log('post: ${f.flex}'));

    if (parent.parent != null) {
      var grandparentFlexSum = 0.00;
      // parent.parent.childFrames.forEach((f) => log('pre: ${f.flex}'));
      parent.parent.childFrames.forEach((f) => grandparentFlexSum += f.flex);
      parent.parent.childFrames.forEach((f) => f.flex =
          f.flex / grandparentFlexSum * parent.parent.childFrames.length);
      // parent.parent.childFrames.forEach((f) => log('post: ${f.flex}'));
    }
  }

  void adjustScale(Offset scale) {
    log(scale.distance.toString());
    if (this == root) return;
    if (parent.layout == FrameLayout.HORIZONTAL) {
      flex += (scaleSensitivity * scale.dx);
      parent.flex += (scaleSensitivity * scale.dy);
    } else {
      flex += (scaleSensitivity * scale.dy);
      parent.flex += (scaleSensitivity * scale.dx);
    }
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
    // log('BEFORE');
    // log(root.prettyPrint());

    // log('removing all frames with widget matching this one: ${frame.widget.id}');

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
    // log(root.prettyPrint());
  }

  // Map<String, dynamic> tree() {
  //   Map getMap(Frame frame) {
  //     var map = Map<String, dynamic>();

  //     var entries = frame.childFrames.map(
  //       (c) => MapEntry<String, dynamic>(
  //         c.toString(),
  //         getMap(c),
  //       ),
  //     );

  //     map['parent'] = frame.parent?.id;
  //     map['widget'] = frame.widget?.id;

  //     for (var entry in entries) {
  //       map[entry.key] = entry.value;
  //     }

  //     return map;
  //   }

  //   var thisMap = Map<String, dynamic>();
  //   thisMap[toString()] = getMap(root);

  //   return thisMap;
  // }

  Frame get root {
    var root = this;
    while (root.parent != null) {
      root = root.parent;
    }
    return root;
  }

  @override
  String toString() => (layout == FrameLayout.HORIZONTAL ? 'H-' : 'V-') + id;

  // String prettyPrint() {
  //   var encoder = JsonEncoder.withIndent('  ');
  //   return encoder.convert(tree());
  // }
  Frame.fromJson(Map<String, dynamic> json) {
    flex = json['flex'].toDouble();
    layout = FrameLayout.values.firstWhere(
        (e) => e.toString() == json['layout'],
        orElse: () => FrameLayout.VERTICAL);
    id = json['id'];
    widget = ViewWidgetSerializer.fromJson(json['widget'], () {});
    childFrames = List();
    if (json['childFrames'] != null) {
      for (var cf in json['childFrames']) {
        childFrames.add(Frame.fromJson(cf));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['layout'] = layout.toString();
    data['flex'] = flex;
    var children = List<Map<String, dynamic>>();
    for (var f in childFrames) {
      children.add(f.toJson());
    }
    data['childFrames'] = children;
    data['id'] = id;
    data['widget'] = widget?.toJson();

    return data;
  }
}
