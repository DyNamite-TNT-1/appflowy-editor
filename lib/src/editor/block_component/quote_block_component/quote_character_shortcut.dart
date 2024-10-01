import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const _doubleQuotes = ['"', '“'];

/// Convert '" ' to quote
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatDoubleQuoteToQuote = CharacterShortcutEvent(
  key: 'format greater to quote',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => node.type != QuoteBlockKeys.type,
    (_, text, __) => _doubleQuotes.any((element) => element == text),
    (_, node, delta) => [
      quoteNode(
        attributes: {
          QuoteBlockKeys.delta: delta.compose(Delta()..delete(1)).toJson(),
        },
      ),
      if (node.children.isNotEmpty) ...node.children,
    ],
  ),
);

CharacterShortcutEvent insertNewLineAfterQuote = CharacterShortcutEvent(
  key: 'insert new block after quote',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.start.path);
  final delta = node?.delta;

  if (node?.type != QuoteBlockKeys.type || delta == null) {
    return false;
  }

  if (selection.startIndex == 0 && delta.isEmpty) {
    // convert quote to parapraph
    return KeyEventResult.ignored !=
        convertToParagraphCommand.execute(editorState);
  }

  await editorState.insertNewLine(
    nodeBuilder: (node) => node.copyWith(
      type: QuoteBlockKeys.type,
      attributes: {
        ...node.attributes,
      },
    ),
  );

  return true;
};
