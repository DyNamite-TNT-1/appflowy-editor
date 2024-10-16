import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/desktop_scroll_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/mobile_scroll_service.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/utils/keyboard_height_observer.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    super.key,
    required this.editorScrollController,
    required this.child,
  });

  final EditorScrollController editorScrollController;

  final Widget child;

  @override
  State<ScrollServiceWidget> createState() => _ScrollServiceWidgetState();
}

class _ScrollServiceWidgetState extends State<ScrollServiceWidget>
    implements AppFlowyScrollService {
  final _forwardKey =
      GlobalKey(debugLabel: 'forward_to_platform_scroll_service');
  AppFlowyScrollService get forward =>
      _forwardKey.currentState as AppFlowyScrollService;

  late EditorState editorState = context.read<EditorState>();

  @override
  late ScrollController scrollController = ScrollController();

  double offset = 0;

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.editorScrollController,
      child: Builder(
        builder: (context) {
          if (PlatformExtension.isDesktopOrWeb) {
            return _buildDesktopScrollService(context);
          } else if (PlatformExtension.isMobile) {
            return _buildMobileScrollService(context);
          }
          throw UnimplementedError();
        },
      ),
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
  ) {
    return MobileScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  void _onSelectionChanged() {
    // should auto scroll after the cursor or selection updated.
    final selection = editorState.selection;
    if (selection == null ||
        [SelectionUpdateReason.selectAll, SelectionUpdateReason.searchHighlight]
            .contains(editorState.selectionUpdateReason)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final selectionRect = editorState.selectionRects();
      if (selectionRect.isEmpty) {
        return;
      }

      final endTouchPoint = selectionRect.last.centerRight;

      if (PlatformExtension.isMobile) {
        // soft keyboard
        // workaround: wait for the soft keyboard to show up

        // OLD CODE:
        // This code attempts to determine whether to wait for the keyboard
        // to show up based solely on the previous keyboard height.
        // It does not account for potential changes in keyboard height
        // after the selection update.
        // final duration = KeyboardHeightObserver.currentKeyboardHeight == 0
        //     ? const Duration(milliseconds: 250)
        //     : Duration.zero;
        // return Future.delayed(duration, () {
        //   startAutoScroll(
        //     endTouchPoint,
        //     edgeOffset: editorState.autoScrollEdgeOffset,
        //     duration: Duration.zero,
        //   });
        // });

        // NEW CODE:
        // The new approach first checks if the keyboard is currently shown
        // by comparing the current keyboard height. This allows for a more
        // accurate delay calculation and ensures that the scroll position
        // is adjusted based on the actual keyboard height at the time of
        // selection change.
        final isShowingKeyboard =
            KeyboardHeightObserver.currentKeyboardHeight != 0;
        final duration = !isShowingKeyboard
            ? const Duration(milliseconds: 250)
            : Duration.zero;

        // Delay the execution based on whether the keyboard is shown or not.
        // To wait keyboard showing up.
        return Future.delayed(duration, () {
          // If isShowingKeyboard is false, the keyboard was not previously visible.
          // However, it is now displayed, so we need to adjust the end touch point
          // to account for the current keyboard height. This ensures that the selection
          // remains visible and is not obscured by the keyboard.
          if (!isShowingKeyboard) {
            final nextKeyboardHeight =
                KeyboardHeightObserver.currentKeyboardHeight;

            final newEndTouchPoint =
                Offset(endTouchPoint.dx, endTouchPoint.dy - nextKeyboardHeight);

            return startAutoScroll(
              newEndTouchPoint,
              edgeOffset: editorState.autoScrollEdgeOffset,
              duration: Duration.zero,
            );
          }

          // If the keyboard is showing, use the original end touch point
          // for auto-scrolling to keep the selection visible.
          startAutoScroll(
            endTouchPoint,
            edgeOffset: editorState.autoScrollEdgeOffset,
            duration: Duration.zero,
          );
        });
      } else {
        startAutoScroll(
          endTouchPoint,
          duration: Duration.zero,
        );
      }
    });
  }

  @override
  void disable() => forward.disable();

  @override
  double get dy => forward.dy;

  @override
  void enable() => forward.enable();

  @override
  double get maxScrollExtent => forward.maxScrollExtent;

  @override
  double get minScrollExtent => forward.minScrollExtent;

  @override
  double? get onePageHeight => forward.onePageHeight;

  @override
  int? get page => forward.page;

  @override
  void scrollTo(
    double dy, {
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      forward.scrollTo(dy, duration: duration);

  @override
  void jumpTo(int index) => forward.jumpTo(index);

  @override
  void jumpToTop() {
    forward.jumpToTop();
  }

  @override
  void jumpToBottom() {
    forward.jumpToBottom();
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 100,
    AxisDirection? direction,
    Duration? duration,
  }) {
    forward.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration,
    );
  }

  @override
  void stopAutoScroll() => forward.stopAutoScroll();

  @override
  void goBallistic(double velocity) => forward.goBallistic(velocity);
}
