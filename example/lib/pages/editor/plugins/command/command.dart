import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'dart:core';

const String punctuation =
    r'''\\.,\\+\\*\\?\\$\\@\\|#{}\\(\\)\\^\\-\\[\\]\\\\/!%\'"~=<>_:;''';

const String name = "r'\\b[A-Z][^\\s$punctuation]'";

const Map<String, String> documentMentionsRegex = {
  'name': name,
  'punctuation': punctuation,
};

final String punc = documentMentionsRegex['punctuation']!;

final String triggers = ['/'].join('');

final String validChars = "r'[^$triggers$punc\\s]'";

final String validJoins = "r'(?:(\\.[ |\$]| |[$punc]|)'";

const int lengthLimit = 75;

final RegExp atSignMentionsRegex = RegExp(
  "r'(^\\s|\\()([$triggers]((?:$validChars$validJoins){0,$lengthLimit}))\$'",
);

// 50 is the longest alias length limit.
const int aliasLengthLimit = 50;

final RegExp atSignMentionsRegexAliasRegex = RegExp(
  "r'(^\\s|\\()([$triggers]((?:$validChars){0,$aliasLengthLimit}))\$'",
);

class MenuTextMatch {
  final int leadOffset;
  final String matchingString;
  final String replaceableString;

  MenuTextMatch(this.leadOffset, this.matchingString, this.replaceableString);
}

MenuTextMatch? checkForSlashSignCommands(String text, int minMatchLength) {
  final match = atSignMentionsRegex.firstMatch(text) ??
      atSignMentionsRegexAliasRegex.firstMatch(text);

  if (match != null) {
    final maybeLeadingWhitespace = match.group(1) ?? '';
    final matchingString = match.group(3) ?? '';

    if (matchingString.length >= minMatchLength) {
      return MenuTextMatch(
        match.start + maybeLeadingWhitespace.length,
        matchingString,
        match.group(2) ?? '',
      );
    }
  }
  return null;
}

class CommandPlugin extends StatefulWidget {
  const CommandPlugin({super.key, required this.editorState});

  final EditorState editorState;

  @override
  State<CommandPlugin> createState() => _CommandPluginState();
}

class _CommandPluginState extends State<CommandPlugin> {
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

  // Sample list of items
  final List<String> _items = [
    'apple',
    'banana',
    'orange',
    'grape',
    'pineapple',
    'strawberry',
  ];

  @override
  void initState() {
    super.initState();

    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(CommandPlugin oldWidget) {
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

    dismiss();

    if (!selection.isCollapsed) {
      return;
    }

    final position = selection.start;

    if (position.offset == 0) {
      return;
    }

    final currentNode = editorState.getNodeAtPath(position.path);
    final delta = currentNode?.delta;

    if (currentNode == null || delta == null) {
      return;
    }

    final currentPlainText = delta.toPlainText();
    final lastWord =
        currentPlainText.substring(0, position.offset).split(' ').last;
    final context = currentNode.context;
    if (context != null && context.mounted) {
      if (lastWord.startsWith('/')) {
        show(context, lastWord.substring(1));
      }
    }
  }

  void dismiss() {
    print("dismiss?");
    _hideOverlay();
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> show(BuildContext context, String searchBy) async {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showOverlay(context, searchBy);
      completer.complete();
    });
    return completer.future;
  }

  void _showOverlay(BuildContext context, String searchBy) {
    if (_overlayEntry == null) {
      final selectionRects = editorState.selectionRects();
      if (selectionRects.isEmpty) {
        return;
      }
      calculateSelectionMenuOffset(selectionRects.first);
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
                        maxHeight: 300,
                        minWidth: 200,
                        maxWidth: 200,
                      ),
                      child: _buildOverlayContent(searchBy),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    } else {
      _overlayEntry?.markNeedsBuild();
    }
  }

  List<String> _getFilteredItems(String searchBy) {
    return _items
        .where(
          (item) => item.toLowerCase().contains(searchBy.trim().toLowerCase()),
        )
        .toList();
  }

  Widget _buildOverlayContent(String searchBy) {
    final filteredItems = _getFilteredItems(searchBy);

    return ListView(
      shrinkWrap: true,
      children: filteredItems.map((item) {
        return TextButton(
          child: Text(item),
          onPressed: () {
            dismiss();
          },
        );
      }).toList(),
    );
  }

  void calculateSelectionMenuOffset(Rect rect) {
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
