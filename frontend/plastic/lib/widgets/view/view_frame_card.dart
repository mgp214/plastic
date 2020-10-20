import 'dart:developer';

import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plastic/model/motif.dart';
import 'package:plastic/model/view/frame.dart';
import 'package:plastic/utility/layout_utils.dart';
import 'package:plastic/widgets/view/frame_resize_handle.dart';

enum Edge { Left, Right, Top, Bottom }
FrameLayout edgeDirection(Edge edge) =>
    (edge == Edge.Left || edge == Edge.Right)
        ? FrameLayout.HORIZONTAL
        : FrameLayout.VERTICAL;

class ViewFrameCard extends StatefulWidget {
  final Frame frame;
  final Function(bool) rebuildLayout;
  final Function(Frame) resetLayout;

  const ViewFrameCard(
      {Key key,
      @required this.frame,
      @required this.rebuildLayout,
      @required this.resetLayout})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewFrameCardState();
}

class ViewFrameCardState extends State<ViewFrameCard> {
  Edge _activeEdge;
  Frame _rootCopy;
  Offset _previousScale;
  double _initialScale;

  void _insertProxyFrame(
      Frame parent, int index, Frame child, bool afterExisting) {
    log('inserting proxy in frame $parent at index $index.');
    if (afterExisting) {
      log('proxy will have child $child inserted after old content ${widget.frame}');
    }

    FrameLayout proxyLayout = opposite(parent.layout);

    var proxyFrame = Frame(parent: parent, layout: proxyLayout);
    proxyFrame.widget = null;

    proxyFrame.childFrames.add(child);

    var existing = Frame(
      layout: parent.layout,
      widget: widget.frame.widget,
      parent: proxyFrame,
    );
    if (afterExisting) {
      proxyFrame.childFrames.add(existing);
    } else {
      proxyFrame.childFrames.insert(0, existing);
    }

    parent.widget = null;

    child.parent?.childFrames?.remove(child);
    child.parent = proxyFrame;
    child.layout = parent.layout;

    parent.childFrames[index] = proxyFrame;
  }

  void _insertFrameAtRoot(Frame root, Frame insertee, Edge edge) {
    if (root.childFrames.length == 0) {
      root.childFrames.add(
        Frame(
          layout: opposite(root.layout),
          widget: root.widget,
          parent: root,
        ),
      );
      root.widget = null;
    }
    insertee.parent = root;
    switch (edge) {
      case Edge.Left:
        root.layout = FrameLayout.HORIZONTAL;
        root.childFrames.insert(0, insertee);
        break;
      case Edge.Right:
        root.layout = FrameLayout.HORIZONTAL;
        root.childFrames.add(insertee);
        break;
      case Edge.Top:
        root.layout = FrameLayout.VERTICAL;
        root.childFrames.insert(0, insertee);
        break;
      case Edge.Bottom:
        root.layout = FrameLayout.VERTICAL;
        root.childFrames.add(insertee);
        break;
    }
  }

  void _insertFrame(Frame insertee, Edge edge) {
    insertee = insertee ?? Frame();

    if (widget.frame.parent == null) {
      _insertFrameAtRoot(widget.frame, insertee, edge);
      return;
    }

    var index = widget.frame.parent.childFrames.indexOf(widget.frame);
    bool after = (edge == Edge.Left || edge == Edge.Top);

    if (edgeDirection(edge) == widget.frame.parent.layout) {
      log('newly inserted frame $insertee added to ${widget.frame} with the grain');
      insertee.layout = opposite(widget.frame.parent.layout);
      index += after ? 0 : 1;
      insertee.parent = widget.frame.parent;
      if (index == widget.frame.parent.childFrames.length)
        widget.frame.parent.childFrames.add(insertee);
      else
        widget.frame.parent.childFrames.insert(index, insertee);
    } else {
      log('newly inserted frame $insertee added to ${widget.frame} requires proxy');
      _insertProxyFrame(widget.frame.parent, index, insertee, after);
    }
  }

  void onAcceptDrag(DragTargetDetails<dynamic> value) {
    var edge = _getEdge(value.offset);

    widget.frame.trimFromTree(value.data);
    _insertFrame(value.data, edge);
    log('AFTER DRAG ACCEPT:');
    log(widget.frame.root.prettyPrint());

    widget.rebuildLayout(false);
  }

  Edge _getEdge(Offset offset) {
    var bounds = LayoutUtils.globalPaintBounds(context);
    var size = Size(bounds.right - bounds.left, bounds.bottom - bounds.top);
    var center = Offset(
      bounds.left + size.width / 2,
      bounds.top + size.height / 2,
    );
    var relOffset = Offset(
      (offset.dx - center.dx) / size.width,
      (offset.dy - center.dy) / size.height,
    );
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

  double _getLength() {
    var length = widget.frame.layout == FrameLayout.HORIZONTAL
        ? context.size.width
        : context.size.height;
    length -= (widget.frame.childFrames.length - 1) * 21;
    return length;
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

    var children = List<Widget>();
    for (var i = 0; i < widget.frame.childFrames.length; i++) {
      if (i > 0) {
        children.add(
          FrameResizeHandle(
            before: widget.frame.childFrames[i - 1],
            after: widget.frame.childFrames[i],
            rebuildLayout: () => widget.rebuildLayout(false),
            parentLayout: widget.frame.layout,
            getParentLength: _getLength,
          ),
        );
      }
      var child = widget.frame.childFrames[i];
      children.add(
        Expanded(
          flex: (child.flex * Frame.flexResolution).round(),
          child: ViewFrameCard(
            frame: child,
            rebuildLayout: widget.rebuildLayout,
            resetLayout: widget.resetLayout,
          ),
        ),
      );
    }
    if (children.length == 0)
      children.add(
        Expanded(
          child: Stack(
            children: [
              Placeholder(color: widget.frame.widget.color),
              Center(
                child: Text(
                  (widget.frame.layout == FrameLayout.VERTICAL ? 'V' : 'H') +
                      '-${widget.frame.widget.id}',
                  style: Motif.contentStyle(Sizes.Content, Motif.black),
                ),
              ),
            ],
          ),
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
        builder: (context, constraints) => LongPressDraggable(
          maxSimultaneousDrags: widget.frame.isRoot ? 0 : 1,
          child: Card(
            color: Motif.lightBackground,
            child: DragTarget(
              builder: (context, candidateList, rejectedData) {
                if (candidateList.length > 0) {
                  return Stack(
                    children: [
                      dragTargetChild,
                      _getDropIndicator(constraints,
                          candidateList[0]?.widget?.color ?? Colors.green),
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
                color: widget.frame.widget.color,
              ),
            ),
          ),
          feedbackOffset: Offset.zero,
          data: widget.frame as dynamic,
          onDragStarted: () {
            _rootCopy = Frame.copy(widget.frame.root);
            widget.frame.trimFromTree(widget.frame);
            widget.rebuildLayout(true);
          },
          onDraggableCanceled: (v, o) {
            widget.resetLayout(_rootCopy);
          },
          dragAnchor: DragAnchor.pointer,
        ),
      );
    } else {
      return dragTargetChild;
    }
  }
}
