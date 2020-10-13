import 'package:flutter/cupertino.dart';

class LayoutUtils {
  static Rect globalPaintBounds(BuildContext context) {
    final renderObject = context.findRenderObject();
    var translation = renderObject?.getTransformTo(null)?.getTranslation();
    if (translation != null && renderObject.paintBounds != null) {
      return renderObject.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
