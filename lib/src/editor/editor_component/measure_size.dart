import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onSizeChange;

  MeasureSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    Size? newSize = child?.size;
    if (oldSize == newSize || newSize == null) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const MeasureSize({
    super.key,
    required this.onSizeChange,
    required Widget super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onSizeChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onSizeChange = onSizeChange;
  }
}
