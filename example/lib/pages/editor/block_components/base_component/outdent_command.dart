import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final CommandShortcutEvent myOutdentCommand = CommandShortcutEvent(
  key: 'outdent',
  getDescription: () => AppFlowyEditorL10n.current.cmdOutdent,
  command: 'shift+tab',
  handler: _outdentCommandHandler,
);

CommandShortcutEventHandler _outdentCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }
  final node = editorState.getNodeAtPath(selection.end.path);

  if (node == null || !indentableBlockTypes.contains(node.type)) {
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  // case node is paragraph
  if (node.type == ParagraphBlockKeys.type && node.indent > 0) {
    final path = node.path;
    final transaction = editorState.transaction
      ..insertNode(
        path,
        node.copyWith(indent: node.indent - 1),
      )
      ..deleteNode(node)
      ..afterSelection = selection;
    editorState.apply(transaction);
    return KeyEventResult.handled;
  }

  final parent = node.parent;
  final parentDelta = parent?.delta;

  if (parent == null ||
      parentDelta == null ||
      !indentableBlockTypes.contains(parent.type) ||
      node.path.length == 1) {
    //  if the current node is having a path which is of size 1.
    //  for example [0], then that means, it is not indented
    //  thus we ignore this event.
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  // case parent has empty text
  if (parentDelta.isEmpty) {
    final path = node.path.sublist(0, node.path.length - 1);
    final afterSelection = Selection(
      start: selection.start.copyWith(path: path),
      end: selection.end.copyWith(path: path),
    );
    final transaction = editorState.transaction
      ..insertNode(path, node, deepCopy: true)
      ..deleteNode(parent)
      ..afterSelection = afterSelection;
    editorState.apply(transaction);

    return KeyEventResult.handled;
  }

  final path = node.path.sublist(0, node.path.length - 1)..last += 1;
  final afterSelection = Selection(
    start: selection.start.copyWith(path: path),
    end: selection.end.copyWith(path: path),
  );
  final transaction = editorState.transaction
    ..deleteNode(node)
    ..insertNode(path, node, deepCopy: true)
    ..afterSelection = afterSelection;
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
