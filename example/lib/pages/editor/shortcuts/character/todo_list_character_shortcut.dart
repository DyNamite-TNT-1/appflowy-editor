import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/editor.dart';

/// Insert a new block after the todo list block.
///
/// - support
///   - mobile
///
CharacterShortcutEvent $insertNewLineAfterTodoList = CharacterShortcutEvent(
  key: 'insert new block after todo list',
  character: '\n',
  handler: (editorState) async => await $insertNewLineInType(
    editorState,
    'todo_list',
    attributes: {
      TodoListBlockKeys.checked: false,
    },
  ),
);
