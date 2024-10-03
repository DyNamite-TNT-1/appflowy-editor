import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Outdent outdentable nodes.
///
/// - support
///   - mobile
///
final CommandShortcutEvent $outdentCommand = CommandShortcutEvent(
  key: 'outdent',
  getDescription: () => AppFlowyEditorL10n.current.cmdOutdent,
  command: 'shift+tab',
  handler: _outdentCommandHandler,
);

CommandShortcutEventHandler _outdentCommandHandler = (editorState) {
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
    if (!isOutdentPermitted(node)) {
      continue;
    }

    allowApply = true;

    transaction
      ..insertNode(node.path, node.copyWith(indent: node.indent - 1))
      ..deleteNode(node)
      ..afterSelection = transaction.beforeSelection;
  }

  if (allowApply) {
    editorState.apply(transaction);
  }

  return KeyEventResult.handled;
};

bool isOutdentPermitted(Node node) {
  if (!indentableBlockTypes.contains(node.type)) {
    return false;
  }
  return node.indent > 0;
}
