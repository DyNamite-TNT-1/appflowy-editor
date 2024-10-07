import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';

final CharacterShortcutEvent $enterInCodeBlock = CharacterShortcutEvent(
  key: 'insert new block after numbered list',
  character: '\n',
  handler: _enterInCodeBlockCommandHandler,
);

CharacterShortcutEventHandler _enterInCodeBlockCommandHandler =
    (editorState) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null || node.type != CodeBlockKeys.type) {
    return false;
  }

  final delta = node.delta;

  final lines = delta?.toPlainText().split('\n') ?? [];
  int spaces = 0;

  if (lines.isNotEmpty) {
    int index = 0;
    for (final line in lines) {
      if (index <= selection.endIndex &&
          selection.endIndex <= index + line.length) {
        final lineSpaces = line.length - line.trimLeft().length;
        spaces = lineSpaces;
        break;
      }
      index += line.length + 1;
    }
  }

  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.end.offset,
      '\n${' ' * spaces}',
    );
  await editorState.apply(transaction);
  return true;
};
