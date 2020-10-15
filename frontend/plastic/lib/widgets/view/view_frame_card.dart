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

  void _insertFrame(Frame insertee, Edge edge) {
    Frame parent;
    if (widget.frame.parent == null) {
      parent = widget.frame;
    } else {
      parent = widget.frame.parent;
    }
    if (parent.layout == FrameLayout.VERTICAL) {
      if (edge == Edge.Top || edge == Edge.Bottom) {
        var insertIndex = parent.childFrames.indexOf(widget.frame);
        if (parent == widget.frame) insertIndex = 0;
        insertIndex += edge == Edge.Bottom ? 1 : 0;

        if (parent.childFrames.length == 0) {
          parent.widget = null;
          parent.childFrames.add(
            Frame(
              parent: parent,
              layout: FrameLayout.HORIZONTAL,
              widget: widget.frame.widget,
            ),
          );
          widget.frame.widget = null;
        }
        insertee?.layout = FrameLayout.HORIZONTAL;
        // insertee?.parent?.childFrames?.remove(insertee);
        parent.childFrames.insert(
          insertIndex,
          insertee ??
              Frame(
                parent: parent,
                layout: FrameLayout.HORIZONTAL,
              ),
        );
      } else {
        if (widget.frame == parent) {
          parent.layout = FrameLayout.HORIZONTAL;
          parent.childFrames.add(Frame(
            layout: FrameLayout.VERTICAL,
            parent: parent,
            widget: widget.frame.widget,
          ));
          widget.frame.widget = null;
          insertee?.layout = FrameLayout.VERTICAL;
          // insertee?.parent?.childFrames?.remove(insertee);
          parent.childFrames.add(insertee ??
              Frame(
                layout: FrameLayout.VERTICAL,
                parent: parent,
              ));
        } else {
          var proxyFrame =
              Frame(parent: parent, layout: FrameLayout.HORIZONTAL);
          proxyFrame.widget = null;
          var index = parent.childFrames.indexOf(widget.frame);
          parent.childFrames[index] = proxyFrame;
          proxyFrame.childFrames.add(Frame(
            parent: proxyFrame,
            layout: widget.frame.layout,
            // childFrames: widget.frame.childFrames,
            widget: widget.frame.widget,
          ));
          widget.frame.widget = null;
          insertee?.layout = FrameLayout.VERTICAL;
          // insertee?.parent?.childFrames?.remove(insertee);
          proxyFrame.childFrames.insert(
              edge == Edge.Right ? 1 : 0,
              insertee ??
                  Frame(
                    parent: proxyFrame,
                    layout: FrameLayout.VERTICAL,
                  ));
        }
      }
    } else {
      if (edge == Edge.Left || edge == Edge.Right) {
        var insertIndex = parent.childFrames.indexOf(widget.frame);
        if (parent == widget.frame) insertIndex = 0;
        insertIndex += edge == Edge.Right ? 1 : 0;

        if (parent.childFrames.length == 0) {
          parent.widget = null;
          parent.childFrames.add(
            Frame(
              parent: parent,
              layout: FrameLayout.VERTICAL,
              widget: widget.frame.widget,
            ),
          );
          widget.frame.widget = null;
        }
        insertee?.layout = FrameLayout.VERTICAL;
        // insertee?.parent?.childFrames?.remove(insertee);
        parent.childFrames.insert(
          insertIndex,
          insertee ??
              Frame(
                parent: parent,
                layout: FrameLayout.VERTICAL,
              ),
        );
      } else {
        if (widget.frame == parent) {
          parent.layout = FrameLayout.VERTICAL;
          parent.childFrames.add(Frame(
            layout: FrameLayout.HORIZONTAL,
            parent: parent,
            widget: widget.frame.widget,
          ));
          widget.frame.widget = null;
          // insertee?.parent?.childFrames?.remove(insertee);
          parent.childFrames.add(insertee ??
              Frame(
                layout: FrameLayout.HORIZONTAL,
                parent: parent,
              ));
        } else {
          var proxyFrame = Frame(parent: parent, layout: FrameLayout.VERTICAL);
          proxyFrame.widget = null;
          var index = parent.childFrames.indexOf(widget.frame);
          parent.childFrames[index] = proxyFrame;
          proxyFrame.childFrames.add(Frame(
            parent: proxyFrame,
            layout: widget.frame.layout,
            // childFrames: widget.frame.childFrames,
            widget: widget.frame.widget,
          ));
          widget.frame.widget = null;
          insertee?.layout = FrameLayout.HORIZONTAL;
          insertee?.parent?.childFrames?.remove(insertee);
          proxyFrame.childFrames.insert(
              edge == Edge.Bottom ? 1 : 0,
              insertee ??
                  Frame(
                    parent: proxyFrame,
                    layout: FrameLayout.HORIZONTAL,
                  ));
        }
      }
    }
  }

  void onAcceptDrag(DragTargetDetails<dynamic> value) {
    var edge = _getEdge(value.offset);
    // if (value.data is Frame) {
    //   _insertFrame(value.data, widget.frame, edge);
    // } else {
    //   _insertFrame(null, widget.frame, edge);
    // }
    if (value.data is Frame) {
      var valueAsFrame = value.data as Frame;
      // var parent = valueAsFrame.parent;
      // if (parent.childFrames.length <= 1) {
      //   parent.parent?.childFrames?.remove(parent);
      // }
      // valueAsFrame.parent.childFrames
      //     .removeWhere((f) => f.widget == valueAsFrame.widget);
      valueAsFrame.trimFromTree(valueAsFrame);
    }

    _insertFrame(value.data, edge);
    // if (value.data is Frame) {
    //   var frame = value.data as Frame;
    //   var index = widget.frame.parent?.childFrames?.indexOf(widget.frame);
    //   if (index == null) {
    //     widget.frame.childFrames.add(frame);
    //     frame.parent = widget.frame;
    //     widget.rebuildLayout();
    //     return;
    //   }
    //   if (edge == Edge.Right || edge == Edge.Bottom) index++;
    //   switch (edge) {
    //     case Edge.Left:
    //     case Edge.Right:
    //       if (widget.frame.parent.layout == FrameLayout.HORIZONTAL) {
    //         widget.frame.parent.childFrames.insert(index, frame);
    //         frame.parent.childFrames.remove(frame);
    //         frame.parent = widget.frame.parent;
    //       } else {
    //         var proxy = Frame(
    //             parent: widget.frame.parent, layout: FrameLayout.HORIZONTAL);
    //         widget.frame.parent.childFrames.insert(index, proxy);
    //         frame.parent.childFrames.remove(frame);
    //         frame.parent = widget.frame.parent;
    //         proxy.childFrames.add(frame);
    //       }
    //       break;
    //     case Edge.Top:
    //     case Edge.Bottom:
    //       if (widget.frame.parent.layout == FrameLayout.VERTICAL) {
    //         widget.frame.parent.childFrames.insert(index, frame);
    //         frame.parent.childFrames.remove(frame);
    //         frame.parent = widget.frame.parent;
    //       } else {
    //         var proxy = Frame(
    //             parent: widget.frame.parent, layout: FrameLayout.VERTICAL);
    //         widget.frame.parent.childFrames.insert(index, proxy);
    //         frame.parent.childFrames.remove(frame);
    //         frame.parent = widget.frame.parent;
    //         proxy.childFrames.add(frame);
    //       }
    //       break;
    //   }
    // } else {
    //   Frame parent;
    //   if (widget.frame.parent == null) {
    //     parent = widget.frame;
    //   } else {
    //     parent = widget.frame.parent;
    //   }
    //   if (parent.layout == FrameLayout.VERTICAL) {
    //     if (edge == Edge.Top || edge == Edge.Bottom) {
    //       var insertIndex = parent.childFrames.indexOf(widget.frame);
    //       insertIndex += edge == Edge.Bottom ? 1 : 0;
    //       if (widget.frame == parent) insertIndex = 0;

    //       if (parent.childFrames.length == 0) {
    //         parent.childFrames.insert(
    //           insertIndex,
    //           Frame(
    //             parent: parent,
    //             layout: FrameLayout.HORIZONTAL,
    //             widget: widget.frame.widget,
    //           ),
    //         );
    //         widget.frame.widget = null;
    //       }
    //       parent.childFrames.insert(
    //         insertIndex,
    //         Frame(
    //           parent: parent,
    //           layout: FrameLayout.HORIZONTAL,
    //         ),
    //       );
    //     } else {
    //       if (widget.frame == parent) {
    //         parent.layout = FrameLayout.HORIZONTAL;
    //         parent.childFrames.add(Frame(
    //           layout: FrameLayout.VERTICAL,
    //           parent: parent,
    //           widget: widget.frame.widget,
    //         ));
    //         widget.frame.widget = null;
    //         parent.childFrames.add(Frame(
    //           layout: FrameLayout.VERTICAL,
    //           parent: parent,
    //         ));
    //       } else {
    //         var proxyFrame =
    //             Frame(parent: parent, layout: FrameLayout.HORIZONTAL);
    //         var index = parent.childFrames.indexOf(widget.frame);
    //         parent.childFrames[index] = proxyFrame;
    //         var newFrame =
    //             Frame(parent: proxyFrame, layout: FrameLayout.VERTICAL);
    //         proxyFrame.childFrames.add(Frame(
    //           parent: proxyFrame,
    //           layout: widget.frame.layout,
    //           childFrames: widget.frame.childFrames,
    //           widget: widget.frame.widget,
    //         ));
    //         widget.frame.widget = null;
    //         proxyFrame.childFrames.insert(edge == Edge.Right ? 1 : 0, newFrame);
    //       }
    //     }
    //   } else {
    //     if (edge == Edge.Left || edge == Edge.Right) {
    //       var insertIndex = parent.childFrames.indexOf(widget.frame);
    //       insertIndex += edge == Edge.Right ? 1 : 0;
    //       if (widget.frame == parent) insertIndex = 0;

    //       if (parent.childFrames.length == 0) {
    //         parent.childFrames.insert(
    //           insertIndex,
    //           Frame(
    //             parent: parent,
    //             layout: FrameLayout.VERTICAL,
    //             widget: widget.frame.widget,
    //           ),
    //         );
    //         widget.frame.widget = null;
    //       }
    //       parent.childFrames.insert(
    //         insertIndex,
    //         Frame(
    //           parent: parent,
    //           layout: FrameLayout.VERTICAL,
    //         ),
    //       );
    //     } else {
    //       if (widget.frame == parent) {
    //         parent.layout = FrameLayout.VERTICAL;
    //         parent.childFrames.add(Frame(
    //           layout: FrameLayout.HORIZONTAL,
    //           parent: parent,
    //           widget: widget.frame.widget,
    //         ));
    //         widget.frame.widget = null;
    //         parent.childFrames.add(Frame(
    //           layout: FrameLayout.HORIZONTAL,
    //           parent: parent,
    //         ));
    //       } else {
    //         var proxyFrame =
    //             Frame(parent: parent, layout: FrameLayout.VERTICAL);
    //         var index = parent.childFrames.indexOf(widget.frame);
    //         parent.childFrames[index] = proxyFrame;
    //         var newFrame =
    //             Frame(parent: proxyFrame, layout: FrameLayout.HORIZONTAL);
    //         proxyFrame.childFrames.add(Frame(
    //           parent: proxyFrame,
    //           layout: widget.frame.layout,
    //           childFrames: widget.frame.childFrames,
    //           widget: widget.frame.widget,
    //         ));
    //         widget.frame.widget = null;
    //         proxyFrame.childFrames
    //             .insert(edge == Edge.Bottom ? 1 : 0, newFrame);
    //       }
    //     }
    //   }
    // }
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
        builder: (context, constraints) => Draggable(
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
          dragAnchor: DragAnchor.pointer,
        ),
      );
    } else {
      return dragTargetChild;
    }
  }
}
