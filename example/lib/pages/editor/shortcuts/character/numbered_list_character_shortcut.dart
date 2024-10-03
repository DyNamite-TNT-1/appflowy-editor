import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/editor.dart';

/// Insert a new block after the numbered list block.
///
/// - support
///   - mobile
///
CharacterShortcutEvent $insertNewLineAfterNumberedList = CharacterShortcutEvent(
  key: 'insert new block after numbered list',
  character: '\n',
  handler: (editorState) async => await $insertNewLineInType(
    editorState,
    NumberedListBlockKeys.type,
  ),
);
