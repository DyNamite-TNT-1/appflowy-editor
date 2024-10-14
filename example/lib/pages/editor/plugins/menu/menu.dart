import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'dart:core';

class MenuTextMatch {
  final int leadOffset;
  final String matchingString;
  final String replaceableString;

  MenuTextMatch(this.leadOffset, this.matchingString, this.replaceableString);
}

class MenuOption {
  final String key;
  MenuOption({
    required this.key,
  });
}

class ItemProps {
  final void Function(MenuOption option) selectOptionAndCleanUp;
  final List<MenuOption> options;

  ItemProps({
    required this.selectOptionAndCleanUp,
    required this.options,
  });
}

class MenuResolution {
  final MenuTextMatch match;
  final Rect rect;

  MenuResolution({
    required this.match,
    required this.rect,
  });
}

typedef TriggerFn = MenuTextMatch? Function(String);
typedef MenuRenderFn = Widget Function(
  ItemProps itemProps,
  String? matchingString,
);

class MenuPlugin extends StatefulWidget {
  const MenuPlugin({
    super.key,
    required this.editorState,
    required this.onQueryChange,
    required this.onSelectOption,
    required this.options,
    required this.menuRenderFn,
    required this.triggerFn,
    this.onOpen,
    this.onClose,
  });

  final void Function(String? matchingString) onQueryChange;
  final EditorState editorState;
  final TriggerFn triggerFn;
  final void Function(
    MenuOption option,
    Node nodeToReplace,
    void Function() closeMenu,
    MenuTextMatch match,
  ) onSelectOption;
  final List<MenuOption> options;
  final MenuRenderFn menuRenderFn;
  final void Function(MenuResolution)? onOpen;
  final void Function()? onClose;

  @override
  State<MenuPlugin> createState() => _MenuPluginState();
}

class _MenuPluginState extends State<MenuPlugin> {
  EditorState get editorState => widget.editorState;

  OverlayEntry? _overlayEntry;

  Offset _offset = Offset.zero;
  Alignment _alignment = Alignment.topLeft;

  Offset get offset {
    return _offset;
  }

  Alignment get alignment {
    return _alignment;
  }

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(MenuPlugin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editorState != oldWidget.editorState) {
      editorState.selectionNotifier.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    final selection = editorState.selection;
    if (selection == null) {
      return;
    }

    if (!selection.isCollapsed) {
      dismiss();
      return;
    }

    final position = selection.start;

    final currentNode = editorState.getNodeAtPath(position.path);
    final delta = currentNode?.delta;

    if (currentNode == null || delta == null) {
      dismiss();
      return;
    }

    final currentPlainText = delta.toPlainText();
    final context = currentNode.context;

    final match = widget.triggerFn(currentPlainText);
    widget.onQueryChange(match?.matchingString);

    if (match != null && context != null && context.mounted) {
      final selectionRect =
          editorState.findRectWithOffset(offset: match.leadOffset);
      if (selectionRect != null) {
        show(
          context,
          currentNode,
          MenuResolution(match: match, rect: selectionRect),
        );
      }
    } else {
      dismiss();
    }
  }

  void _selectOptionAndCleanUp(
    MenuOption selectedOption,
    Node nodeToReplace,
    MenuResolution resolution,
  ) {
    widget.onSelectOption(
      selectedOption,
      nodeToReplace,
      dismiss,
      resolution.match,
    );
  }

  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> show(
    BuildContext context,
    Node node,
    MenuResolution resolution,
  ) async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showOverlay(context, node, resolution);
      completer.complete();
    });
    return completer.future;
  }

  void _showOverlay(
    BuildContext context,
    Node node,
    MenuResolution resolution,
  ) {
    dismiss();

    _calculateMenuOffset(resolution.rect);
    final (left, top, right, bottom) = getPosition();

    final editorHeight = editorState.renderBox!.size.height;
    final editorWidth = editorState.renderBox!.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => SizedBox(
        width: editorWidth,
        height: editorHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            dismiss();
          },
          child: Stack(
            children: [
              Positioned(
                top: top,
                bottom: bottom,
                left: left,
                right: right,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        spreadRadius: 1,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      minWidth: 200,
                      maxWidth: 200,
                    ),
                    child: widget.menuRenderFn(
                      ItemProps(
                        selectOptionAndCleanUp: (MenuOption option) {
                          _selectOptionAndCleanUp(option, node, resolution);
                        },
                        options: widget.options,
                      ),
                      resolution.match.matchingString,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _calculateMenuOffset(Rect rect) {
    const menuHeight = 100.0;
    const menuOffset = Offset(0, 10);
    final editorOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final editorHeight = editorState.renderBox!.size.height;
    final editorWidth = editorState.renderBox!.size.width;

    // show below default
    _alignment = Alignment.topLeft;
    final bottomRight = rect.bottomRight;
    final topRight = rect.topRight;
    var offset = bottomRight + menuOffset;
    _offset = Offset(
      offset.dx,
      offset.dy,
    );

    // show above
    if (offset.dy + menuHeight >= editorOffset.dy + editorHeight) {
      offset = topRight - menuOffset;
      _alignment = Alignment.bottomLeft;

      _offset = Offset(
        offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      );
    }

    // show on left
    if (_offset.dx - editorOffset.dx > editorWidth / 2) {
      _alignment = _alignment == Alignment.topLeft
          ? Alignment.topRight
          : Alignment.bottomRight;

      _offset = Offset(
        editorWidth - _offset.dx + editorOffset.dx,
        _offset.dy,
      );
    }
  }

  (double? left, double? top, double? right, double? bottom) getPosition() {
    double? left, top, right, bottom;
    switch (alignment) {
      case Alignment.topLeft:
        left = offset.dx;
        top = offset.dy;
        break;
      case Alignment.bottomLeft:
        left = offset.dx;
        bottom = offset.dy;
        break;
      case Alignment.topRight:
        right = offset.dx;
        top = offset.dy;
        break;
      case Alignment.bottomRight:
        right = offset.dx;
        bottom = offset.dy;
        break;
    }

    return (left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

extension on EditorState {
  Rect? findRectWithOffset({int? offset}) {
    final selection = this.selection;
    if (selection == null) {
      return null;
    }

    final node = getNodeAtPath(selection.end.path);
    if (node == null) {
      return null;
    }
    final selectable = node.selectable;
    if (selectable != null) {
      final rect = selectable.getCursorRectInPosition(
        offset != null ? selection.end.copyWith(offset: offset) : selection.end,
        shiftWithBaseOffset: true,
      );
      if (rect != null) {
        return selectable.transformRectToGlobal(
          rect,
          shiftWithBaseOffset: true,
        );
      }
    }
    return null;
  }
}
