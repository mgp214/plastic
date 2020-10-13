import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/utility/constants.dart';
import 'package:plastic/utility/layout_utils.dart';

enum Edge { Left, Right, Top, Bottom }

class ViewFrameCard extends StatefulWidget {
  final Frame frame;
  final VoidCallback rebuildLayout;

  const ViewFrameCard(
      {Key key, @required this.frame, @required this.rebuildLayout})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewFrameCardState();

  // Widget build(BuildContext context) => Draggable(
  //       feedback: _getCard(),
  //       child: DragTarget(
  //         builder: (context, candidateData, rejectedData) => Container(
  //           constraints: BoxConstraints.expand(),
  //           alignment: Alignment.center,
  //           width: double.maxFinite,
  //           height: double.maxFinite,
  //           child: _getCard(),
  //         ),
  //       ),
  //     );
}

class ViewFrameCardState extends State<ViewFrameCard> {
  Edge _activeEdge;

  Widget _getCard() => Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Constants.borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Icon(
            Icons.add,
            color: Motif.title,
            size: Constants.iconSize,
          ),
        ),
      );

  void onAcceptDrag(DragTargetDetails<dynamic> value) {
    var edge = _getEdge(value.offset);
    if (value.data is Frame) {
      var frame = value.data as Frame;
      var index = widget.frame.parent?.childFrames?.indexOf(widget.frame);
      if (index == null) {
        widget.frame.childFrames.add(frame);
        frame.parent = widget.frame;
        widget.rebuildLayout();
        return;
      }
      if (edge == Edge.Right || edge == Edge.Bottom) index++;
      switch (edge) {
        case Edge.Left:
        case Edge.Right:
          if (widget.frame.parent.layout == FrameLayout.HORIZONTAL) {
            widget.frame.parent.childFrames.insert(index, frame);
            frame.parent.childFrames.remove(frame);
            frame.parent = widget.frame.parent;
          } else {
            var proxy = Frame(
                parent: widget.frame.parent, layout: FrameLayout.HORIZONTAL);
            widget.frame.parent.childFrames.insert(index, proxy);
            frame.parent.childFrames.remove(frame);
            frame.parent = widget.frame.parent;
            proxy.childFrames.add(frame);
          }
          break;
        case Edge.Top:
        case Edge.Bottom:
          if (widget.frame.parent.layout == FrameLayout.VERTICAL) {
            widget.frame.parent.childFrames.insert(index, frame);
            frame.parent.childFrames.remove(frame);
            frame.parent = widget.frame.parent;
          } else {
            var proxy = Frame(
                parent: widget.frame.parent, layout: FrameLayout.VERTICAL);
            widget.frame.parent.childFrames.insert(index, proxy);
            frame.parent.childFrames.remove(frame);
            frame.parent = widget.frame.parent;
            proxy.childFrames.add(frame);
          }
          break;
      }
    } else {
      if (widget.frame.layout == FrameLayout.VERTICAL) {
        if (edge == Edge.Top || edge == Edge.Bottom) {
          Frame parent;
          if (widget.frame.parent == null) {
            parent = widget.frame;
          } else {
            parent = widget.frame.parent;
          }
          var insertIndex = parent.childFrames.indexOf(widget.frame);

          insertIndex += edge == Edge.Bottom ? 1 : 0;
          parent.childFrames.insert(
            insertIndex,
            Frame(
              parent: parent,
              layout: FrameLayout.HORIZONTAL,
            ),
          );
        } else {
          var proxyFrame =
              Frame(parent: widget.frame, layout: FrameLayout.HORIZONTAL);
          widget.frame.childFrames.add(proxyFrame);
          var newWidget1 =
              Frame(parent: proxyFrame, layout: FrameLayout.VERTICAL);
          var newWidget2 =
              Frame(parent: proxyFrame, layout: FrameLayout.VERTICAL);
          proxyFrame.childFrames.add(newWidget1);
          proxyFrame.childFrames.add(newWidget2);
        }
      } else {
        if (edge == Edge.Left || edge == Edge.Right) {
          var insertIndex =
              widget.frame.parent.childFrames.indexOf(widget.frame);
          insertIndex += edge == Edge.Right ? 1 : 0;
          widget.frame.parent.childFrames.insert(
            insertIndex,
            Frame(
              parent: widget.frame.parent,
              layout: FrameLayout.VERTICAL,
            ),
          );
        } else {
          var proxyFrame =
              Frame(parent: widget.frame, layout: FrameLayout.VERTICAL);
          widget.frame.childFrames.add(proxyFrame);
          var newWidget1 =
              Frame(parent: proxyFrame, layout: FrameLayout.HORIZONTAL);
          var newWidget2 =
              Frame(parent: proxyFrame, layout: FrameLayout.HORIZONTAL);
          proxyFrame.childFrames.add(newWidget1);
          proxyFrame.childFrames.add(newWidget2);
        }
      }
    }
    widget.rebuildLayout();
  }

  Edge _getEdge(Offset offset) {
    var bounds = LayoutUtils.globalPaintBounds(context);
    var size = Size(bounds.right - bounds.left, bounds.bottom - bounds.top);
    // log('bounds: ${bounds.toString()}');
    // log('size: $size');
    var center = Offset(
      bounds.left + size.width / 2,
      bounds.top + size.height / 2,
    );
    var relOffset = Offset(
      (offset.dx - center.dx) / size.width,
      (offset.dy - center.dy) / size.height,
    );
    log('offset: ${offset.toString()}');
    log('center: ${center.toString()}');
    log('relOff: ${relOffset.toString()}');
    if (relOffset.dx < 0 && relOffset.dx.abs() > relOffset.dy.abs()) {
      return Edge.Left;
    } else if (relOffset.dx > 0 && relOffset.dx.abs() > relOffset.dy.abs()) {
      return Edge.Right;
    } else if (relOffset.dy < 0 && relOffset.dy.abs() > relOffset.dx.abs()) {
      return Edge.Top;
    } else {
      return Edge.Bottom;
    }
  }

  void _onDragMove(DragTargetDetails<dynamic> details) {
    setState(() {
      _activeEdge = _getEdge(details.offset);
    });
  }

  Widget _getDropIndicator(BoxConstraints constraints, Color color) {
    Widget dropIndicator;
    switch (_activeEdge) {
      case Edge.Left:
        dropIndicator = Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          right: constraints.maxWidth / 2,
          child: Placeholder(
            color: color,
          ),
        );
        break;
      case Edge.Right:
        dropIndicator = Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          left: constraints.maxWidth / 2,
          child: Placeholder(
            color: color,
          ),
        );
        break;
      case Edge.Top:
        dropIndicator = Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: constraints.maxHeight / 2,
          child: Placeholder(
            color: color,
          ),
        );
        break;
      case Edge.Bottom:
        dropIndicator = Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          top: constraints.maxHeight / 2,
          child: Placeholder(
            color: color,
          ),
        );
        break;
      default:
        dropIndicator = Container();
    }
    return dropIndicator;
  }

  @override
  Widget build(BuildContext context) {
    Widget dragTargetChild;

    var children = widget.frame.childFrames
        .map<Widget>(
          (c) => Expanded(
            child: ViewFrameCard(
              frame: c,
              rebuildLayout: widget.rebuildLayout,
            ),
          ),
        )
        .toList();
    if (children.length == 0)
      children.add(
        Expanded(
          child: Placeholder(color: widget.frame.color),
        ),
      );

    if (widget.frame.layout == FrameLayout.VERTICAL) {
      dragTargetChild = Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    } else {
      dragTargetChild = Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }
    if (widget.frame.childFrames.length == 0) {
      return LayoutBuilder(
        builder: (context, constraints) => Draggable(
          child: Card(
            color: Motif.lightBackground,
            child: DragTarget(
              builder: (context, candidateList, rejectedData) {
                if (candidateList.length > 0) {
                  return Stack(
                    children: [
                      dragTargetChild,
                      _getDropIndicator(
                          constraints, candidateList[0]?.color ?? Colors.green),
                    ],
                  );
                }
                return dragTargetChild;
              },
              onWillAccept: (dynamic value) {
                return value != widget.frame;
              },
              onAcceptWithDetails: (value) => onAcceptDrag(value),
              onMove: _onDragMove,
            ),
          ),
          feedback: Transform.translate(
            offset: Offset(
              -constraints.maxWidth / 2,
              -constraints.maxHeight / 2,
            ),
            child: Container(
              alignment: Alignment.center,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Placeholder(
                color: widget.frame.color,
              ),
            ),
          ),
          feedbackOffset: Offset.zero,
          data: widget.frame as dynamic,
          dragAnchor: DragAnchor.pointer,
        ),
      );
    } else {
      return dragTargetChild;
    }
  }
}
