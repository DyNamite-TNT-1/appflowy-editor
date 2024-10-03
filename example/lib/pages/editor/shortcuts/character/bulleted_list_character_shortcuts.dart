import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:example/pages/editor/editor.dart';

/// Insert a new block after the bulleted list block.
///
/// - support
///   - mobile
///
CharacterShortcutEvent $insertNewLineAfterBulletedList = CharacterShortcutEvent(
  key: 'insert new block after bulleted list',
  character: '\n',
  handler: (editorState) async => await $insertNewLineInType(
    editorState,
    'bulleted_list',
  ),
);
