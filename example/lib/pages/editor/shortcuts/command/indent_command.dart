import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final indentableBlockTypes = {
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
  ParagraphBlockKeys.type,
};

const maxDepth = 5;

/// Indent indentable nodes.
///
/// - support
///   - mobile
///
final CommandShortcutEvent $indentCommand = CommandShortcutEvent(
  key: 'indent',
  getDescription: () => AppFlowyEditorL10n.current.cmdIndent,
  command: 'tab',
  handler: _indentCommandHandler,
);

CommandShortcutEventHandler _indentCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection);

  if (nodes.isEmpty) {
    return KeyEventResult.handled;
  }

  final transaction = editorState.transaction;
  bool allowApply = false;

  for (final node in nodes) {
    if (!isIndentPermitted(node, maxDepth)) {
      continue;
    }

    allowApply = true;

    transaction
      ..insertNode(node.path, node.copyWith(indent: node.indent + 1))
      ..deleteNode(node)
      ..afterSelection = transaction.beforeSelection;
  }

  if (allowApply) {
    editorState.apply(transaction);
  }

  return KeyEventResult.handled;
};

/// Checks if the current node's indentation is permitted based on the given max depth.
bool isIndentPermitted(Node node, int maxDepth) {
  if (!indentableBlockTypes.contains(node.type)) {
    return false;
  }

  var totalDepth = 0;

  // Calculate the total depth, considering the current indent and adding 1
  totalDepth = node.indent + 1;
  // Check if the total depth exceeds the maximum permitted depth
  return totalDepth <= maxDepth;
}
