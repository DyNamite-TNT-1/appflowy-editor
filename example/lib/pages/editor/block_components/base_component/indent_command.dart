import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final indentableBlockTypes = {
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
  ParagraphBlockKeys.type,
};

const maxDepth = 5;

final CommandShortcutEvent myIndentCommand = CommandShortcutEvent(
  key: 'indent',
  getDescription: () => AppFlowyEditorL10n.current.cmdIndent,
  command: 'tab',
  handler: _indentCommandHandler,
);

CommandShortcutEventHandler _indentCommandHandler = (editorState) {
  if (!isIndentPermitted(editorState, maxDepth)) {
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null || !indentableBlockTypes.contains(node.type)) {
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  //case node is paragraph
  if (node.type == ParagraphBlockKeys.type) {
    final path = node.path;
    final transaction = editorState.transaction
      ..insertNode(
        path,
        node.copyWith(indent: node.indent + 1),
        deepCopy: true,
      )
      ..deleteNode(node)
      ..afterSelection = selection;
    editorState.apply(transaction);
    return KeyEventResult.handled;
  }

  //case previous is empty => make new empty paragraph
  final previous = node.previous;
  if (previous == null) {
    final paraParent = paragraphNode();
    final newParent = paraParent.copyWith(type: node.type);
    final insertParentAt = node.path;
    final moveChildAt = insertParentAt + [0];

    final afterSelection = Selection(
      start: selection.start.copyWith(path: moveChildAt),
      end: selection.end.copyWith(path: moveChildAt),
    );
    var transaction = editorState.transaction
      ..insertNode(insertParentAt, newParent, deepCopy: true)
      ..moveNode(moveChildAt, node)
      ..afterSelection = afterSelection;
    editorState.apply(transaction);
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  final path = previous.path + [previous.children.length];
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

/// Checks if the current node's indentation is permitted based on the given max depth.
bool isIndentPermitted(EditorState editorState, int maxDepth) {
  final selection = editorState.selection;

  if (selection == null || !selection.isSingle) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);

  if (node == null || !indentableBlockTypes.contains(node.type)) {
    return false;
  }

  var totalDepth = 0;

  // If current node is paragraph
  if (node.type == ParagraphBlockKeys.type) {
    // Calculate the total depth, considering the current indent and adding 1
    totalDepth = node.indent + 1;
    // Check if the total depth exceeds the maximum permitted depth
    return totalDepth <= maxDepth;
  }

  // For other block types, calculate the total depth based on the node's path length
  // For example [0, 0, 0, 0, 0], then that mean, it is 4th depth
  totalDepth = node.path.length - 1 + 1;
  // Check if the total depth exceeds the maximum permitted depth
  return totalDepth <= maxDepth;
}
