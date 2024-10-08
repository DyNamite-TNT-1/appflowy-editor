import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';

const int maxEmptyLines =
    3; // Maximum number of consecutive empty lines allowed

final CharacterShortcutEvent enterInCodeBlockEvent = CharacterShortcutEvent(
  key: 'insert new block after numbered list',
  character: '\n',
  handler: _handleEnterInCodeBlockCommand,
);

// Handler for the Enter key when in a code block
CharacterShortcutEventHandler _handleEnterInCodeBlockCommand =
    (editorState) async {
  final selection = editorState.selection;

  // Check if selection is valid and collapsed
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final currentNode = editorState.getNodeAtPath(selection.end.path);

  // Ensure the current node is a code block
  if (currentNode == null || currentNode.type != CodeBlockKeys.type) {
    return false;
  }

  final delta = currentNode.delta;

  final lines = delta?.toPlainText().split('\n') ?? [];
  int leadingSpaces = 0; // Leading spaces in the current line

  // Check if the delta and lines are valid
  if (delta != null && lines.isNotEmpty) {
    int charIndex = 0; // Current character index in the overall text

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      // Check if the cursor is within the current line
      if (charIndex <= selection.endIndex &&
          selection.endIndex <= charIndex + line.length) {
        // Check for consecutive empty lines
        if (lineIndex >= maxEmptyLines - 1) {
          int emptyLineCount = 0;
          int currentLineIndex = lineIndex;

          // Count empty lines above the current line
          while (emptyLineCount < maxEmptyLines && currentLineIndex >= 0) {
            final previousLine = lines[currentLineIndex];
            if (previousLine.isEmpty) {
              emptyLineCount++;
              currentLineIndex--;
            } else {
              break;
            }
          }

          // If maximum empty lines reached
          if (emptyLineCount == maxEmptyLines) {
            final simplifiedContent =
                delta.toPlainText().trim().replaceAll("\n", "");
            if (simplifiedContent.length > 1) {
              if (lineIndex == lines.length - 1) {
                await _removeNewLinesAndExitCodeBlock(editorState, currentNode);
                return true;
              } else {
                await _splitCodeBlock(editorState, currentNode, charIndex);
                return true;
              }
            } else {
              await _removeCodeBlock(editorState, currentNode);
              return true;
            }
          }
        }

        // Count leading spaces in the current line
        final lineLeadingSpaces = line.length - line.trimLeft().length;
        leadingSpaces = lineLeadingSpaces;
        break; // Exit loop after finding the current line
      }
      charIndex += line.length + 1; // Update character index for next line
    }
  }

  // Insert a new line with leading spaces
  final transaction = editorState.transaction
    ..insertText(
      currentNode,
      selection.end.offset,
      '\n${' ' * leadingSpaces}',
    );
  await editorState.apply(transaction);
  return true;
};

// Function to remove new lines and exit the code block
Future<void> _removeNewLinesAndExitCodeBlock(
  EditorState editorState,
  Node node,
) async {
  final delta = node.delta;
  if (delta == null) {
    return;
  }

  final transaction = editorState.transaction
    ..deleteText(node, delta.length - maxEmptyLines, maxEmptyLines)
    ..insertNode(node.path.next, paragraphNode())
    ..afterSelection = Selection.collapsed(Position(path: node.path.next));
  await editorState.apply(transaction);
}

// Function to remove the code block
Future<void> _removeCodeBlock(
  EditorState editorState,
  Node node,
) async {
  final transaction = editorState.transaction
    ..deleteNode(node)
    ..insertNode(node.path.next, paragraphNode())
    ..afterSelection = Selection.collapsed(Position(path: node.path));
  await editorState.apply(transaction);
}

// Function to split the code block at the specified index
Future<void> _splitCodeBlock(
  EditorState editorState,
  Node node,
  int index,
) async {
  final delta = node.delta;
  if (delta == null) {
    return;
  }
  final indexToDeleteFrom = index - maxEmptyLines;
  final deletionCount = delta.length - indexToDeleteFrom;

  final transaction = editorState.transaction
    ..deleteText(node, indexToDeleteFrom, deletionCount)
    ..insertNode(node.path.next, paragraphNode())
    ..insertNode(
      node.path.next,
      codeBlockNode(delta: delta.slice(index + 1)),
    )
    ..afterSelection = Selection.collapsed(Position(path: node.path.next));
  await editorState.apply(transaction);
}
