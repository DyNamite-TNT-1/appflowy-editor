import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor_plugins/appflowy_editor_plugins.dart';
import 'package:example/pages/editor/plugins/mention/mention_block/mention_block.dart';
import 'package:example/pages/editor/plugins/mention/mention_plugin.dart';
import 'package:example/pages/editor/toolbar/toolbar_items/toolbar_items.dart';
import 'package:example/pages/editor/ui/code_block/code_block_component.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'editor/editor.dart';
import 'editor/plugins/command/command_plugin.dart';
import 'editor/ui/numbered_list_block_component.dart';

final List<CharacterShortcutEvent> myCharacterShortcutEvents = [
  // '\n'
  $insertNewLineAfterBulletedList,
  $insertNewLineAfterTodoList,
  $insertNewLineAfterNumberedList,
  insertNewLineAfterHeading,
  enterInCodeBlockEvent,
  insertNewLineAfterQuote,
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
  ...tableCommands,
  $backspaceCommand,
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
  $indentCommand,
  $outdentCommand,

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

final List<UserMention> fakeMentions = [
  UserMention(alias: "user1", fullName: "Nguyen Trong Nhan"),
  UserMention(alias: "user2", fullName: "Nguyen Thanh Luan"),
  UserMention(alias: "user3", fullName: "Trinh Huu Tien"),
  UserMention(alias: "user4", fullName: "Dinh Hoang Hieu"),
  UserMention(alias: "user5", fullName: "Le Mau Anh Duc"),
];

class MobileEditor extends StatefulWidget {
  const MobileEditor({
    super.key,
    required this.editorState,
    this.editorStyle,
  });

  final EditorState editorState;
  final EditorStyle? editorStyle;

  @override
  State<MobileEditor> createState() => _MobileEditorState();
}

class _MobileEditorState extends State<MobileEditor> {
  EditorState get editorState => widget.editorState;

  late final EditorScrollController editorScrollController;

  late EditorStyle editorStyle;
  late Map<String, BlockComponentBuilder> blockComponentBuilders;

  @override
  void initState() {
    super.initState();

    editorScrollController = EditorScrollController(
      editorState: editorState,
      shrinkWrap: false,
    );

    editorStyle = _buildMobileEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
  }

  @override
  void reassemble() {
    super.reassemble();

    editorStyle = _buildMobileEditorStyle();
    blockComponentBuilders = _buildBlockComponentBuilders();
  }

  @override
  Widget build(BuildContext context) {
    return MobileToolbarV2(
      toolbarHeight: 48.0,
      toolbarItems: [
        textDecorationMobileToolbarItemV2,
        buildTextAndBackgroundColorMobileToolbarItem(),
        myBlocksToolbarItem,
        linkMobileToolbarItem,
        dividerMobileToolbarItem,
        indentMobileToolbarItem,
        outdentMobileToolbarItem,
      ],
      editorState: editorState,
      child: Column(
        children: [
          CommandPlugin(
            editorState: editorState,
            commands: standardCommands,
          ),
          MentionPlugin(
            editorState: editorState,
            mentions: fakeMentions,
          ),
          // build appflowy editor
          Expanded(
            child: MobileFloatingToolbar(
              editorState: editorState,
              editorScrollController: editorScrollController,
              toolbarBuilder: (context, anchor, closeToolbar) {
                return AdaptiveTextSelectionToolbar.editable(
                  clipboardStatus: ClipboardStatus.pasteable,
                  onCopy: () {
                    $copyCommand.execute(editorState);
                    closeToolbar();
                  },
                  onCut: () => $cutCommand.execute(editorState),
                  onPaste: () => $pasteCommand.execute(editorState),
                  onSelectAll: () => selectAllCommand.execute(editorState),
                  onLiveTextInput: null,
                  onLookUp: null,
                  onSearchWeb: null,
                  onShare: null,
                  anchors: TextSelectionToolbarAnchors(
                    primaryAnchor: anchor,
                  ),
                );
              },
              child: AppFlowyEditor(
                editorStyle: editorStyle,
                editorState: editorState,
                editorScrollController: editorScrollController,
                blockComponentBuilders: blockComponentBuilders,
                showMagnifier: true,
                characterShortcutEvents: myCharacterShortcutEvents,
                commandShortcutEvents: myCommandShortcutEvents,
                // showcase 3: customize the header and footer.
                header: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Image.asset(
                    'assets/images/header.png',
                  ),
                ),
                footer: const SizedBox(
                  height: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // showcase 1: customize the editor style.
  EditorStyle _buildMobileEditorStyle() {
    return EditorStyle.mobile(
      textScaleFactor: 1.0,
      cursorColor: const Color.fromARGB(255, 134, 46, 247),
      dragHandleColor: const Color.fromARGB(255, 134, 46, 247),
      selectionColor: const Color.fromARGB(50, 134, 46, 247),
      textStyleConfiguration: TextStyleConfiguration(
        text: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black,
        ),
        code: GoogleFonts.sourceCodePro(
          backgroundColor: Colors.grey.shade200,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      magnifierSize: const Size(144, 96),
      mobileDragHandleBallSize: const Size(12, 12),
      textSpanDecorator: customizeAttributeDecorator,
    );
  }

  InlineSpan customizeAttributeDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan before,
    TextSpan after,
  ) {
    final attributes = text.attributes;
    if (attributes == null) {
      return before;
    }

    // Inline Mentions (Page Reference, Date, Reminder, etc.)
    final mention =
        attributes[MentionBlockKeys.mention] as Map<String, dynamic>?;
    if (mention != null) {
      return WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        style: after.style,
        child: MentionBlock(
          key: ValueKey(mention[MentionBlockKeys.userId]),
          node: node,
          index: index,
          mention: mention,
          textStyle: after.style,
        ),
      );
    }

    return mobileTextSpanDecoratorForAttribute(
      context,
      node,
      index,
      text,
      before,
      after,
    );
  }

  // showcase 2: customize the block style
  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {
      ...standardBlockComponentBuilderMap,
    };
    // customize the heading block component
    final levelToFontSize = [
      24.0,
      22.0,
      20.0,
      18.0,
      16.0,
      14.0,
    ];
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      textStyleBuilder: (level) => GoogleFonts.poppins(
        fontSize: levelToFontSize.elementAtOrNull(level - 1) ?? 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
    map[ParagraphBlockKeys.type] = ParagraphBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        placeholderText: (node) => 'Type something...',
        indentPadding: (node, textDirection) {
          final multiplier = node.indent;
          switch (textDirection) {
            case TextDirection.ltr:
              return EdgeInsets.only(left: 24.0 * multiplier);
            case TextDirection.rtl:
              return EdgeInsets.only(right: 24.0 * multiplier);
          }
        },
      ),
    );
    map[QuoteBlockKeys.type] = QuoteBlockComponentBuilder(
      configuration: map[QuoteBlockKeys.type]!.configuration.copyWith(
        padding: (node) {
          return const EdgeInsets.all(0);
        },
      ),
    );
    map[BulletedListBlockKeys.type] = BulletedListBlockComponentBuilder(
      configuration: map[BulletedListBlockKeys.type]!.configuration.copyWith(
        indentPadding: (node, textDirection) {
          final multiplier = node.indent;
          switch (textDirection) {
            case TextDirection.ltr:
              return EdgeInsets.only(left: 24.0 * multiplier);
            case TextDirection.rtl:
              return EdgeInsets.only(right: 24.0 * multiplier);
          }
        },
      ),
    );
    map[NumberedListBlockKeys.type] = CustomNumberedListBlockComponentBuilder(
      configuration: map[NumberedListBlockKeys.type]!.configuration.copyWith(
        indentPadding: (node, textDirection) {
          final multiplier = node.indent;
          switch (textDirection) {
            case TextDirection.ltr:
              return EdgeInsets.only(left: 24.0 * multiplier);
            case TextDirection.rtl:
              return EdgeInsets.only(right: 24.0 * multiplier);
          }
        },
      ),
    );
    map[TodoListBlockKeys.type] = TodoListBlockComponentBuilder(
      configuration: map[TodoListBlockKeys.type]!.configuration.copyWith(
        indentPadding: (node, textDirection) {
          final multiplier = node.indent;
          switch (textDirection) {
            case TextDirection.ltr:
              return EdgeInsets.only(left: 24.0 * multiplier);
            case TextDirection.rtl:
              return EdgeInsets.only(right: 24.0 * multiplier);
          }
        },
      ),
    );
    map[QuoteBlockKeys.type] = QuoteBlockComponentBuilder(
      configuration: map[QuoteBlockKeys.type]!.configuration.copyWith(
        padding: (node) {
          return const EdgeInsets.all(0);
        },
      ),
    );
    map[CodeBlockKeys.type] = CustomCodeBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        placeholderText: (node) => 'Type something...',
        indentPadding: (node, textDirection) {
          final multiplier = node.indent;
          switch (textDirection) {
            case TextDirection.ltr:
              return EdgeInsets.only(left: 24.0 * multiplier);
            case TextDirection.rtl:
              return EdgeInsets.only(right: 24.0 * multiplier);
          }
        },
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      copyButtonBuilder: codeBlockCopyBuilder,
      showLineNumbers: false,
    );
    return map;
  }
}
