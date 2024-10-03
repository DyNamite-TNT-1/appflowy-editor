import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

Future<bool> $insertNewLineInType(
  EditorState editorState,
  String type, {
  Attributes attributes = const {},
}) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node?.type != type || delta == null) {
    return false;
  }

  if (selection.startIndex == 0 && delta.isEmpty) {
    // clear the style
    if (node != null && node.path.length > 1) {
      return KeyEventResult.ignored != outdentCommand.execute(editorState);
    }
    return KeyEventResult.ignored !=
        convertToParagraphCommand.execute(editorState);
  }

  // keep current indent
  final currentIndent = node?.indent;

  await editorState.insertNewLine(
    nodeBuilder: (node) => node.copyWith(
      type: type,
      indent: currentIndent,
      attributes: {
        ...node.attributes,
        ...attributes,
      },
    ),
  );
  return true;
}
