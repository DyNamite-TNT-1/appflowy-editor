import 'package:appflowy_editor/appflowy_editor.dart';

import 'base_component/indent_command.dart';
import 'base_component/outdent_command.dart';

final List<CharacterShortcutEvent> myCharacterShortcutEvents = [
  // '\n'
  insertNewLineAfterBulletedList,
  insertNewLineAfterTodoList,
  insertNewLineAfterNumberedList,
  insertNewLineAfterHeading,
  insertNewLine,

  // bulleted list
  formatAsteriskToBulletedList,
  formatMinusToBulletedList,

  // numbered list
  formatNumberToNumberedList,

  // quote
  formatDoubleQuoteToQuote,

  // heading
  formatSignToHeading,

  // checkbox
  // format unchecked box, [] or -[]
  formatEmptyBracketsToUncheckedBox,
  formatHyphenEmptyBracketsToUncheckedBox,

  // format checked box, [x] or -[x]
  formatFilledBracketsToCheckedBox,
  formatHyphenFilledBracketsToCheckedBox,

  // slash
  slashCommand,

  // divider
  convertMinusesToDivider,
  convertStarsToDivider,
  convertUnderscoreToDivider,

  // markdown syntax
  ...markdownSyntaxShortcutEvents,

  // convert => to arrow
  formatGreaterEqual,
];

final List<CommandShortcutEvent> myCommandShortcutEvents = [
  // undo, redo
  undoCommand,
  redoCommand,

  // backspace
  convertToParagraphCommand,
  ...tableCommands,
  backspaceCommand,
  deleteLeftWordCommand,
  deleteLeftSentenceCommand,

  //delete
  deleteCommand,
  deleteRightWordCommand,

  // arrow keys
  ...arrowLeftKeys,
  ...arrowRightKeys,
  ...arrowUpKeys,
  ...arrowDownKeys,

  //
  homeCommand,
  endCommand,

  //
  toggleTodoListCommand,
  ...toggleMarkdownCommands,
  toggleHighlightCommand,
  showLinkMenuCommand,
  openInlineLinkCommand,
  openLinksCommand,

  //
  myIndentCommand,
  myOutdentCommand,

  //
  exitEditingCommand,

  //
  pageUpCommand,
  pageDownCommand,

  //
  selectAllCommand,

  // delete line
  deleteLineCommand,

  // copy paste and cut
  copyCommand,
  ...pasteCommands,
  cutCommand,
];
